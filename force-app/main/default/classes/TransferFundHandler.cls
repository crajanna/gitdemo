public class TransferFundHandler {     
     
    public void createFinancialTransactions(List<Transfer_Fund__c> newList){
         for(Transfer_Fund__c txns : newList)
        {
        List<FinServ__FinancialAccountTransaction__c> finTranscList = new List<FinServ__FinancialAccountTransaction__c>();    
        List<Transfer_Fund__c> records = [ select Financial_Account_Investment__c,Source_Type__c,Transfer_Amount__c 
                                          from Transfer_Fund__c where Status__c = 'Complete' and Start_Date__c = Today
                                         and id = :txns.id];
        if(records.size()>0)
        { 
             
            for(transfer_fund__c tf : records)
            {
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
                
                finTranscList.add(credit_txn);   
            }
        }
            insert(finTranscList);
        }
            
        
    }            
}