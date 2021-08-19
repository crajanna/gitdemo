/**
 * Modifications Log: 
 * Date         Modified By    Modification Details
 *   xx            xxx         Original Implementation for InvestmentTransactionRS
 * 7/14/2021   Satish Nikam    Cleanup activity / Removed hardcoded recordtypeId
 * 7/16/2021   Satish Nikam    Cleanup activity / Updated Bulkification support and FH insertion scenarion from flow to code
**/
@RestResource(urlMapping='/InvestmentTrxRS/*')
global with sharing class InvestmentTransactionRS {
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_COMPLETE = 'Complete';
    public static String ACTION_TYPE_BUY = 'Buy';
    public static Id transferRecordTypeId = Schema.SObjectType.Transfer_Fund__c.getRecordTypeInfosByDeveloperName().get('Transfer').getRecordTypeId();

	@HttpPost
    global static boolean markCompleted() {
        
        Map<ID, FinServ__FinancialAccount__c> accountsMap = new Map<ID, FinServ__FinancialAccount__c>([select Id, Cost_Basis__c, Earnings_Ratio__c from FinServ__FinancialAccount__c where Id in (select Financial_Account_Cash__c from Transfer_Fund__c where RecordTypeId = :transferRecordTypeId and Status__c = :STATUS_PROCESSING)]);
        List<Transfer_Fund__c> withdrawls = [SELECT Status__c, Transfer_Amount__c, Financial_Account_Cash__c FROM Transfer_Fund__c  where RecordTypeId = :transferRecordTypeId and Status__c = :STATUS_PROCESSING];
        
        //Map<ID, FinServ__FinancialAccount__c> accountsMap = new Map<ID, FinServ__FinancialAccount__c>([select Id, Cost_Basis__c, Earnings_Ratio__c from FinServ__FinancialAccount__c where Id in (select Financial_Account_Cash__c from Transfer_Fund__c where RecordTypeId = :transferRecordTypeId and Financial_Account_Cash__c = 'a0FP0000007uyy8MAA')]);
        //List<Transfer_Fund__c> withdrawls = [SELECT Status__c, Transfer_Amount__c, Financial_Account_Cash__c FROM Transfer_Fund__c  where RecordTypeId = :transferRecordTypeId and Financial_Account_Cash__c = 'a0FP0000007uyy8MAA' and Withdrawal_Cost_Basis__c = null];
        if(accountsMap!=null && withdrawls!=null) {
            List<FinServ__FinancialAccount__c> accountsToUpdate = new List<FinServ__FinancialAccount__c>();
            for(Transfer_Fund__c w: withdrawls){
                
                FinServ__FinancialAccount__c account = accountsMap.get(w.Financial_Account_Cash__c);
                
                Decimal withdrawlAmount = Math.abs(w.Transfer_Amount__c);
                Decimal earningsPortion = (account.Earnings_Ratio__c * withdrawlAmount) / 100;
                Decimal wCostBasic =  withdrawlAmount - earningsPortion;
                Decimal aCostBasic =  account.Cost_Basis__c - wCostBasic;
                
                w.Withdrawal_Cost_Basis__c = wCostBasic;
                w.Processed_Date__c = DateTime.now();
                w.Status__c = STATUS_COMPLETE;
                account.Cost_Basis__c = aCostBasic;
                accountsToUpdate.add(account);
            }

            try{
                
                if(!withdrawls.isEmpty() && Schema.sObjectType.Transfer_Fund__c.fields.Status__c.isUpdateable() ) {
                    update withdrawls;
                }

            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while updating Transfer Fund records :'+ ex.getMessage());
            }

            try{
                update accountsToUpdate;
            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while updating account records :'+ ex.getMessage());
            }
        } 
        
        
        List<Investment_Transaction__c> items = [SELECT id, Status__c,shares_quantity__c, Action_Type__c, Cost_Basis__c FROM Investment_Transaction__c  where Status__c = 'Processing'];
        for(Investment_Transaction__c item: items){
            item.Status__c = STATUS_COMPLETE;
        }
        
        try{
            if(!items.isEmpty() && Schema.sObjectType.Investment_Transaction__c.fields.Status__c.isUpdateable() ) {
                update items;
            }
        }Catch(Exception ex){
            //we can log error if needed
            System.debug('Error while updating Investment_Transaction__c records :'+ ex.getMessage());
        }
        resetFinancialHoldings();
        return true;
    }
    
    private static void resetFinancialHoldings(){
        Set<String> accIds = new Set<String>();	
        List<FinServ__FinancialHolding__c> fhs = new List<FinServ__FinancialHolding__c>();
        List<Investment_Transaction__c> invTranList = new List<Investment_Transaction__c>();
        for (Investment_Transaction__c  item : [SELECT Financial_Account__c,Securities__c,shares_quantity__c FROM Investment_Transaction__c WHERE CreatedDate = today]) {
            accIds.add(item.Financial_Account__c); 
            invTranList.add(item);
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
            Decimal sharePrice  = (decimal)agg.get('sharePrice');
            List<FinServ__FinancialHolding__c>  itemList = secFinanceHoldingMapping.get(secId);
            if(itemList != null){
                for (FinServ__FinancialHolding__c  item :secFinanceHoldingMapping.get(secId) ) {
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
                if(Schema.sObjectType.FinServ__FinancialHolding__c.fields.FinServ__PurchasePrice__c.isUpdateable() && Schema.sObjectType.FinServ__FinancialHolding__c.fields.FinServ__PurchasePrice__c.isCreateable()) {
                    upsert fhs;
                }
                
            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while upserting Financial Holding records :'+ ex.getMessage());
                //return 'Error while inserting Investment Transaction :'+ ex.getMessage();
            }
            
        }
        
    }
}