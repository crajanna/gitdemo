@isTest
public class BoardContDocumentLinkTriggerHelperTest {
@TestSetup
    public static void makeData(){
        Event firstQrt = new Event();
        firstQrt.Type = 'ABLE United';
        firstQrt.Subject = 'First Quarter 2021';
        firstQrt.StartDateTime = System.today();
        firstQrt.EndDateTime = System.today()+5;
        firstQrt.ActivityDateTime = System.today();
        firstQrt.Location = 'Board Office, Tallahassee, Florida';
        //firstQrt.recordTypeId = '012P00000021ockIAA';
        insert firstQrt;

        ContentVersion cv1 = new ContentVersion(Title='Invoice', pathOnclient='/Invoice.pdf', versionData=Blob.valueOf('Invoice') );
        ContentVersion cv2 = new ContentVersion(Title='Receipt', pathOnclient='/Receipt.pdf', versionData=Blob.valueOf('Receipt') );
        
        List<ContentVersion> lstCv = new List<ContentVersion>{cv1, cv2};
        insert lstCv;
        
        //ContentDistribution cdist = new ContentDistribution(ContentVersionId=cvid, PreferencesAllowViewInBrowser=true, PreferencesLinkLatestVersion=true, PreferencesNotifyOnVisit=false, PreferencesPasswordRequired=false, PreferencesAllowOriginalDownload= true);
        //contentdocument cd = new contentdocument();
    }
    
    @isTest
  	public static void updateContactRoleTest() {
        List<ContentDocument> lstCd = [select id from ContentDocument];  
        List<Event> lstEvt = [select id from Event]; 
        List<Contact> lstCon = [select id from Contact]; 
    
        Test.startTest();
        ContentDocumentLink cdl1 = new ContentDocumentLink(ContentDocumentId=lstCd[0].id, LinkedEntityId=lstEvt[0].Id, ShareType='I', Visibility='InternalUsers'); 
        List<ContentDocumentLink> lstCdl = new List<ContentDocumentLink>{cdl1};
        insert lstCdl;
        Test.stopTest();
  }
}