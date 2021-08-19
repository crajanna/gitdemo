/**
 * Name: ProcessTransferFundDailyBatch
 * Description: Refactor code for Transfer Fund daily process
 * Test Class: 
 * Created By: Satish Nikam - 7/26/2021
 * Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/26/2021   Satish Nikam    11203 - T2 : Refactor transfer Fund daily job
**/
global class ProcessTransferFundDailyBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static Id transferRecordTypeId = Schema.SObjectType.Transfer_Fund__c.getRecordTypeInfosByDeveloperName().get('Transfer').getRecordTypeId();
    public static String STATUS_COMPLETE = 'Complete';
    public static String ACTION_TYPE_BUY = 'Buy';
    public static String STATUS_PROCESSING = 'Processing';
    public static String INTIATOR_TYPE_WITHDRAWAL = 'Withdrawal';
    public static String ACTION_TYPE_SELL = 'Sell';

   	public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime createdSince = System.now().addHours(-24);//pulling all the records created in last 24 hours
        return Database.getQueryLocator(
            'SELECT Status__c, Transfer_Amount__c, Financial_Account_Cash__c '
           +'FROM Transfer_Fund__c '
           +'WHERE RecordTypeId = :transferRecordTypeId '
           +'AND Status__c = :STATUS_PROCESSING '
           +'AND CreatedDate > :createdSince'
        );
    }

	public void execute(Database.BatchableContext bc, List<Transfer_Fund__c> withdrawls){

        Map<ID, FinServ__FinancialAccount__c> accountsMap = new Map<ID, FinServ__FinancialAccount__c>([SELECT Id, Cost_Basis__c, Earnings_Ratio__c FROM FinServ__FinancialAccount__c WHERE Id in (Select Financial_Account_Cash__c FROM Transfer_Fund__c WHERE Id IN :withdrawls)]);
        List<Investment_Transaction__c> InvTransactionList = new List<Investment_Transaction__c>(); 
        //List<FinServ__FinancialAccount__c> accountsToUpdate = new List<FinServ__FinancialAccount__c>();
        Set<Id> accIds = new Set<Id>();
        for(Transfer_Fund__c transFund: withdrawls){
            
            FinServ__FinancialAccount__c account = accountsMap.get(transFund.Financial_Account_Cash__c);
            
            Decimal withdrawlAmount = Math.abs(transFund.Transfer_Amount__c);
            Decimal earningsPortion = (account.Earnings_Ratio__c * withdrawlAmount) / 100;
            Decimal wCostBasic =  withdrawlAmount - earningsPortion;
            //Decimal aCostBasic =  account.Cost_Basis__c - wCostBasic;
            
            transFund.Withdrawal_Cost_Basis__c = wCostBasic;
            transFund.Processed_Date__c = DateTime.now();
            transFund.Status__c = STATUS_COMPLETE;
            //account.Cost_Basis__c = aCostBasic;
            //accountsToUpdate.add(account);
            accIds.add(transFund.Financial_Account_Cash__c);
            
        }

        try{
            if(!withdrawls.isEmpty() && Schema.sObjectType.Transfer_Fund__c.fields.Withdrawal_Cost_Basis__c.isUpdateable()) {
                update withdrawls;
            }
        }Catch(Exception ex){
            //we can log error if needed
            System.debug('Error while updating Transfer Fund records :'+ ex.getMessage());
        }
        /*
        for(FinServ__FinancialHolding__c  finHoldingItem : [SELECT Id,FinServ__Securities__c, FinServ__MarketValue__c,FinServ__Shares__c,FinServ__Price__c,
                                                                FinServ__FinancialAccount__C,FinServ__FinancialAccount__r.FinServ__Balance__c,FinServ__Securities__r.FinServ__Price__c,FinServ__Securities__r.Name
                                                                FROM FinServ__FinancialHolding__c 
                                                                WHERE FinServ__FinancialAccount__C IN :accIds]){
                                                                    
            Decimal marketAllocation = finHoldingItem.FinServ__MarketValue__c * finHoldingItem.FinServ__FinancialAccount__r.FinServ__Balance__c;
            Decimal MarketAllocationPerc = finHoldingItem.FinServ__MarketValue__c/finHoldingItem.FinServ__FinancialAccount__r.FinServ__Balance__c;
            Decimal securityWithdrawalAmt ;//= MarketAllocationPerc * (TransferFund.Transfer_Amount__c * -1);
            Decimal TransactionAmount = securityWithdrawalAmt * -1;
            Decimal SharesToWithdraw = (securityWithdrawalAmt / finHoldingItem.FinServ__Securities__r.FinServ__Price__c) * -1;
            Investment_Transaction__c  InvTransactionObj = new Investment_Transaction__c();
            InvTransactionObj.Financial_Account__c = finHoldingItem.FinServ__FinancialAccount__c;
            InvTransactionObj.Action_Type__c = ACTION_TYPE_SELL;
            InvTransactionObj.Status__c = STATUS_PROCESSING; 
            InvTransactionObj.shares_quantity__c = SharesToWithdraw;
            InvTransactionObj.Buy_Amount__c = TransactionAmount; 
            InvTransactionObj.Purchase_Price__c = finHoldingItem.FinServ__Securities__r.FinServ__Price__c;
            InvTransactionObj.Securities__c = finHoldingItem.FinServ__Securities__c;
            InvTransactionObj.Cost_Basis__c = finHoldingItem.FinServ__MarketValue__c * -1;
            InvTransactionObj.Initiator_Type__c = INTIATOR_TYPE_WITHDRAWAL;
            InvTransactionObj.Transaction_Date__c = System.now();
            InvTransactionList.add(InvTransactionObj);

        }*/

        /*
        try{
            update accountsToUpdate;
        }Catch(Exception ex){
            //we can log error if needed
            System.debug('Error while updating account records :'+ ex.getMessage());
        }
        */
    }

    public void finish(Database.BatchableContext bc){
        //Chaining of Batch Jobs - #4 - ProcessInvestTransactionDailyBatch
        Batch_Configuration__mdt pspHistoryRecord = Batch_Configuration__mdt.getInstance('ProcessInvestTransactionDailyBatch');
        Integer transactionSize = pspHistoryRecord != null ? Integer.ValueOf(pspHistoryRecord.Transaction_Size__c) : 10;
        Database.executeBatch(new ProcessInvestTransactionDailyBatch(),transactionSize);
    }
}