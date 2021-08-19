@isTest
public class PartialWithdrawalTest {
    @isTest
  public static void testbatch() {
        	    //create new account
  		Account a  = new Account();  
        a.FirstName = 'TestFirsts';
        a.LastName = 'testlastn';
        a.RecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']; 
        insert a;
        a = [Select OwnerID, Owner.ID From Account where ID = :a.id];
        //create temp cash account
         list<FinServ__FinancialAccount__c> cashAccnt = new List<FinServ__FinancialAccount__c>();
        
    	for(integer i=0;i<20;i++)
   		 {
 
        FinServ__FinancialAccount__c tempcashaccount = new FinServ__FinancialAccount__c();
        tempcashaccount.FinServ__PrimaryOwner__c = a.id;
        tempcashaccount.Name = 'Test Cash Account for apex Testing';
        tempcashaccount.FinServ__Status__c = 'Active'; 
        tempcashaccount.RecordTypeId   = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
        tempcashaccount.FinServ__FinancialAccountType__c = 'Cash Account';
     	cashAccnt.add(tempcashaccount);
   		 }
        insert cashAccnt;
      
      //create bank account
        List<FinServ__FinancialAccount__c> bankaccount = new List<FinServ__FinancialAccount__c>();
         for(integer i=0;i<20;i++)
   		 {
 
        FinServ__FinancialAccount__c tempbankaccount = new FinServ__FinancialAccount__c();
        tempbankaccount.FinServ__PrimaryOwner__c = a.id;
        tempbankaccount.Name = 'bank account'+i;
        tempbankaccount.FinServ__Status__c = 'Active';   
        tempbankaccount.RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('BankingAccount').getRecordTypeId();
        tempbankaccount.FinServ__FinancialAccountType__c = 'Cash Account';
     	bankaccount.add(tempbankaccount);
   		 }
        insert bankaccount;
 
        //insert withdrawal record 
        List<Transfer_Fund__c> transfer = new List<Transfer_Fund__c>();
        for(Integer i =0;i<20;i++)
        {
             	transfer_fund__c new_transferFund = new Transfer_Fund__c();
            	new_transferFund.Financial_Account_Cash__c = cashAccnt[i].id;
            	new_transferFund.Source_Type__c = 'ACH';
                new_transferFund.Financial_Institution__c = bankaccount[i].id;
           		new_transferFund.RecordTypeId = Schema.SObjectType.transfer_fund__c.getRecordTypeInfosByName().get('Withdrawal').getRecordTypeId();
               	new_transferFund.Transfer_Amount__c = 100;
                new_transferFund.Status__c = 'Queued';
                new_transferFund.Frequency__c = 'One-Time';
                new_transferFund.Start_Date__c = Date.today();
                new_transferFund.Full_Withdrawal__c = false;
                new_transferFund.Withdrawal_Source__c = null;
            	transfer.add(new_transferFund);
           
        }
      insert transfer;
      system.debug('total transfer record created' + transfer.size());
  		//start test 
        Test.startTest();
        PartialWithdrawalBatchJob pwt = new PartialWithdrawalBatchJob();
        Id batchId = Database.executeBatch(pwt);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
     
        System.assertEquals(20, [select count() from transfer_fund__c where id =: transfer and status__c = 'Complete']);
    
  }
}