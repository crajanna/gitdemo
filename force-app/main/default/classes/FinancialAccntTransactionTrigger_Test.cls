@isTest
public class FinancialAccntTransactionTrigger_Test {

 @isTest
    public static void testtrigger()
    {
   
	    //create new account
  		Account a  = new Account();  
        a.FirstName = 'TestFirsts';
        a.LastName = 'testlastn';
        a.RecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']; 
        insert a;
        a = [Select OwnerID, Owner.ID From Account where ID = :a.id];
        //create temp cash account
     
        FinServ__FinancialAccount__c tempcashaccount = new FinServ__FinancialAccount__c();
        tempcashaccount.FinServ__PrimaryOwner__c = a.id;
        tempcashaccount.Name = 'Test Cash Account for apex Testing';
        tempcashaccount.FinServ__Status__c = 'Active'; 
        tempcashaccount.RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
       	tempcashaccount.FinServ__FinancialAccountType__c = 'Cash Account';
        insert tempcashaccount;     
        //create transaction record
        system.debug('created account id: '+tempcashaccount.Id);
   
        List<FinServ__FinancialAccountTransaction__c> ListRollup = new List<FinServ__FinancialAccountTransaction__c>();
        		FinServ__FinancialAccountTransaction__c tempFin_txn = new FinServ__FinancialAccountTransaction__c();
         
                tempFin_txn.FinServ__Amount__c = 100;
                tempFin_txn.FinServ__PostDate__c = DateTime.now();
                tempFin_txn.FinServ__TransactionType__c = 'Debit';
                tempFin_txn.FinServ__TransactionSubtype__c = 'Withdrawal';
                tempFin_txn.Source_Type__c = 'ACH';
               	tempFin_txn.FinServ__FinancialAccount__c = tempcashaccount.Id;
                tempFin_txn.FinServ__TransactionStatus__c = 'Posted';
                tempFin_txn.FinServ__TransactionDate__c = DateTime.now();
        
                ListRollup.add(tempFin_txn);
                system.debug('list size: '+ListRollup.size());
                if(ListRollup.size()>0)
      			insert(ListRollup);
        
        List<FinServ__FinancialAccountTransaction__c> ListRollup1 = new List<FinServ__FinancialAccountTransaction__c>();
         
        FinServ__FinancialAccountTransaction__c tempFin_txn12 = ListRollup[0];
         
                tempFin_txn12.FinServ__Amount__c = 1000;
               
                ListRollup1.add(tempFin_txn12);
                system.debug('list size: '+ListRollup1.size());
                if(ListRollup1.size()>0)
      			update(ListRollup1);
        
         List<FinServ__FinancialAccountTransaction__c> ListFeewaiver = new List<FinServ__FinancialAccountTransaction__c>();
        		FinServ__FinancialAccountTransaction__c tempFin_txn1 = new FinServ__FinancialAccountTransaction__c(
                FinServ__Amount__c = 100,
                FinServ__PostDate__c = DateTime.now(),
                FinServ__TransactionType__c = 'Credit',
                FinServ__TransactionSubtype__c = 'Fee Waiver',
                Source_Type__c = 'ACH',
                FinServ__FinancialAccount__c = tempcashaccount.Id,
                FinServ__TransactionStatus__c = 'Posted',
                FinServ__TransactionDate__c = DateTime.now()); 
                ListFeewaiver.add(tempFin_txn1);
        
        		FinServ__FinancialAccountTransaction__c tempFin_txn2 = new FinServ__FinancialAccountTransaction__c(
                FinServ__Amount__c = 200,
                FinServ__PostDate__c = DateTime.now(),
                FinServ__TransactionType__c = 'Debit',
                FinServ__TransactionSubtype__c = 'Fee',
                Source_Type__c = 'ACH',
                FinServ__FinancialAccount__c = tempcashaccount.Id,
                FinServ__TransactionStatus__c = 'Posted',
                FinServ__TransactionDate__c = DateTime.now()); 
                ListFeewaiver.add(tempFin_txn2);
      			insert ListFeewaiver;
 
        
      	Test.startTest();
         system.debug('Test Started'); 
        FinTxnHandler testinst = new FinTxnHandler();
        testinst.onafterInsertRollupBalance(ListRollup);
        testinst.onafterInsertRollupBalance(ListRollup1);
        testinst.FeewaiverValid(ListFeewaiver);
        Test.stopTest();
        
      system.debug('Test Completed');  
    }

}