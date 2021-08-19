/* Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/20/2021   Satish Nikam    10924 - T2 : Refactoring WithdrawalAnnualSummaryBatchJob and QuarterlyAccountStmtBatchJob
**/
global class WithdrawalAnnualSummaryBatchJob implements Database.Batchable<sObject>, Database.Stateful {
    
    public static Id transferRecordTypeId = Schema.SObjectType.Transfer_Fund__c.getRecordTypeInfosByDeveloperName().get('Transfer').getRecordTypeId();
    public static String STATUS_COMPLETE = 'Complete';
    
    //global Integer recordsProcessed = 0;
   	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id FROM Transfer_Fund__c WHERE RecordTypeId = :transferRecordTypeId AND Processed_Date__c = THIS_YEAR AND Status__c = :STATUS_COMPLETE'
        );
    }

	public void execute(Database.BatchableContext bc, List<Transfer_Fund__c> records){
        List<Withdrawal_Annual_Summary__c> summaries = new List<Withdrawal_Annual_Summary__c>();
        String currentYear = String.valueOf(System.Today().year());
        for (AggregateResult  agg : [SELECT Account__r.Id accountId,  SUM(Transfer_Amount__c) contribution, SUM(Withdrawal_Cost_Basis__c) costBasis FROM Transfer_Fund__c where Id IN :records group by  Account__r.Id]) {
            //String wtyMapKey = (String)agg.get('Id') +'' + (String)agg.get('Tax_Year__c');
            Withdrawal_Annual_Summary__c summary = new Withdrawal_Annual_Summary__c();
            summary.Account__c = (String)agg.get('accountId');
            summary.Tax_Year__c = currentYear;
            summary.Total_Cost_Basis__c = (Decimal)agg.get('costBasis');
            summary.Total_Distributions__c = Math.abs((Decimal)agg.get('contribution'));
            summaries.add(summary);
        }
        
        if(!summaries.isEmpty()){
            try{
                if(Schema.sObjectType.Withdrawal_Annual_Summary__c.fields.Total_Cost_Basis__c.isUpdateable() && Schema.sObjectType.Withdrawal_Annual_Summary__c.fields.Total_Cost_Basis__c.isCreateable()){
                    upsert summaries;
                }
            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while upserting Withdrawal Annual Summary Records :'+ ex.getMessage());
                
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        //EmailUtils.sendMessage(job, recordsProcessed);
    }
}