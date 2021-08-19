/* Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/20/2021   Satish Nikam    10924 - T2 : Refactoring WithdrawalAnnualSummaryBatchJob and QuarterlyAccountStmtBatchJob
**/
global class QuarterlyAccountStmtBatchJob implements Database.Batchable<sObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
    public Date startDate = null;
    public Date endDate = null;
    public Date startDateNextQ = null;
    public Date endDateNextQ = null;
    public static Id invAccoutRecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId();

   	public Database.QueryLocator start(Database.BatchableContext bc) {
       
        for(Period periodRecord :[SELECT startdate,enddate FROM Period WHERE type = 'Quarter' AND startdate IN (LAST_FISCAL_QUARTER, THIS_FISCAL_QUARTER) ORDER BY startdate asc]){
            if(startDate == null){
                startDate = periodRecord.startdate;
                endDate = periodRecord.enddate;
                continue;
            }
            
            if(startDate < periodRecord.startdate){
                startDateNextQ = periodRecord.startdate;
                endDateNextQ = periodRecord.enddate;
            }else{
                startDateNextQ = startDate;
                endDateNextQ = enddate;
                startDate = periodRecord.startdate;
                endDate = periodRecord.enddate;
            }
        }   
        //need to check if any additional where clause should be there
        return Database.getQueryLocator(
            'SELECT ID From FinServ__FinancialAccount__c WHERE RecordTypeId = :invAccoutRecordTypeId'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<FinServ__FinancialAccount__c> records){
        Set<Id> resultIds = (new Map<Id,FinServ__FinancialAccount__c>(records)).keySet();
        List<FinServ__Securities__c> securitiesList = [SELECT ID,FinServ__Price__c From FinServ__Securities__c];
        List<FinServ__FinancialHolding__c> holdingsList =  [select id, FinServ__FinancialAccount__r.Id, FinServ__Securities__r.Id, Cost_Basis__c, FinServ__PurchasePrice__c, FinServ__GainLoss__c, FinServ__Shares__c, FinServ__MarketValue__c from FinServ__FinancialHolding__c where FinServ__FinancialAccount__c = :resultIds ];
        List<Quarterly_Account_Summary__c> acccSumList =  [select id, Investment_Account__r.Id, Securities__r.id, Opening_Balance__c, Closing_Balance__c from Quarterly_Account_Summary__c where Quarter_Begin_Date__c=LAST_FISCAL_QUARTER and  Investment_Account__r.Id = :resultIds ];
        
        Map<String, FinServ__FinancialHolding__c> fhsMap = getFHsMap (holdingsList);
        Map<String, Quarterly_Account_Summary__c> qasMap  = getQASMap (acccSumList);
        Map<String, TotalTemp> totRecMaps = new Map<String, TotalTemp>();        
        List<Quarterly_Account_Summary__c> newAccSumList = new List<Quarterly_Account_Summary__c>();
        //Map<String, QuarterTemp> aggData = new Map<String, QuarterTemp>();
        for (AggregateResult  agg : [
            SELECT 
            Financial_Account__r.Id accId,
			Securities__r.id secId,
            Initiator_Type__c,
            SUM( Buy_Amount__c) totalAmount
            FROM Investment_Transaction__c  
            WHERE Status__c = 'Complete' and Financial_Account__r.Id in :resultIds

            GROUP BY Financial_Account__r.Id, Securities__r.id, Initiator_Type__c
        ]) {
            
            //Step 1 -
            String secId  = (String)agg.get('secId');
            String accId  = (String)agg.get('accId');
            String initiatorType  = (String)agg.get('Initiator_Type__c');
            Decimal totalAmount  = (Decimal)agg.get('totalAmount');
            String mapKey = accId +'-'+ secId;
            System.debug('mapKey-->'+mapKey);
            //Step 2- 
            Quarterly_Account_Summary__c quarter = qasMap.get(mapKey);
            FinServ__FinancialHolding__c fhObj = fhsMap.get(mapKey);
            if(quarter == null) {
                quarter = new Quarterly_Account_Summary__c();
                quarter.Investment_Account__c = accId;
                quarter.Securities__c = secId;
                quarter.Opening_Balance__c = 0;
                quarter.Quarter_Begin_Date__c = startDate;
                quarter.Quarter_End_Date__c = endDate;
            }  
            quarter.Contribution_Amount__c = totalAmount;
            quarter.Withdrawals_Amount__c = totalAmount;
            quarter.Closing_Balance__c = fhObj.FinServ__MarketValue__c;
            quarter.Total_Gains__c = fhObj.FinServ__GainLoss__c;
            //System.debug('quarter = ' + quarter);
            newAccSumList.add(quarter);
            
            TotalTemp totalTmp = totRecMaps.get(accId);
            if(totalTmp == null) {
                totalTmp = new TotalTemp(accId, 
                                         startDate, 
                                         endDate, 
                                         quarter.Opening_Balance__c, 
                                         totalAmount,  
                                         totalAmount, 
                                         fhObj.FinServ__MarketValue__c,
                                         fhObj.FinServ__GainLoss__c );
            } else {
                totalTmp.totalOpen += quarter.Opening_Balance__c;
                totalTmp.totalContribution += totalAmount;
                totalTmp.totalWithDrawal += totalAmount;
                totalTmp.totalClose += fhObj.FinServ__MarketValue__c;
                totalTmp.totGainLoss += fhObj.FinServ__GainLoss__c ;
            }
            totRecMaps.put(accId, totalTmp);
            
            //Preparing current quarterly object with opening balance for each security.
            Quarterly_Account_Summary__c nextQObj = new Quarterly_Account_Summary__c();
            nextQObj.Investment_Account__c = accId;
            nextQObj.Securities__c = secId;
            nextQObj.Opening_Balance__c = fhObj.FinServ__MarketValue__c;
            nextQObj.Quarter_Begin_Date__c = startDateNextQ;
            nextQObj.Quarter_End_Date__c = endDateNextQ;
            
            newAccSumList.add(nextQObj);
            ///////////////////////////////////////
        }
        
        //Inserting total records
        for(TotalTemp totTemp : totRecMaps.values()){
            Quarterly_Account_Summary__c totalRec = new Quarterly_Account_Summary__c();
            totalRec.Investment_Account__c = totTemp.accId;
            totalRec.Opening_Balance__c = totTemp.totalOpen;
            totalRec.Quarter_Begin_Date__c = totTemp.startDate;
            totalRec.Quarter_End_Date__c = totTemp.endDate;
            totalRec.Contribution_Amount__c = totTemp.totalContribution;
            totalRec.Withdrawals_Amount__c = totTemp.totalWithDrawal;
            totalRec.Closing_Balance__c = totTemp.totalClose;
            totalRec.Total_Gains__c = totTemp.totGainLoss;
            totalRec.Total_Row__c = 'Yes';
            newAccSumList.add(totalRec);
        }
        
        recordsProcessed += newAccSumList.size();
        if(!newAccSumList.isEmpty() && Schema.sObjectType.Quarterly_Account_Summary__c.fields.Investment_Account__c.isUpdateable() && Schema.sObjectType.Quarterly_Account_Summary__c.fields.Investment_Account__c.isCreateable()){
            upsert newAccSumList;
        }
    }

    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        EmailUtils.sendMessage(job, recordsProcessed);
    }
    
    private Map<String, FinServ__FinancialHolding__c> getFHsMap(List<FinServ__FinancialHolding__c> holdingsList){
        Map<String, FinServ__FinancialHolding__c> dataMap = new Map<String, FinServ__FinancialHolding__c>();
        for (FinServ__FinancialHolding__c  item : holdingsList) {
            String mapKey = item.FinServ__FinancialAccount__r.Id +'-'+ item.FinServ__Securities__r.Id;
            dataMap.put(mapKey, item);
        }
        return dataMap;
    }
    
    private Map<String, Quarterly_Account_Summary__c> getQASMap(List<Quarterly_Account_Summary__c> acccSumList){
        Map<String, Quarterly_Account_Summary__c> dataMap = new Map<String, Quarterly_Account_Summary__c>();
        for (Quarterly_Account_Summary__c  item : acccSumList) {
            String mapKey = item.Investment_Account__r.Id +'-'+ item.Securities__r.Id;
            dataMap.put(mapKey, item);
        }
        return dataMap;
    }
    
    public class TotalTemp {
        public String accId; 
        Date startDate;
        Date endDate;
        public Decimal totalOpen = 0;
        public Decimal totalContribution = 0;
        public Decimal totalWithDrawal = 0;
        public Decimal totalClose = 0;
        public Decimal totGainLoss = 0;
        
        public TotalTemp(String accId, 
                         Date startDate, 
                         Date endDate, 
                         Decimal totalOpen, 
                         Decimal totalContribution, 
                         Decimal totalWithDrawal, 
                         Decimal totalClose, 
                         Decimal totGainLoss){
            this.accId = accId;
            this.startDate = startDate;
            this.endDate = endDate;
            this.totalOpen = totalOpen;
            this.totalContribution = totalContribution;
            this.totalWithDrawal = totalWithDrawal;
            this.totalClose = totalClose;
            this.totGainLoss = totGainLoss;
        }
    }
}