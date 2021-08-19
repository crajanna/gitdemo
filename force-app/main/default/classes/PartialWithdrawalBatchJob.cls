global class PartialWithdrawalBatchJob implements Database.Batchable<sObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
    global Integer Transfer_recordsProcessed = 0;
   	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
           'select id,Status__c,Transfer_Amount__c,Source_Type__c,Financial_Account_Cash__c from Transfer_Fund__c where RecordType.Name = \'WithDrawal\' and Status__c =\'Queued\' and Full_Withdrawal__c = false and Withdrawal_Source__c = null'
        );
        
    }
    
    public void execute(Database.BatchableContext bc, List<Transfer_Fund__c> records)
    {
       
        if(records.size()>0)//batch input is not null
        {
       	     List<FinServ__FinancialAccountTransaction__c> finTranscList = new List<FinServ__FinancialAccountTransaction__c>(); 
            List<Transfer_Fund__c> Upd_TransferList = new List<Transfer_Fund__c>(); 
            
            for(transfer_fund__c tf : records)
            {
            	FinServ__FinancialAccountTransaction__c tempFin_txn = new FinServ__FinancialAccountTransaction__c(); 
                transfer_fund__c temp_transferFund = tf;
                
                
                tempFin_txn.FinServ__Amount__c = tf.Transfer_Amount__c;
                tempFin_txn.FinServ__PostDate__c = DateTime.now();
                tempFin_txn.FinServ__TransactionType__c = 'Debit';
                tempFin_txn.FinServ__TransactionSubtype__c = 'Withdrawal';
                tempFin_txn.Source_Type__c = tf.Source_Type__c;
               	tempFin_txn.FinServ__FinancialAccount__c = tf.Financial_Account_Cash__c;
                tempFin_txn.FinServ__TransactionStatus__c = 'Posted';
                tempFin_txn.FinServ__TransactionDate__c = DateTime.now();
               
                temp_transferFund.Status__c = 'Complete';
              
             finTranscList.add(tempFin_txn);   
             Upd_TransferList.add(temp_transferFund);
            }
      
               recordsProcessed = finTranscList.size();
               Transfer_recordsProcessed = Upd_TransferList.size();

            if(!finTranscList.isEmpty() && Schema.sObjectType.FinServ__FinancialAccountTransaction__c.fields.FinServ__Amount__c.isCreateable() ) {
                insert finTranscList;
            }
            if(!Upd_TransferList.isEmpty() && Schema.sObjectType.Transfer_Fund__c.fields.Status__c.isUpdateable()) {
               update Upd_TransferList;
            }
        }
    }
    
    public void finish(Database.BatchableContext bc)
    {
          AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        JobEmailUtility.sendMessage(job, recordsProcessed);
    }

}