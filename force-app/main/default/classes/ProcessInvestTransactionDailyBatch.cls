/**
 * Name: ProcessInvestTransactionDailyBatch
 * Description: Refactor code for Investment transaction daily process
 * Test Class: 
 * Created By: Satish Nikam - 7/26/2021
 * Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/26/2021   Satish Nikam    11203 - T2 : Refactor Investment transaction daily job
**/
global class ProcessInvestTransactionDailyBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_COMPLETE = 'Complete';
    
   	public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'SELECT id, Status__c,shares_quantity__c, Action_Type__c, Cost_Basis__c FROM Investment_Transaction__c  where Status__c = :STATUS_PROCESSING'
           
        );
    }

	public void execute(Database.BatchableContext bc, List<Investment_Transaction__c> invTransactionList){
        List<Investment_Transaction__c> invTransactionListToUpdate = new List<Investment_Transaction__c>();
        for(Investment_Transaction__c item: invTransactionList){
            item.Status__c = STATUS_COMPLETE;
            invTransactionListToUpdate.add(item);
        }
        
        try{
            if(!invTransactionListToUpdate.isEmpty() && Schema.sObjectType.Investment_Transaction__c.fields.Status__c.isUpdateable()){
                update invTransactionListToUpdate;
            }
        }Catch(Exception ex){
            //we can log error if needed
            System.debug('Error while updating Investment_Transaction__c records :'+ ex.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc){
        //Chaining of Batch Jobs - #5 - ProcessFinancialHoldingsDaily
        Batch_Configuration__mdt pspHistoryRecord = Batch_Configuration__mdt.getInstance('ProcessFinancialHoldingsDaily');
        Integer transactionSize = pspHistoryRecord != null ? Integer.ValueOf(pspHistoryRecord.Transaction_Size__c) : 10;
        Database.executeBatch(new ProcessFinancialHoldingsDaily(),transactionSize);
    }
}