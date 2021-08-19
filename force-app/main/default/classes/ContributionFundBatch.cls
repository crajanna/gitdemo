global class ContributionFundBatch implements
    Database.Batchable<sObject>, Database.Stateful{
    
    global Integer recordsProcessed = 0;
     
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            ' select Financial_Account_Investment__c,Financial_Account_Cash__c,Source_Type__c,Transfer_Amount__c '+
            ' from Transfer_Fund__c where Status__c = \'Complete\' and Start_Date__c = Today and RecordType.Name = \'Contribution\' and IsBatch__c = true');
			
    }
    public void execute(Database.BatchableContext bc, List<Transfer_Fund__c> records)
    {
        //Set<Id> cashaccountID = new 
        if(records.size()>0)//batch input is not null
        {            
            List<FinServ__FinancialAccountTransaction__c> financialTranscList = new List<FinServ__FinancialAccountTransaction__c>(); 

            
            for(transfer_fund__c tf : records)
            {
                financialTranscList.add(createFinancialTransactions(tf)); 
            } 
                recordsProcessed = financialTranscList.size();
                if(null != financialTranscList && financialTranscList.size() >0){
                   insert(financialTranscList);
                }
        }
     }
    
    	public FinServ__FinancialAccountTransaction__c createFinancialTransactions(Transfer_fund__c tf){
            	List<FinServ__FinancialAccountTransaction__c> finTranscList = new List<FinServ__FinancialAccountTransaction__c>();          
                FinServ__FinancialAccountTransaction__c credit_txn = new FinServ__FinancialAccountTransaction__c();           
                credit_txn.FinServ__Amount__c = tf.Transfer_Amount__c;
                credit_txn.FinServ__PostDate__c = DateTime.now();
                credit_txn.FinServ__TransactionType__c = 'Credit';
                credit_txn.FinServ__TransactionSubtype__c = 'Transfer In';
                credit_txn.Source_Category__c = 'Personal_Contribution';
                credit_txn.Source_Type__c = tf.Source_Type__c;
                credit_txn.FinServ__FinancialAccount__c = tf.Financial_Account_Investment__c;
                credit_txn.FinServ__TransactionStatus__c = 'Posted';
                credit_txn.FinServ__TransactionDate__c = DateTime.now();
            return credit_txn;
    }

    public void finish(Database.BatchableContext bc){
        
    }

}