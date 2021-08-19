@isTest
public with sharing class ClaimTransferFundBatchTest {
    
    @isTest
    public static void Test() {
        
        //create new claims where condition are Status =\'Granted\' and ClaimType =\'School Invoice\'and AccountId != null and Educational_Institutes__c != null' 
        
        //create Policy Owner cash account account
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
        
        
        //create institution account
        
        Account ia  = new Account();  
        ia.Name = ' Test Educational Institutes';
        ia.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Educational_Institutes').getRecordTypeId();
        insert ia;
        
        
        FinServ__FinancialAccount__c tempcashaccount1 = new FinServ__FinancialAccount__c();
        tempcashaccount1.FinServ__PrimaryOwner__c = ia.id;
        tempcashaccount1.Name = 'Test Cash Account for apex Testing';
        tempcashaccount1.FinServ__Status__c = 'Active'; 
        tempcashaccount1.RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
        tempcashaccount1.FinServ__FinancialAccountType__c = 'Cash Account';
        
        insert tempcashaccount1;
        
        //create claim
        List<Claim> claim_List = new List<Claim>();
        for(integer i=0; i<10; i++)
        {
            claim temp_claim = new Claim();
            temp_claim.Status = 'Granted';
            temp_claim.ClaimType ='School Invoice';
            temp_claim.Name = 'Test'+i;
            temp_claim.AccountId = a.id;
            temp_claim.Educational_Institutes__c = ia.id;
            temp_claim.ApprovedAmount = 100;
            temp_claim.Claim_Amount__c = 100;
            claim_List.add(temp_claim);
        }
        insert claim_List;
        
        Test.startTest();
        ClaimTransferFundBatch fwt = new ClaimTransferFundBatch();
        Id batchId = Database.executeBatch(fwt);
        Test.stopTest();
    }
}