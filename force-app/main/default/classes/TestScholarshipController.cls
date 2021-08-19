@isTest
public class TestScholarshipController {

    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @TestSetup
    public static void makeData(){
        String value = '13';
       	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        String userId = CreatePortalUserController.createPortalUser('firstName '+value, 'lastName '+value, 'email'+value+'@email.com', 'businessName'+value, 'true');
        System.debug('userId : '+userId);
        Account newAccount = new Account(Name = 'test test123', Email__c = 'test@test.com', Phone = '8745147562', Website = 'www.google.com', OwnerId=userId);
        insert newAccount;   
        System.debug('account -> Name -> '+newAccount.Name);     
		
        Id recTypeId = Schema.getGlobalDescribe().get('Product2').getDescribe().getRecordTypeInfosByName().get('Scholarship').getRecordTypeId();
        
        Product2  p2 = new Product2();
		p2.Name = 'FirstChoice';
        p2.spotlight__c = false;
        p2.RecordTypeId = recTypeId;
        p2.Product_Type__c='Scholarship Program';
        p2.Start_Date__c = Date.TODAY().addDays(-1);
        p2.Sort__c = 1;
		insert p2;

    }
    
        /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    /*@isTest
    public static void testGetUserAccount(){
       User user =  [SELECT Id, FirstName, LastName, Name FROM User  LIMIT 1];
       System.debug('Id : '+user.Id+' --- LastName : '+user.LastName);
       Test.startTest();
       String con = ScholarshipController.getUserAccount(user.Id);   
       Test.stopTest();
       System.debug('Con : '+con);
    }*/
    
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetScholarshipApplicationDetails(){
       	//Scholarship_Application_Setting__mdt sas = [SELECT Id, DeveloperName from Scholarship_Application_Setting__mdt LIMIT 1];
        //sas.DeveloperName = 'Black_History_Month_Scholarship';
        Test.startTest();
       	//Scholarship_Application_Setting__mdt conList = ScholarshipController.getScholarshipApplicationDetails(product.Id);   
       	Test.stopTest();
    }
}