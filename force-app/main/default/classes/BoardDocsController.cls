public without sharing class BoardDocsController {
    @AuraEnabled(cacheable=false)
	public static List<BoardDocsWrapper> getMeetingMaterials(String boardType, String templateType){
        List<BoardDocsWrapper> boardDocsList = new List<BoardDocsWrapper>();
        String recordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByName().get('Board Portal').getRecordTypeId();
        List<Event> eventsList = [SELECT Id, StartDateTime, Subject, OwnerId, ActivityDate, ActivityDateTime, Location, IsAllDayEvent, RecordTypeId FROM Event where RecordTypeId =: recordTypeId and Type =: boardType order by ActivityDate desc LIMIT 12];
        String board = boardType;
        String  BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
         
        
        for(Event event: eventsList){
            List<ContentDocumentLink> docLinkList = [SELECT ContentDocumentId,  ShareType, Visibility, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: event.Id];
            String dateStamp = event.ActivityDateTime.format('MMMMM dd, yyyy hh:mm:ss a');        
            String[] strArray = dateStamp.split(' ');
            String[] timeArray = strArray[3].split(':');
            
            BoardDocsWrapper bdObj = new BoardDocsWrapper();
            bdObj.eventId	=	event.Id;
            bdObj.eventSubject =	event.Subject;
            if(dateStamp != null){
            	bdObj.eventTime =	timeArray[0]+':'+timeArray[1]+' '+strArray[4];
            	bdObj.eventDate =	strArray[0]+' '+strArray[1]+' '+strArray[2];     
            }
            
            bdObj.eventLocation =	event.Location;
            bdObj.boardType = templateType;
            
        	Map<Id, ContentDistribution> cdMap = new Map<Id, ContentDistribution>();
            if(docLinkList.size() > 0){
                for(ContentDocumentLink cdocLink: docLinkList){
                    List<ContentVersion> contentVersionList = [SELECT Id, ContentUrl, IsLatest, Title, ContentSize, SharingOption, SharingPrivacy, ContentDocumentId, VersionNumber, FileExtension FROM ContentVersion where ContentDocumentId =: cdocLink.ContentDocumentId AND IsLatest = true AND FileExtension = 'pdf' ];
                    Map<Id, ContentDistribution> cdMap1 = createContrentDistributionLink(contentVersionList, cdMap);
                    
                    if(contentVersionList.size() > 0){
            			for(ContentVersion cdoc: contentVersionList){
                            bdObj.contentDocId =	cdoc.ContentDocumentId;
                 			bdObj.contentDocTitle =	cdoc.Title;
                             if(cdoc.Title.contains('Board Meeting')){
                                bdObj.boardDocURL = cdMap1.get(cdoc.Id).ContentDownloadUrl;
                                bdObj.boardDocSize =	cdoc.ContentSize/1024;
                             }
                     
                             if(cdoc.Title.contains('Audit Committee')){
                                bdObj.auditCommitteeDocURL = cdMap1.get(cdoc.Id).ContentDownloadUrl;
                                bdObj.auditCommitteeDocSize =	cdoc.ContentSize/1024;
                             }
                             
                             if(cdoc.Title.contains('Investment Committee')){
                                bdObj.investCommitteeDocURL = cdMap1.get(cdoc.Id).ContentDownloadUrl;
                                bdObj.investmentCommitteeDocSize =	cdoc.ContentSize/1024;
                             }
                             
                             if(cdoc.Title.contains('Workshop')){
                                bdObj.workshopsDocURL = cdMap1.get(cdoc.Id).ContentDownloadUrl;
                                bdObj.workshopsDocSize =	cdoc.ContentSize/1024;
                             }
                            
                             if(cdoc.Title.contains('Steering Committee')){
                                bdObj.steeringCommitteeDocURL = cdMap1.get(cdoc.Id).ContentDownloadUrl;
                                bdObj.steeringCommitteeDocSize =	cdoc.ContentSize/1024;
                             }
                        }//end-for
                    }//end-if
               }//end-for
          	}//end-if
            boardDocsList.add(bdObj);
        }//end-for
        
        return boardDocsList;
    }

    public static Map<Id, ContentDistribution> createContrentDistributionLink(List<ContentVersion>  contentVersionList, Map<Id, ContentDistribution> cdMap){
        
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        List<ContentDistribution> contentDistributionList2 = new List<ContentDistribution>();
        for(ContentVersion conVersion: contentVersionList){
            List<ContentDistribution> cList = [SELECT Id, ContentVersionId, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl,PdfDownloadUrl, ViewCount from ContentDistribution  where ContentVersionId = :conVersion.Id ];	
            
            if(cList.size() == 0 ){
                ContentDistribution contentDistribution = new ContentDistribution();
                contentDistribution.Name = conVersion.Title;
                contentDistribution.ContentVersionId = conVersion.Id;
                contentDistribution.PreferencesAllowViewInBrowser= true;
                contentDistribution.PreferencesLinkLatestVersion=true;
                contentDistribution.PreferencesNotifyOnVisit=false;
                contentDistribution.PreferencesPasswordRequired=false;
                contentDistribution.PreferencesAllowOriginalDownload= true; 
                contentDistributionList.add(contentDistribution);                   
            }else{
                ContentDistribution c = cList[0];
                contentDistributionList2.add(cList[0]);
            }
        }
        
        if(contentDistributionList.size() > 0 ){
            insert contentDistributionList;
            for(ContentDistribution contentDistribution: contentDistributionList){
                cdMap.put(contentDistribution.ContentVersionId, contentDistribution);
            }
        }
        if(contentDistributionList2.size() > 0 ){
            for(ContentDistribution contentDistribution: contentDistributionList2){
                cdMap.put(contentDistribution.ContentVersionId, contentDistribution);
            }
        }
        return cdMap;
    }
    
    /**
     *Wrapper Class
     *Holding field values from Events and ContentDocument Objects  
	*/
    public class BoardDocsWrapper{
        
        @AuraEnabled
        public String eventId{get; set;}
        
        @AuraEnabled
        public String contentDocId{get; set;}
        
        @AuraEnabled
        public String eventSubject{get; set;}
        
        @AuraEnabled
        public String boardType{get; set;}
        
        @AuraEnabled
        public String contentDocTitle{get; set;}
        
        @AuraEnabled
        public String eventTime{get; set;}
        
        @AuraEnabled
        public String eventDate{get; set;}
        
        @AuraEnabled
        public String eventLocation{get; set;}
        
        @AuraEnabled
        public Double boardDocSize{get; set;}
        
        @AuraEnabled
        public Double auditCommitteeDocSize{get; set;}
        
        @AuraEnabled
        public Double investmentCommitteeDocSize{get; set;} 
        
        @AuraEnabled
        public Double workshopsDocSize{get; set;}
        
        @AuraEnabled
        public Double steeringCommitteeDocSize{get; set;}
        
        @AuraEnabled
        public String boardDocURL{get; set;} 
            
        @AuraEnabled
        public String steeringCommitteeDocURL{get; set;}
        
        @AuraEnabled
        public String auditCommitteeDocURL{get; set;}
        
        @AuraEnabled
        public String investCommitteeDocURL{get; set;}
        
        @AuraEnabled
        public String workshopsDocURL{get; set;}
        
        
   }
}