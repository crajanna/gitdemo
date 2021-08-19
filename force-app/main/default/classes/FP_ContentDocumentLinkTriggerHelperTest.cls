@isTest
public class FP_ContentDocumentLinkTriggerHelperTest {

    @TestSetup
    public static void makeData()
    {
        Account newAccount = new Account(Name = 'test test', Email__c = 'test@test.com', Phone = '8745147562', Website = 'www.google.com');
        insert newAccount;
        Contact newContact = new Contact(FirstName='test',LastName='test',Email='test@test.com', AccountId = newAccount.Id);
        insert newContact;

        contentversion cv1 = new contentversion(Title='Invoice', pathOnclient='/Invoice.pdf', versionData=Blob.valueOf('Invoice') );
        contentversion cv2 = new contentversion(Title='Receipt', pathOnclient='/Receipt.pdf', versionData=Blob.valueOf('Receipt') );
        List<contentversion> lstCv = new List<contentversion>{cv1, cv2};
        insert lstCv;
        
        //ContentDistribution cdist = new ContentDistribution(ContentVersionId=cvid, PreferencesAllowViewInBrowser=true, PreferencesLinkLatestVersion=true, PreferencesNotifyOnVisit=false, PreferencesPasswordRequired=false, PreferencesAllowOriginalDownload= true);
        //contentdocument cd = new contentdocument();
    }
    
    @isTest
  	public static void updateContactRoleTest() {
        List<contentdocument> lstCd = [select id from contentdocument];  
        List<Account> lstAcc = [select id from Account]; 
        List<Contact> lstCon = [select id from Contact]; 
    
        Test.startTest();
        contentdocumentlink cdl1 = new contentdocumentlink(ContentDocumentId=lstCd[0].id, LinkedEntityId=lstAcc[0].Id, ShareType='I', Visibility='InternalUsers'); 
        contentdocumentlink cdl2 = new contentdocumentlink(ContentDocumentId=lstCd[1].id, LinkedEntityId=lstCon[0].Id, ShareType='I', Visibility='InternalUsers'); 
        List<contentdocumentlink> lstCdl = new List<contentdocumentlink>{cdl1, cdl2};
        insert lstCdl;
        Test.stopTest();
  }
}