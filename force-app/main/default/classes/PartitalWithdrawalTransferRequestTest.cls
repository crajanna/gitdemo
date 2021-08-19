@isTest
public class PartitalWithdrawalTransferRequestTest {
    @isTest
  public static void testbatch() {
        string cashaccountId = '';
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
        cashaccountId = tempcashaccount.Id;
          //create temp Investment account
        FinServ__FinancialAccount__c tempInvestaccount = new FinServ__FinancialAccount__c();
        tempInvestaccount.FinServ__PrimaryOwner__c = a.id;
      //  tempInvestaccount.Name = 'Test Investment Account for apex Testing';
        tempInvestaccount.FinServ__Status__c = 'Active';
        tempInvestaccount.RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId();	
        tempInvestaccount.FinServ__FinancialAccountType__c = 'Regular';
        insert tempInvestaccount;
      system.debug('cash account id' + cashaccountId);
      system.debug('investment account id'+ tempInvestaccount.Id);
        
        //insert withdrawal record 
              List<Transfer_Fund__c> transfer = new List<Transfer_Fund__c>();
        for(Integer i =0;i<20;i++)
        {
             transfer_fund__c new_transferFund = new Transfer_Fund__c();
            	new_transferFund.Financial_Account_Cash__c = cashaccountId;
               // new_transferFund.RecordTypeId = '012P0000002232jIAA';
            	new_transferFund.RecordTypeId = Schema.SObjectType.transfer_fund__c.getRecordTypeInfosByName().get('Withdrawal').getRecordTypeId();
                new_transferFund.Transfer_Amount__c = 100;
                new_transferFund.Status__c = 'Queued';
                new_transferFund.Frequency__c = 'One-Time';
                new_transferFund.Start_Date__c = Date.today();
                new_transferFund.Full_Withdrawal__c = false;
                new_transferFund.Withdrawal_Source__c = tempInvestaccount.Id;
         		 // add invetment account
                new_transferFund.Financial_Account_Investment__c = tempInvestaccount.Id;
            transfer.add(new_transferFund);
           
        }
      
         insert transfer;
         
      system.debug('total transfer record created' + transfer.size());
  //start test 
        Test.startTest();
        PartitalWithdrawalTransferRequestBatch pwt = new PartitalWithdrawalTransferRequestBatch();
        Id batchId = Database.executeBatch(pwt);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
     
        System.assertEquals(20, [select count() from transfer_fund__c where id =: transfer and status__c = 'Complete']);
      //Status__c = 'Complete' and 
   
  }
}