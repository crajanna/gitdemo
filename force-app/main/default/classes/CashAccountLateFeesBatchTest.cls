@isTest
public class CashAccountLateFeesBatchTest {
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
        tempcashaccount.FinServ__CashBalance__c = -200000;
        tempcashaccount.RecordTypeId   = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
        tempcashaccount.FinServ__FinancialAccountType__c = 'Cash Account';
     	cashAccnt.add(tempcashaccount);
   		 }
        insert cashAccnt;
      
  		//start test 
        Test.startTest();
        CashAccountLateFeesBatch pwt = new CashAccountLateFeesBatch();
        Id batchId = Database.executeBatch(pwt);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
     
        System.assertEquals(20, [select count() from FinServ__FinancialAccountTransaction__c where FinServ__FinancialAccount__c =: cashAccnt and FinServ__TransactionSubtype__c = 'Fee' and Sub_Type_Description__c = 'Late Fee']);
    
  }
}