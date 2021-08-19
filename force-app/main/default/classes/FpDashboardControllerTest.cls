@isTest
public class FpDashboardControllerTest {
    // private Account newAccount;
    // private Contact newContact;
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
        ContentDistribution cdist = new ContentDistribution(ContentVersionId=cvid, PreferencesAllowViewInBrowser=true, PreferencesLinkLatestVersion=true, PreferencesNotifyOnVisit=false, PreferencesPasswordRequired=false, PreferencesAllowOriginalDownload= true);
        contentdocument cd = new contentdocument();
        cd = [select id from contentdocument where LatestPublishedVersionId = :cvid limit 1];  
        contentdocumentlink cdl = new contentdocumentlink(ContentDocumentId=cd.id, LinkedEntityId=newContact.AccountId, ShareType='I', Visibility='AllUsers');  
        insert cdl;
    }

  @isTest
  public static void updateContactRoleTest() {
    List<Contact> query = [SELECT Id, AccountId FROM Contact];

    Test.startTest();
    String returned = FpDashboardController.updateContactRole(
        query[0].AccountId,
        query[0].Id,
        'Registered Agent'
    );
    Test.stopTest();


  }

  @isTest
  public static void uploadLogoToRecordTest() {
    List<Contact> query = [SELECT Id, AccountId FROM Contact];

    Test.startTest();
  	FpDashboardController dashCntrl = new FpDashboardController();
   	String returned = FpDashboardController.uploadLogoToRecord(
        query[0].AccountId,
        'AccountLogo',
        'FileName.jpeg'
  	);
    
    Test.stopTest();
  }

  @isTest
  public static void findImageByRecordTest(){
    List<Account> query = [SELECT Id FROM Account];

    Test.startTest();
    String returned1 = FpDashboardController.uploadLogoToRecord(
        query[0].Id,
        'AccountLogo',
        'FileName.jpeg'
  	);
    String returned2 = FpDashboardController.findImageByRecord(
        query[0].Id, 'randomNum', 'Company Logo'
    );
    String returned3 = ResourceController.findResourceByRecord(
        query[0].Id, 'Company Logo'
    );
    String returned4 = ResourceController.findResourceByRecord(
        query[0].Id, 'Company Logo', 'randomNum'
    );
    Test.stopTest();
  }

  @isTest
  public static void getStateOptionsListTest(){
    Test.startTest();
    Map < String, String > returned = FpDashboardController.getStateOptionsList();
    Test.stopTest();
  }
    
  @isTest
  public static void getAccountContactDataTest(){
    Test.startTest();
    List<Account> query = [SELECT Id FROM Account];
    FpDashboardController.AccountContactWrapper accConWrp = new FpDashboardController.AccountContactWrapper();
    List<FpDashboardController.AccountContactWrapper> lstAccConWrp = FpDashboardController.getAccountContactData(query[0].id, '123');
    //List<FpDashboardController.AccountContactWrapper> lstAccConWrp = FpDashboardController.getAccountContactData(query[0].id);
    Test.stopTest();
  }
    
  @isTest
  public static void getTaskListTest(){
    Test.startTest();
    List<Account> query = [SELECT Id FROM Account];
    List<Task> lstTasks = FpDashboardController.getTaskList(query[0].id, '123');
    Test.stopTest();
  }

  @isTest
    public static void getDocumentsOnRecord(){
      List<Account> query = [SELECT Id FROM Account];
      List<String> lstCategory = new List<String>();
      lstCategory.add('Company');
      lstCategory.add('Logo');
      Test.startTest();
      List<FpDashboardController.ContentDocumentWrapper> lstConDocLink = FpDashboardController.getDocumentsOnRecord(
        query[0].Id,
        lstCategory
      );
      Test.stopTest();
    }
}