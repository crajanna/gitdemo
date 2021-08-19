@isTest
public class FinancialHolding_CustomTrigger_Test {
    
    @isTest 
    public static void testHoldingTrigger()
    {
           //create new account
  		Account a  = new Account();  
        a.FirstName = 'TestHoldFirsts';
        a.LastName = 'testHoldlastn';
        a.RecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']; 
        insert a;
        a = [Select OwnerID, Owner.ID From Account where ID = :a.id];
        
        
          //create temp Investment account
      	FinServ__FinancialAccount__c tempInvestaccount = new FinServ__FinancialAccount__c();
        tempInvestaccount.FinServ__PrimaryOwner__c = a.id;
        tempInvestaccount.FinServ__Status__c = 'Active';
        tempInvestaccount.FinServ__Balance__c = 2000;
        tempInvestaccount.RecordTypeId =   Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId();
        tempInvestaccount.FinServ__FinancialAccountType__c = 'Regular';
     	insert tempInvestaccount;
        
        //create financial holding under investment account
         list<FinServ__FinancialHolding__c> list_holding  = new List<FinServ__FinancialHolding__c>();
        FinServ__FinancialHolding__c tempholding  = new FinServ__FinancialHolding__c();
        tempholding.FinServ__FinancialAccount__c = tempInvestaccount.id;
        tempholding.Name = 'Test Holding';
        tempholding.FinServ__MarketValue__c = 100;
        list_holding.add(tempholding);
        
        FinServ__FinancialHolding__c tempholding1  = new FinServ__FinancialHolding__c();
        tempholding1.FinServ__FinancialAccount__c = tempInvestaccount.id;
        tempholding1.Name = 'Test Holding1';
        tempholding1.FinServ__MarketValue__c = 1000;
        list_holding.add(tempholding1);
        
        insert list_holding;
        
        Test.startTest();
        FinancialHoldingHandler handler = new FinancialHoldingHandler();
        handler.updateTotalHoldingBalance(list_holding);
        Test.stopTest();
        system.debug('Test Completed');  
        
        
    }

}