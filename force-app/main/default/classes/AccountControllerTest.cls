@isTest
public with sharing class AccountControllerTest {
    
    public static String studentInterest = '{"Favorite_Subject__c": "favorite Subject", "Interests__c": "Interests", "Organization__c": "Organization", "Goals__c": "Goals"}';
    public static String profileData = '{"file": "file", "fileName": "fileName", "description": "description"}';
    public static String resVerificationData = '{"file": "file", "fileName": "fileName", "docType": "docType"}';
    
    @TestSetup
    public static void makeData()
    {	
        RecordType recTypeAcc = [SELECT Id FROM RecordType WHERE Name = 'Business' and SObjectType = 'Account'];
        Account newAccount1 = new Account(RecordTypeId=recTypeAcc.Id, Name = 'test test1', Email__c = 'test1@test.com', Phone = '8745147562', Website = 'www.google.com');
     	Account newAccount2 = new Account(RecordTypeId=recTypeAcc.Id, Name = 'test test2', Email__c = 'test2@test.com', Phone = '8745147562', Website = 'www.google.com');
    	List<Account> lstAccount = new List<Account>{newAccount1, newAccount2};
        insert lstAccount;
        Contact newContact = new Contact(FirstName='test',LastName='test',Email='test@test.com', AccountId = newAccount1.Id, Phone = '8745147562', Birthdate = Date.today(), OtherStreet = '425 Abc', OtherCity = 'Dallas', OtherState = 'Florida', OtherPostalCode='457848', OtherCountry='United States', OtherStateCode='FL', OtherCountryCode='US');
        insert newContact;
        
        RecordType recTypeRole = [SELECT Id FROM RecordType WHERE Name = 'Account Role' and SObjectType = 'FinServ__ReciprocalRole__c'];
        FinServ__ReciprocalRole__c faccount = 
            new FinServ__ReciprocalRole__c(RecordTypeId=recTypeRole.Id, Name='Test Role', FinServ__InverseRole__c='Test Inverse Role');
        insert faccount;
      
    }
    
    @isTest
    public static void saveAccountDetailsTest(){
        Contact con = [SELECT Id, FirstName, LastName, MiddleName, Suffix, Email, phone, Birthdate, Race__c, SSN2__c, FinServ__Gender__c, 
                     OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherStateCode, OtherCountryCode, AccountId FROM Contact WHERE Email='test@test.com' LIMIT 1];
        Test.startTest();
      	AccountController.saveAccountDetails(con.clone(false,true), studentInterest, profileData, resVerificationData);
       	Test.stopTest();
    } 
    
    @isTest
    public static void getAccountInfoTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
      	AccountController.getAccountInfo(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void createAccountAccountRelationShipTest(){
        List<Account> lstAcc = [SELECT Id FROM Account];
        //Id portalUserId = CreatePortalUserController.createPortalUser('firstName', 'lastName', 'email@email.com', 'businessName', 'true');
        //User u = [SELECT Id, AccountId FROM User WHERE Id = :portalUserId LIMIT 1];
        User u = new User(Id = UserInfo.getUserId());

        Test.startTest();
        system.RunAs(u){
            AccountController.createAccountAccountRelationShip(lstAcc[0].Id, lstAcc[1].Id, 'Test Role');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getAccountRelationShipDetailsTest(){
       	List<Account> lstAcc = [SELECT Id FROM Account];
        User u = new User(Id = UserInfo.getUserId());
        Test.startTest();
        system.RunAs(u){
            AccountController.createAccountAccountRelationShip(lstAcc[0].Id, lstAcc[1].Id, 'Test Role');
            List<AccountController.AccountRelationshipWrapper> lstARWrapper = AccountController.getAccountRelationShipDetails(lstAcc[1].Id, 'Test Role');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getAccountIdTest(){
        Id accountId;
        Id portalUserId = CreatePortalUserController.createPortalUser('firstName', 'lastName', 'email@email.com', 'businessName', 'true');
        User u = [SELECT Id FROM User WHERE Id = :portalUserId LIMIT 1];

        Test.startTest();
        system.RunAs(u){
            accountId = AccountController.getAccountId(u.Id);
        }
        Test.stopTest();

        Id portalUserAccountId = [SELECT AccountId FROM User WHERE Id = :portalUserId].AccountId;
        
        System.debug('accountId =>'+accountId);
        System.debug('portalUserAccountId =>'+portalUserAccountId);
        System.assertEquals(accountId == portalUserAccountId, true);
    }
}