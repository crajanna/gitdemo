/**
 * Name: ProcessFinancialHoldingsDaily
 * Description: Refactor code for Financial Holding daily process
 * Test Class: 
 * Created By: Satish Nikam - 7/09/2021
 * Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/21/2021   Satish Nikam    10945 - T2 : Refactor code for Financial Holding daily process
**/
global class ProcessFinancialHoldingsDaily implements Database.Batchable<sObject>, Database.Stateful {
    
    public static String STATUS_COMPLETE = 'Complete';
    public static String ACTION_TYPE_BUY = 'Buy';


   	public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime createdSince = System.now().addHours(-24);//pulling all the records created in last 24 hours
        return Database.getQueryLocator(
            'SELECT Financial_Account__c,Securities__c,shares_quantity__c FROM Investment_Transaction__c WHERE CreatedDate > :createdSince AND Status__c = :STATUS_COMPLETE'
        );
        //need to check where cluase with Raj
    }

	public void execute(Database.BatchableContext bc, List<Investment_Transaction__c> invTranList){

        Set<String> accIds = new Set<String>();	
        List<FinServ__FinancialHolding__c> fhs = new List<FinServ__FinancialHolding__c>();
        for (Investment_Transaction__c  item : invTranList) {
            accIds.add(item.Financial_Account__c); 
        }
        
        Set<Id> secIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        //Retrive average purchase prices to calculate cost basis.
        List<AggregateResult> aggrData = new List<AggregateResult>();
        for (AggregateResult  agg : [
            SELECT 
            Securities__c secId, 
            Financial_Account__c accId, 
            AVG( Purchase_Price__c) sharePrice  
            FROM Investment_Transaction__c  
            WHERE Status__c = :STATUS_COMPLETE and Action_Type__c = :ACTION_TYPE_BUY and Financial_Account__c in :accIds
            GROUP BY Securities__c, Financial_Account__c
        ]) {
            String secId  = (String)agg.get('secId');
            secIdSet.add(secId);
            aggrData.add(agg);
            String accId  = (String)agg.get('accId');
            accIdSet.add(accId);
        }

        
        //retrive security to finance Holding Mapping
        Map<String, List<FinServ__FinancialHolding__c>> secFinanceHoldingMapping = new Map<String, List<FinServ__FinancialHolding__c>>();
        for (FinServ__FinancialHolding__c  item : [SELECT id, FinServ__Price__c, Cost_Basis__c, FinServ__PurchasePrice__c, FinServ__MarketValue__c, FinServ__GainLoss__c, FinServ__Shares__c, FinServ__PercentChange__c,FinServ__Securities__c,FinServ__FinancialAccount__c 
                                                   FROM FinServ__FinancialHolding__c 
                                                   WHERE FinServ__FinancialAccount__c IN :accIdSet AND 
                                                         FinServ__Securities__c IN :secIdSet]) {
            String keyStr = String.ValueOf(item.FinServ__Securities__c +'-'+item.FinServ__FinancialAccount__c);                                                 
            List<FinServ__FinancialHolding__c> finHoldingList = secFinanceHoldingMapping.get(keyStr)== null ? 
                                                                new List<FinServ__FinancialHolding__c>():
                                                                secFinanceHoldingMapping.get(keyStr);
            finHoldingList.add(item);
            secFinanceHoldingMapping.put(keyStr,finHoldingList);
        }
        
        //retrive security records
        Map<Id,FinServ__Securities__c> securitiesMap = new Map<Id,FinServ__Securities__c>( [SELECT Id, Name, FinServ__SecuritiesName__c, Fund_Category__c,FinServ__Price__c 
                                                                                                            From FinServ__Securities__c 
                                                                                                            Where Id IN :secIdSet]);
        
        //if financial holding is not present for for security create new FH
        for(Investment_Transaction__c  item :invTranList){
            String keyStr = String.ValueOf(item.Securities__c +'-'+item.Financial_Account__c);  
            if(secFinanceHoldingMapping.get(keyStr) == null) {
                FinServ__Securities__c secRecord = securitiesMap.get(item.Securities__c);
                if(secRecord == null) continue;
                FinServ__FinancialHolding__c  fhItem = new FinServ__FinancialHolding__c();
                fhItem.FinServ__Securities__c = item.Securities__c;
                //need to update remaining values as per flow
                fhItem.Cost_Basis__c = secRecord.FinServ__Price__c;
                fhItem.FinServ__MarketValue__c= secRecord.FinServ__Price__c;
                fhItem.FinServ__Price__c = secRecord.FinServ__Price__c;
                fhItem.Name = secRecord.Name;
                fhItem.FinServ__FinancialAccount__c = item.Financial_Account__c;
                fhItem.FinServ__Shares__c = item.shares_quantity__c;
                fhs.add(fhItem);

            }
           
        }
        //Iterate average purchase prices to calculate cost basis.
        for (AggregateResult  agg : aggrData) {
            String secId  = (String)agg.get('secId');
            String accId  = (String)agg.get('accId');
            String keyStr = String.ValueOf(secId +'-'+accId);
            Decimal sharePrice  = (decimal)agg.get('sharePrice');
            List<FinServ__FinancialHolding__c>  itemList = secFinanceHoldingMapping.get(keyStr);
            if(itemList != null){
                for (FinServ__FinancialHolding__c  item :itemList) {
                    System.debug(item.Cost_Basis__c);
                    if(item.FinServ__Shares__c==0){
                        item.Cost_Basis__c = 0;
                        item.FinServ__PurchasePrice__c = 0;
                        item.FinServ__MarketValue__c = 0;
                        item.FinServ__GainLoss__c = 0;
                        item.FinServ__PercentChange__c = 0;
                    } else {
                        Decimal costBasis = item.FinServ__Shares__c * sharePrice;
                        Decimal mrktValue = item.FinServ__Shares__c * item.FinServ__Price__c;
                        item.Cost_Basis__c = costBasis;
                        item.FinServ__MarketValue__c = mrktValue;
                        item.FinServ__PurchasePrice__c = sharePrice;
                        item.FinServ__GainLoss__c = mrktValue - costBasis;
                        decimal percentage = 100 * (mrktValue - costBasis)/ costBasis;
                        item.FinServ__PercentChange__c = percentage;
                    }
                    fhs.add(item);
                }
            }
        }
        if(!fhs.isEmpty()){
            try{
                if(Schema.sObjectType.FinServ__FinancialHolding__c.fields.FinServ__MarketValue__c.isUpdateable() && Schema.sObjectType.FinServ__FinancialHolding__c.fields.FinServ__MarketValue__c.isCreateable()){
                    upsert fhs;
                }
            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while upserting Financial Holding records :'+ ex.getMessage());
                //return 'Error while inserting Investment Transaction :'+ ex.getMessage();
            }
            
        }

    }

    public void finish(Database.BatchableContext bc){
        //Chaining of Batch Jobs - #6 - SecurityPerformanceIndicatorsBatchJob
        Batch_Configuration__mdt pspHistoryRecord = Batch_Configuration__mdt.getInstance('SecurityPerformanceIndicatorsBatchJob');
        Integer transactionSize = pspHistoryRecord != null ? Integer.ValueOf(pspHistoryRecord.Transaction_Size__c) : 10;
        Database.executeBatch(new SecurityPerformanceIndicatorsBatchJob(),transactionSize);
    }
}