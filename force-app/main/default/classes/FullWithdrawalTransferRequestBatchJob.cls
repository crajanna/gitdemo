global class FullWithdrawalTransferRequestBatchJob implements Database.Batchable<sObject>, Database.Stateful {
    
 global Integer recordsProcessed = 0;
    global Integer Transfer_recordsProcessed = 0;
   	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
           'select id,Status__c,Transfer_Amount__c,Source_Type__c,Financial_Account_Cash__c,Withdrawal_Source__c from Transfer_Fund__c where RecordType.Name = \'WithDrawal\' and Status__c =\'Queued\' and Full_Withdrawal__c = true and Withdrawal_Source__c != null'
        );
        
    }
    
    public void execute(Database.BatchableContext bc, List<Transfer_Fund__c> records)
    {
        
        // withdrawal invsetment account list
       List<FinServ__FinancialAccount__c> WithdrawlAccntListId = [select Id,FinServ__Balance__c from FinServ__FinancialAccount__c where Id in(Select Withdrawal_Source__c from Transfer_Fund__c where id =: records)];
       Map<Id,FinServ__FinancialAccount__c> InvestmentAccountMap= new Map<Id,FinServ__FinancialAccount__c>(WithdrawlAccntListId);
        
        List<Transfer_Fund__c> Upd_TransferList = new List<Transfer_Fund__c>(); 
       List<Transfer_Fund__c> new_TransferList = new List<Transfer_Fund__c>(); 
        
            
            
            for(transfer_fund__c tf : records)
            {
                 transfer_fund__c temp_transferFund = tf;
                transfer_fund__c new_transferFund = new Transfer_Fund__c();
                
                
                new_transferFund.Financial_Account_Cash__c = tf.Withdrawal_Source__c;
               // new_transferFund.RecordTypeId = '012P000000228OsIAI';
                 new_transferFund.RecordTypeId = Schema.SObjectType.transfer_fund__c.getRecordTypeInfosByName().get('Transfer').getRecordTypeId();
                //get full amount from investment account.
                 new_transferFund.Transfer_Amount__c = InvestmentAccountMap.get(tf.Withdrawal_Source__c).FinServ__Balance__c;
         
                new_transferFund.Status__c = 'Queued';
                new_transferFund.Frequency__c = 'One-Time';
                new_transferFund.Start_Date__c = Date.today();
                new_transferFund.Financial_Account_Investment__c = tf.Financial_Account_Cash__c;
                temp_transferFund.Status__c = 'Complete';
              
           	 new_TransferList.add(new_transferFund);   
             Upd_TransferList.add(temp_transferFund);
            }
      
               recordsProcessed = new_TransferList.size();
               Transfer_recordsProcessed = Upd_TransferList.size();

                if(!new_TransferList.isEmpty() && Schema.sObjectType.Transfer_Fund__c.fields.Status__c.isCreateable() ) {
                    insert new_TransferList;
                }
                if(!Upd_TransferList.isEmpty() && Schema.sObjectType.Transfer_Fund__c.fields.Status__c.isUpdateable()) {
                   update Upd_TransferList;
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