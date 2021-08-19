@isTest
public with sharing class ScholarshipControllerTest {

    @TestSetup
    public static void makedata(){
        RecordType recordTypeAcc = [SELECT Id FROM RecordType WHERE Name = 'Business' and SObjectType = 'Account'];
        Account acc = new Account(Name='TestAccount', RecordTypeId=recordTypeAcc.Id);
        insert acc;
        

        Product2 product = new Product2(Name='Black History Month Scholarship', Product_Type__c='Scholarship Application', Start_Date__c=Date.Today().addDays(-5), End_Date__c=Date.Today().addDays(5));
        insert product;

        RecordType recordTypeCont =  [SELECT Id FROM RecordType WHERE Name = 'Scholarship Application' and SObjectType = 'Contract'];
        
        Contract contract = new Contract(Name='TestContract', RecordTypeId=recordTypeCont.Id, AccountId=acc.Id, Product__c=product.Id);
        insert contract;
        
        Contentversion cv = new ContentVersion(Title='Company Logo', pathOnclient='/AccountLogo.jpeg', versionData=Blob.valueOf('AccountLogo') );
        insert cv;
        Id cvid = cv.id;
    }

    private static testMethod void testgetUserAccount(){
        Id accountId;
        Id portalUserId = CreatePortalUserController.createPortalUser('firstName', 'lastName', 'email@email.com', 'businessName', 'true');
        User u = new User(Id=portalUserId);

        Test.startTest();
        system.RunAs(u){
            accountId = ScholarshipController.getUserAccount(u.Id);
        }
        Test.stopTest();

        Id portalUserAccountId = [SELECT AccountId FROM User WHERE Id = :u.Id].AccountId;
        
        System.debug('accountId =>'+accountId);
        System.debug('portalUserAccountId =>'+portalUserAccountId);
        System.assertEquals(accountId == portalUserAccountId, true);
    }

    private static testMethod void getScholarshipApplicationDetailsTest(){
        Id prdId = [SELECT Id FROM Product2 LIMIT 1].Id;

        Test.startTest();
        Scholarship_Application_Setting__mdt schMdt = ScholarshipController.getScholarshipApplicationDetails(prdId);
        Test.stopTest();
    }

    private static testMethod void getScholarshipApplicationReviewTest(){
        Id portalUserId = CreatePortalUserController.createPortalUser('firstName', 'lastName', 'email@email.com', 'businessName', 'true');       
        Contract contract = [SELECT Id, OwnerId  FROM Contract LIMIT 1];
        contract.OwnerId = portalUserId;
        update contract;

        Test.startTest();
        List<ScholarshipController.WrapperClass> lstWrp = ScholarshipController.getScholarshipApplicationReview(portalUserId);
        Test.stopTest();
    }
    
  	private static testMethod void getSPChooseProgramsTest(){
        Id portalUserId = CreatePortalUserController.createPortalUser('firstName', 'lastName', 'email@email.com', 'businessName', 'true');       
        Contract contract = [SELECT Id, OwnerId  FROM Contract LIMIT 1];
        contract.OwnerId = portalUserId;
        update contract;

        Test.startTest();
        List<ScholarshipController.WrapperClass> lstWrp = ScholarshipController.getSPChoosePrograms();
        Test.stopTest();
    }
    
  	private static testMethod void FullPhotoUrlTest(){
        Id portalUserId = CreatePortalUserController.createPortalUser('firstName', 'lastName', 'email@email.com', 'businessName', 'true');       

        Test.startTest();
        String photo = ScholarshipController.findUserProfilePic(portalUserId);
        Test.stopTest();
    }
    
 	private static testMethod void uploadVideoToRecordTest(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;       

        Test.startTest();
        String photo = ScholarshipController.uploadVideoToRecord(accountId, 'file', 'filename');
        Test.stopTest();
    }
    
    private static testMethod void linkFileWithRecordTest(){
        Id cdId = [select id from contentdocument limit 1].Id; 
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;   
        
        Test.startTest();
        String cdlId = ScholarshipController.linkFileWithRecord(cdId, accountId);
        Test.stopTest();
    }
}