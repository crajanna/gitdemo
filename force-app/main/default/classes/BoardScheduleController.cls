public without sharing class BoardScheduleController {

    @AuraEnabled(cacheable=false)
	public static List<BoardScheduleController.BoardScheduleWrapper> getBoardSchedules(){
    	String  BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
        String recordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByName().get('Board Portal').getRecordTypeId();
        Integer year = System.Today().year();
        String quarterStr = 'First Quarter '+year+'%,Second Quarter '+year+'%,Third Quarter '+year+'%,Fourth Quarter '+year+'%';
        
        String[] quarterArray = quarterStr.split(',');
        Date currentYear = date.parse('01/01/'+year);
        
		List<Event> eventsList = [SELECT Id, Subject, ActivityDate, ActivityDateTime, Type, Location  FROM Event where Subject like :quarterArray order by ActivityDate desc];
		Map<String, BoardScheduleController.BoardScheduleWrapper> boardMap = new Map<String, BoardScheduleController.BoardScheduleWrapper>();
		
        if(eventsList.size() > 0){
        	List<BoardScheduleController.BoardScheduleWrapper> bswList = new List<BoardScheduleController.BoardScheduleWrapper>();
            
            String eventSubject = null;
            for(Event event: eventsList){
                BoardScheduleWrapper bswObj = null;
                if(boardMap.get(event.Subject) != null){
                   	bswObj = boardMap.get(event.Subject);
                }else{
                   	bswObj = new BoardScheduleWrapper();
            	   	bswObj.eventId	=	event.Id;
                	bswObj.eventSubject =	event.Subject;
                    bswObj.eventLocation =	event.Location;
                }
                
                List<ContentDocumentLink> docLinkList = [SELECT ContentDocumentId,  LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: event.Id];
               	if(event.type == 'ABLE United'){
                   	bswObj.ableUnitedDocsWrapper = getBoardDocsList(docLinkList, event);
        		}else if(event.type == 'Florida Prepaid College Board'){
                   bswObj.floridaPrepaidCollegeBoardDocsWrapper = getBoardDocsList(docLinkList, event) ;   
        		}else if(event.type == 'Florida Prepaid College Foundation'){
                    bswObj.floridaPrepaidCollegeFoundationBoardDocsWrapper = getBoardDocsList(docLinkList, event) ;   
                }
         
                boardMap.put(event.Subject, bswObj);
           	}
        }
        return boardMap.values();
    }
    
    public static BoardDocsWrapper getBoardDocsList(List<ContentDocumentLink> docLinkList, Event event){
        String  BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
        BoardDocsWrapper boardDocsWrapper = new BoardDocsWrapper();
        String dt = event.ActivityDateTime.format('MMMMM dd, yyyy hh:mm:ss a');        
        String[] strArray = dt.split(' ');
        String[] time1 = strArray[3].split(':');
        boardDocsWrapper.eventTime = time1[0]+':'+time1[1]+' '+strArray[4];
        boardDocsWrapper.eventDate = strArray[0]+' '+strArray[1]+' '+strArray[2];
        if(docLinkList.size() > 0){
            for(ContentDocumentLink cdocLink : docLinkList){
            	ContentVersion cdoc = [SELECT Id, Title, ContentSize, ContentDocumentId FROM ContentVersion where ContentDocumentId =: cdocLink.ContentDocumentId AND IsLatest = true AND FileExtension = 'pdf'];
                ContentDistribution contentDistribution = createContentDistributionLink(cdoc);
                if(cdoc.Title.contains('Board Meeting')){
                    boardDocsWrapper.boardDocURL = contentDistribution.ContentDownloadUrl;
                    boardDocsWrapper.boardDocSize =	cdoc.ContentSize/1024;
                }
                
                if(cdoc.Title.contains('Audit Committee')){
                    boardDocsWrapper.auditDocURL = contentDistribution.ContentDownloadUrl;
                    boardDocsWrapper.auditDocSize =	cdoc.ContentSize/1024;
                }
                
                if(cdoc.Title.contains('Investment Committee')){
                    boardDocsWrapper.investmentDocURL = contentDistribution.ContentDownloadUrl;
                    boardDocsWrapper.investmentDocSize =	cdoc.ContentSize/1024;
                }
            } //end-for loop
        }
        return boardDocsWrapper;
    }
    
    
    public static ContentDistribution createContentDistributionLink(ContentVersion contentVersion){
        
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        List<ContentDistribution> contentDistributionList2 = new List<ContentDistribution>();
        List<ContentDistribution> cList = [SELECT Id, ContentVersionId, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl,PdfDownloadUrl, ViewCount from ContentDistribution  where ContentVersionId = :contentVersion.Id ];	
        ContentDistribution contentDistribution;
        if(cList.size() == 0 ){
            contentDistribution = new ContentDistribution();
            contentDistribution.Name = contentVersion.Title;
            contentDistribution.ContentVersionId = contentVersion.Id;
            contentDistribution.PreferencesAllowViewInBrowser= true;
            contentDistribution.PreferencesLinkLatestVersion=true;
            contentDistribution.PreferencesNotifyOnVisit=false;
            contentDistribution.PreferencesPasswordRequired=false;
            contentDistribution.PreferencesAllowOriginalDownload= true; 
            insert contentDistribution;                   
     	}else{
            contentDistribution = cList[0];
      	}
    
        return contentDistribution;
    }
    
    public class BoardDocsWrapper{
    	
        @AuraEnabled
        public Double boardDocSize{get; set;}
        
        @AuraEnabled
        public String boardDocURL{get; set;}
        
        @AuraEnabled
        public String eventTime{get; set;}
        
        @AuraEnabled
        public String eventDate{get; set;}
        
        @AuraEnabled
        public Double auditDocSize{get; set;}
        
        @AuraEnabled
        public String auditDocURL{get; set;}
        
        @AuraEnabled
        public Double investmentDocSize{get; set;}
        
        @AuraEnabled
        public String investmentDocURL{get; set;}
        
    }
    
    public class BoardScheduleWrapper{
        
        @AuraEnabled
        public String eventId{get; set;}
        
        @AuraEnabled
        public String eventSubject{get; set;}
        
        @AuraEnabled
        public String eventType{get; set;} 
        
        @AuraEnabled
        public String eventLocation{get; set;}
       
        @AuraEnabled
        public BoardDocsWrapper ableUnitedDocsWrapper{get;set;}
        
        @AuraEnabled
        public BoardDocsWrapper floridaPrepaidCollegeFoundationBoardDocsWrapper{get;set;}
        
        @AuraEnabled
        public BoardDocsWrapper floridaPrepaidCollegeBoardDocsWrapper{get;set;}
        
    }//end of class
    
    @AuraEnabled(cacheable=true)
	public static List<Contact> getContactsList(String accountId){
    	return [SELECT Id, Name, Title FROM Contact where accountId =: accountId];
    }
}