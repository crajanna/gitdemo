public without sharing class ResourceController {

    @AuraEnabled
    public static String uploadResourceToRecord(String accountId, string file, string fileName, String description){ 

        String theUrl;
        List<ContentDocumentLink> lstCdl;
        List<ContentDocument> lstCd = new List<ContentDocument>();
        
        try{  

            lstCdl = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :accountId AND ContentDocument.Description = :description];

            if(lstCdl != null && lstCdl.size()>0){
                for (ContentDocumentLink eachCdl : lstCdl){
                    lstCd.add(new ContentDocument(Id = eachCdl.ContentDocumentId));
                }
                delete lstCd;
            }

            String base64File = EncodingUtil.urlDecode(file, 'UTF-8');     
            ContentVersion contentVersionRec = new ContentVersion();  
            contentVersionRec.Title = fileName;  
            contentVersionRec.Description = description; 
            contentVersionRec.PathOnClient = '/' + fileName;  
            contentVersionRec.FirstPublishLocationId = accountId;  
            contentVersionRec.VersionData = EncodingUtil.base64Decode(base64File);  
            contentVersionRec.IsMajorVersion = true;  
            Insert contentVersionRec;  

            ContentDistribution cDist = new ContentDistribution();
            cDist.Name = 'Test';
            cDist.ContentVersionId = contentVersionRec.Id;
            cDist.PreferencesAllowViewInBrowser= true;
            cDist.PreferencesLinkLatestVersion=true;
            cDist.PreferencesNotifyOnVisit=false;
            cDist.PreferencesPasswordRequired=false;
            cDist.PreferencesAllowOriginalDownload= true;
            insert cDist;

            String baseDomain = URL.getOrgDomainUrl().toExternalForm();
            baseDomain = baseDomain.substringBefore('.') + '--c.documentforce.com';
            cDist = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id =:cDist.Id LIMIT 1];
            String originalUrl = String.valueOf(cDist.DistributionPublicUrl);
            String cDistParam = originalUrl.substring(originalUrl.indexOf('/a/'));

            ContentVersion cvd = [SELECT ContentBodyId, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionRec.Id LIMIT 1];

            theUrl = baseDomain + '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg' +
                     '&versionId=' + contentVersionRec.Id + '&operationContext=DELIVERY&contentId=' + cvd.ContentBodyId +
                     '&page=0&d=' + cDistParam + '&oid=' +  UserInfo.getOrganizationId() + '&dpt=null&viewId=';

            return theUrl;

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String findResourceByRecord(String recordId, String description){  
    	 return findResourceByRecord(recordId, description, null);
    }
    @AuraEnabled(cacheable=true)
    public static String findResourceByRecord(String recordId, String description, String randomNumber){ 
        String theUrl = '';
        
        try{  
            List<ContentDocumentLink> lstCdl;
            List<ContentVersion> lstCVersion;
            List<ContentDistribution> lstCDist;


            lstCdl = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.Description = :description];

            if(lstCdl != null && lstCdl.size()>0){
                lstCVersion = [SELECT Id, VersionData, ContentBodyId, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = : lstCdl[0].ContentDocumentId AND IsLatest = true];
            

                if(lstCVersion != null && lstCVersion.size()>0){
                    String contentVersionId =  lstCVersion[0].Id;
                    lstCDist = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId =:contentVersionId LIMIT 1];

                    if(lstCDist != null && lstCDist.size()>0){
                        String baseDomain = URL.getOrgDomainUrl().toExternalForm();
                        baseDomain = baseDomain.substringBefore('.') + '--c.documentforce.com';
                        String originalUrl = String.valueOf(lstCDist[0].DistributionPublicUrl);
                        String cDistParam = originalUrl.substring(originalUrl.indexOf('/a/'));


                        theUrl = baseDomain + '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg' +
                                '&versionId=' + contentVersionId + '&operationContext=DELIVERY&contentId=' + lstCVersion[0].ContentBodyId +
                                '&page=0&d=' + cDistParam + '&oid=' +  UserInfo.getOrganizationId() + '&dpt=null&viewId=';
                    }
                }
            }

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('Image url..'+theUrl);
        return theUrl;
    }
}