@isTest
public class BoardDocsControllerTest {

    @TestSetup
    public static void makeData(){
        String recordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByName().get('Board Portal').getRecordTypeId();
        
        Account newAccount = new Account(Name = 'test test', Email__c = 'test@test.com', Phone = '8745147562', Website = 'www.google.com');
        insert newAccount;
        
		Contact newContact = new Contact(FirstName='test76',LastName='test76',Email='test76@test.com', AccountId = newAccount.Id);
        insert newContact;
        
        Event firstQrt = new Event();
        firstQrt.Type = 'ABLE United';
        firstQrt.Subject = 'First Quarter 2021';
        firstQrt.StartDateTime = System.today();
        firstQrt.EndDateTime = System.today()+5;
        firstQrt.ActivityDateTime = System.today();
        firstQrt.Location = 'Board Office, Tallahassee, Florida';
        firstQrt.recordTypeId = recordTypeId;
        insert firstQrt;
        
        BoardDocsController.BoardDocsWrapper bdObj = new BoardDocsController.BoardDocsWrapper();
        bdObj.eventId	=	firstQrt.Id;
        bdObj.eventSubject =	firstQrt.Subject;
        String dateStamp = firstQrt.ActivityDateTime.format('MMMMM dd, yyyy hh:mm:ss a');        
            String[] strArray = dateStamp.split(' ');
            String[] timeArray = strArray[3].split(':');
        if(dateStamp != null){
            bdObj.eventTime =	timeArray[0]+':'+timeArray[1]+' '+strArray[4];
            bdObj.eventDate =	strArray[0]+' '+strArray[1]+' '+strArray[2];     
        }else{
            bdObj.eventTime =	'';
            bdObj.eventDate =	''; 
        }
            
        bdObj.eventLocation =	firstQrt.Location;
        
        ContentVersion boardMeetingDoc = new ContentVersion(
            Title = 'Board Meeting',
            PathOnClient = 'BoardMeeting.pdf',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert boardMeetingDoc;
        ContentVersion boardContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :boardMeetingDoc.Id];
		ContentDocumentLink boardContentLink = new ContentDocumentLink();
        boardContentLink.LinkedEntityId=firstQrt.id;
        boardContentLink.ShareType= 'V';
        boardContentLink.ContentDocumentId=boardContent.ContentDocumentId;
        boardContentLink.Visibility = 'AllUsers'; 
        insert boardContentLink;
        
        
        ContentVersion auditMeetingDoc = new ContentVersion(
            Title = 'Audit Committee',
            PathOnClient = 'AuditMeeting.pdf',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert auditMeetingDoc;
        ContentVersion auditContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :auditMeetingDoc.Id];
		ContentDocumentLink auditContentLink = new ContentDocumentLink();
        auditContentLink.LinkedEntityId=firstQrt.id;
        auditContentLink.ShareType= 'V';
        auditContentLink.ContentDocumentId=auditContent.ContentDocumentId;
        auditContentLink.Visibility = 'AllUsers'; 
        insert auditContentLink;
        
        ContentVersion investmentMeetingDoc = new ContentVersion(
            Title = 'Investment Committee',
            PathOnClient = 'InvestmentMeeting.pdf',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert investmentMeetingDoc;
        ContentVersion investmentContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :investmentMeetingDoc.Id];
		ContentDocumentLink investmentContentLink = new ContentDocumentLink();
        investmentContentLink.LinkedEntityId=firstQrt.id;
        investmentContentLink.ShareType= 'V';
        investmentContentLink.ContentDocumentId=investmentContent.ContentDocumentId;
        investmentContentLink.Visibility = 'AllUsers'; 
        insert investmentContentLink;
        
       
        ContentVersion workshopMeetingDoc = new ContentVersion(
            Title = 'Workshop',
            PathOnClient = 'WorkshopMeeting.pdf',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert workshopMeetingDoc;
        ContentVersion workshopContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :workshopMeetingDoc.Id];
		ContentDocumentLink workshopContentLink = new ContentDocumentLink();
        workshopContentLink.LinkedEntityId=firstQrt.id;
        workshopContentLink.ShareType= 'V';
        workshopContentLink.ContentDocumentId=workshopContent.ContentDocumentId;
        workshopContentLink.Visibility = 'AllUsers'; 
        insert workshopContentLink;
        
        String  BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
        List<ContentDocument> docsList = [SELECT Id, Title, ContentSize, OwnerId FROM ContentDocument where FileExtension = 'pdf'];
        for(ContentDocument cdoc: docsList){
        	bdObj.contentDocId =	cdoc.Id;
            bdObj.contentDocTitle =	cdoc.Title; 
            
            if(cdoc.Title.contains('Board Meeting')){
                bdObj.boardDocURL = BASE_URL + '/sfc/servlet.shepherd/document/download/'+cdoc.Id;
                bdObj.boardDocSize =	cdoc.ContentSize/1024;
            }
            
            if(cdoc.Title.contains('Audit Committee')){
                bdObj.auditCommitteeDocURL = BASE_URL + '/sfc/servlet.shepherd/document/download/'+cdoc.Id;
                bdObj.auditCommitteeDocSize =	cdoc.ContentSize/1024;
            }
            
            if(cdoc.Title.contains('Investment Committee')){
                bdObj.investCommitteeDocURL = BASE_URL + '/sfc/servlet.shepherd/document/download/'+cdoc.Id;
                bdObj.investmentCommitteeDocSize =	cdoc.ContentSize/1024;
            }
            
            if(cdoc.Title.equals('Workshop')){
                bdObj.workshopsDocURL = BASE_URL + '/sfc/servlet.shepherd/document/download/'+cdoc.Id;
                bdObj.workshopsDocSize =	cdoc.ContentSize/1024;
            } 
        }
        
        
        Event secondQrt = new Event();
        secondQrt.Type = 'Florida Prepaid College Board';
        secondQrt.Subject = 'First Quarter 2021';
        secondQrt.StartDateTime = System.today();
        secondQrt.EndDateTime = System.today()+5;
        secondQrt.ActivityDateTime = System.today();
        secondQrt.Location = 'Board Office, Tallahassee, Florida';
        secondQrt.recordTypeId = recordTypeId;
        insert secondQrt;
        
        BoardDocsController.BoardDocsWrapper bdObj1 = new BoardDocsController.BoardDocsWrapper();
        bdObj1.eventId	=	secondQrt.Id;
        bdObj1.eventSubject =	secondQrt.Subject;
        String dateStamp1 = secondQrt.ActivityDateTime.format('MMMMM dd, yyyy hh:mm:ss a');        
            String[] strArray1 = dateStamp1.split(' ');
            String[] timeArray1 = strArray1[3].split(':');
        if(dateStamp1 != null){
            bdObj1.eventTime =	timeArray1[0]+':'+timeArray1[1]+' '+strArray1[4];
            bdObj1.eventDate =	strArray1[0]+' '+strArray1[1]+' '+strArray1[2];     
        }else{
            bdObj1.eventTime =	'';
            bdObj1.eventDate =	''; 
        }
            
        bdObj1.eventLocation =	secondQrt.Location;
        
      	Event thirdQrt = new Event();
        thirdQrt.Type = 'Florida Prepaid College Foundation';
        thirdQrt.Subject = 'First Quarter 2021';
        thirdQrt.StartDateTime = System.today();
        thirdQrt.EndDateTime = System.today()+5;
        thirdQrt.ActivityDateTime = System.today();
        thirdQrt.Location = 'Board Office, Tallahassee, Florida';
        thirdQrt.recordTypeId = recordTypeId;
        insert thirdQrt;
        
        BoardScheduleController.BoardScheduleWrapper bdObj11 = new BoardScheduleController.BoardScheduleWrapper();
        bdObj11.eventId	=	thirdQrt.Id;
        bdObj11.eventSubject =	thirdQrt.Subject;
        bdObj11.eventType = thirdQrt.Type;
        bdObj11.eventLocation =	thirdQrt.Location;        
    }
    
    @isTest
    public static void getMeetingMaterialsTest(){
        Test.startTest();
        BoardDocsController.getMeetingMaterials('ABLE United', 'ABLE Board');
        BoardDocsController.getMeetingMaterials('Florida Prepaid College Board', 'ABLE Board');
        BoardDocsController.getMeetingMaterials('Florida Prepaid College Foundation', 'ABLE Board');
        Test.stopTest();
    }
    
    @isTest
    public static void getBoardSchedulesTest(){
        Test.startTest();
        BoardScheduleController.getBoardSchedules();
        Test.stopTest();
    }
    
    @isTest
    public static void getContactsListTest(){
        Account acct = [Select Id from Account LIMIT 1];
        Test.startTest();
        BoardScheduleController.getContactsList(acct.Id);
        Test.stopTest();
    }
}