@isTest
public with sharing class CreatePersonAccountTest {

    @TestSetup
    public static void makeData()
    {
        Account newAccount = new Account(Name = 'test test', Email__c = 'test@test.com', Phone = '8745147562', Website = 'www.google.com');
        insert newAccount;
        Contact newContact = new Contact(FirstName='test',LastName='test',Email='test@test.com', AccountId = newAccount.Id);
        insert newContact;
        
        
        contentversion cv = new contentversion(Title='Company Logo', pathOnclient='/AccountLogo.jpeg', versionData=Blob.valueOf('AccountLogo') );
        insert cv;
        Id cvid = cv.id;
        ContentDistribution cdist = new ContentDistribution(Name='Company Logo',ContentVersionId=cvid, PreferencesAllowViewInBrowser=true, PreferencesLinkLatestVersion=true, PreferencesNotifyOnVisit=false, PreferencesPasswordRequired=false, PreferencesAllowOriginalDownload= true);
        insert cdist;
        contentdocument cd = new contentdocument();
        cd = [select id from contentdocument where LatestPublishedVersionId = :cvid limit 1];  
        contentdocumentlink cdl = new contentdocumentlink(ContentDocumentId=cd.id, LinkedEntityId=newContact.AccountId, ShareType='I', Visibility='AllUsers');  
        insert cdl;
    }

    @isTest
    public static void saveContactRecordTest() {
      Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];
  
      Test.startTest();
      CreatePersonAccount.saveContactRecord(con);
      Test.stopTest();
    }


    @isTest
    public static void savePersonAccountTest() {
      Contact con = [SELECT Id, FirstName, LastName, MiddleName, Suffix, Birthdate, Race__c, SSN2__c, FinServ__Gender__c,
                     OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherStateCode, OtherCountryCode, AccountId FROM Contact LIMIT 1];
  
      Test.startTest();
      CreatePersonAccount.savePersonAccount(con);
      Test.stopTest();
    }

	@isTest
    public static void savePersonAccountWithFileTest(){
        Contact con = [SELECT Id, FirstName, LastName, MiddleName, Suffix, Birthdate, Race__c, SSN2__c, FinServ__Gender__c,
                     OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherStateCode, OtherCountryCode, AccountId FROM Contact LIMIT 1];
        Test.startTest();
      	CreatePersonAccount.savePersonAccountWithFile(con, 'image', 'profile', 'person profile picture', '.pdf', 'testpdf', 'abc');
       	Test.stopTest();
    }
    
    @isTest
    public static void findLogoTest(){
        contentversion conVer = [SELECT Id FROM contentversion WHERE Title='Company Logo' LIMIT 1];
        Test.startTest();
      	CreatePersonAccount.findLogo(conVer.Id);
       	Test.stopTest();
    }
	
    @isTest
    public static void getAccountDetailsTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
      	CreatePersonAccount.getAccountDetails(acc.Id);
        Test.stopTest();
    }
        
    @isTest
    public static void getAccountAddressTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
      	CreatePersonAccount.getAccountAddress(acc.Id);
        Test.stopTest();
    }
        
    @isTest
    public static void getCountryOptionsListTest(){
        Test.startTest();
      	CreatePersonAccount.getCountryOptionsList();
        Test.stopTest();
    }
    
    @isTest
    public static void getStateOptionsListTest(){
        Test.startTest();
      	CreatePersonAccount.getStateOptionsList();
        Test.stopTest();
    }
}