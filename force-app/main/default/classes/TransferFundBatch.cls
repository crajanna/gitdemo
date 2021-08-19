global class TransferFundBatch implements
    Database.Batchable<sObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
     
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            ' select Financial_Account_Cash__c,Financial_Account_Investment__c,Source_Type__c,Transfer_Amount__c,'+
            'Financial_Account_Cash__r.RecordTypeId,Financial_Account_Cash__r.FinServ__Balance__c  '+
            ' from Transfer_Fund__c where Status__c = \'Queued\' and Start_Date__c = Today and RecordType.Name = \'Transfer\'');
			
    }
    public void execute(Database.BatchableContext bc, List<Transfer_Fund__c> records)
    {
        //Set<Id> cashaccountID = new 
        if(records.size()>0)//batch input is not null
        {            
            List<FinServ__FinancialAccountTransaction__c> financialTranscList = new List<FinServ__FinancialAccountTransaction__c>(); 
            List<Transfer_Fund__c> updateTransferFundList  = new List<Transfer_Fund__c>(); 
            List<Investment_Transaction__c> investmentTransactionList = new List<Investment_Transaction__c>();
            Double marketAllocationPerc;
            Double securityWithdrawalAmt;
            Double sharesToWithdraw;
            for(transfer_fund__c tf : records)
            {
                Transfer_Fund__c updateTransferFund = new Transfer_Fund__c();
                if(tf.Financial_Account_Cash__r.RecordTypeId == 
                   Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId()){
                  List<FinServ__FinancialHolding__c> financialHoldings = [SELECT Id, FinServ__MarketValue__c, FinServ__Price__c, FinServ__Shares__c  ,FinServ__Securities__c
                                                                          from FinServ__FinancialHolding__c WHERE FinServ__FinancialAccount__c =:tf.Financial_Account_Cash__c];
                    for(FinServ__FinancialHolding__c fh :financialHoldings) {
                        Investment_Transaction__c investment_Transaction = new Investment_Transaction__c();
                        marketAllocationPerc = 0.0;
                        securityWithdrawalAmt = 0.0 ;
                        sharesToWithdraw = 0;
                    	marketAllocationPerc = fh.FinServ__MarketValue__c / tf.Financial_Account_Cash__r.FinServ__Balance__c;
                        securityWithdrawalAmt = marketAllocationPerc *  (tf.Transfer_Amount__c * -1);
                        sharesToWithdraw = (securityWithdrawalAmt / fh.FinServ__Price__c) * -1;
                        investment_Transaction.shares_quantity__c = sharesToWithdraw;
                        investment_Transaction.Action_Type__c = 'Sell';
                        investment_Transaction.Financial_Account__c= fh.FinServ__FinancialAccount__c;
                        investment_Transaction.Buy_Amount__c = securityWithdrawalAmt * -1;
                        investment_Transaction.Status__c = 'Processing';
                        investment_Transaction.Purchase_Price__c = fh.FinServ__Price__c;
                        investment_Transaction.Securities__c = fh.FinServ__Securities__c;
                        investment_Transaction.Cost_Basis__c = securityWithdrawalAmt;
                        investment_Transaction.Initiator_Type__c = 'Transfer';
                        investment_Transaction.Transaction_Date__c = Date.today();
                    }
                    updateTransferFund.Status__c = 'Processing';
                   }else{
                     updateTransferFund.Status__c = 'Complete';  
                     financialTranscList = createFinancialTransactions(tf);
                   }
               
                updateTransferFund.Id = tf.Id;
                updateTransferFundList.add(updateTransferFund);
             
            }
      
                recordsProcessed = financialTranscList.size();
                if(null != financialTranscList && financialTranscList.size() >0){
                   insert(financialTranscList);
                }
                update(updateTransferFundList);
        }
     }
    
    	public List<FinServ__FinancialAccountTransaction__c> createFinancialTransactions(Transfer_fund__c tf){
            	List<FinServ__FinancialAccountTransaction__c> finTranscList = new List<FinServ__FinancialAccountTransaction__c>(); 
        		FinServ__FinancialAccountTransaction__c debit_txn = new FinServ__FinancialAccountTransaction__c(); 
           
                debit_txn.FinServ__Amount__c = tf.Transfer_Amount__c;
                debit_txn.FinServ__PostDate__c = DateTime.now();
                debit_txn.FinServ__TransactionType__c = 'Debit';
                debit_txn.FinServ__TransactionSubtype__c = 'Transfer Out';
                debit_txn.Source_Category__c = 'Personal_Contribution';
                debit_txn.Source_Type__c = tf.Source_Type__c;
                debit_txn.FinServ__FinancialAccount__c = tf.Financial_Account_Cash__c;
                debit_txn.FinServ__TransactionStatus__c = 'Posted';
                debit_txn.FinServ__TransactionDate__c = DateTime.now();
                
                finTranscList.add(debit_txn);  
                
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
            return finTranscList;
    }
    public void finish(Database.BatchableContext bc){
        
    }
}