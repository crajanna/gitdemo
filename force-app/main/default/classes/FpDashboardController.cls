public without sharing class FpDashboardController {
    
    public FpDashboardController() {

    }

    /*@InvocableMethod(label='Create Tasks')
    public static List<String> createTasks(List<String> accId){
        Id templateVersionid = [SELECT Id FROM ActionPlanTemplateVersion ORDER BY CreatedDate DESC LIMIT 1].Id;
        if(accId != null && templateVersionid != null){
            ActionPlan actionPlan = new ActionPlan();
            actionPlan.ActionPlanTemplateVersionId = templateVersionid;
            actionPlan.ActionPlanType = 'Industries';
            actionPlan.Name = 'Foundation Portal Task';
            actionPlan.StartDate =  System.today() ;
            actionPlan.TargetId = accId[0];
            insert actionPlan;
        }
        return new List<String>();
    }*/
    
    @AuraEnabled(cacheable=true)
    public static List<AccountContactWrapper> getAccountContactData(String accountId, String randomNum) {
    //public static List<AccountContactWrapper> getAccountContactData(String accountId) {
       // accountId = '001P000001nnM6iIAE';
        List<AccountContactWrapper> listobj = new List<AccountContactWrapper>();    

        for(AccountContactRelation item: [SELECT ContactId, Roles
                                FROM AccountContactRelation
                                WHERE AccountId in (:accountId)]){
                AccountContactWrapper acObj = new AccountContactWrapper();
                acObj.contactId = item.ContactId;
                acObj.Roles = item.Roles;
                acObj.contactName = [SELECT Name FROM Contact WHERE Id =:item.ContactId].Name;                                                                      
                listobj.add(acObj);
            }
                                               
       return listobj;                

    }

    @AuraEnabled
    public static string updateContactRole (String accId, String conId, String role){
        AccountContactRelation accConRel;
        if(accId!=null && accId!='' && conId!=null && conId!=''){
            accConRel = [SELECT Id, Roles FROM AccountContactRelation WHERE AccountId =: accId AND ContactId =: conId];
            accConRel.Roles = role;
            try {
                update accConRel;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return accConRel.Id;
    }

    // @AuraEnabled
    // public static Account getDefaultAccountData(String recordId){
    //     Account getAccount;
    //     if(recordId!='' && recordId!=null){
    //         getAccount = [SELECT Id, Name, Email__c, Phone, Website, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Id=:recordId];
    //     }
    //     return getAccount;
    // }

    @AuraEnabled
    public static String uploadLogoToRecord(String accountId, string file, string fileName){ 
        String theUrl;
        List<ContentDocumentLink> lstCdl;
        List<ContentDocument> lstCd = new List<ContentDocument>();
        
        //try{  

            lstCdl = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :accountId AND ContentDocument.Description = 'Company Logo'];

            if(lstCdl != null && lstCdl.size()>0){
                for (ContentDocumentLink eachCdl : lstCdl){
                    lstCd.add(new ContentDocument(Id = eachCdl.ContentDocumentId));
                }
                delete lstCd;
            }

            String base64File = EncodingUtil.urlDecode(file, 'UTF-8');     
            ContentVersion contentVersionRec = new ContentVersion();  
            contentVersionRec.Title = fileName;  
            contentVersionRec.Description = 'Company Logo'; 
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

            system.debug('cvd '+cvd.ContentDocumentId);

            List<Account> lstAcc = [SELECT Id, Logo__c FROM Account WHERE Id = :accountId];

            if(lstAcc!=null && String.IsBlank(lstAcc[0].Logo__c)) {
                lstAcc[0].Logo__c = 'Logo Uploaded';
                update lstAcc;
            }

            /*ContentDocumentLink cd1 = new ContentDocumentLink();
            cd1.ContentDocumentId=cvd.ContentDocumentId;
            cd1.LinkedEntityId=accountId;
            cd1.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cd1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUse
            insert cd1;*/

            theUrl = baseDomain + '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg' +
                     '&versionId=' + contentVersionRec.Id + '&operationContext=DELIVERY&contentId=' + cvd.ContentBodyId +
                     '&page=0&d=' + cDistParam + '&oid=' +  UserInfo.getOrganizationId() + '&dpt=null&viewId=';


            return theUrl;

        //}catch(Exception e){
            //throw new AuraHandledException(e.getMessage());
        //}
    }

  
    @AuraEnabled(cacheable=true)
    public static String findImageByRecord(String recordId, String randomNum, String description){ 
        String theUrl = '';
        
        try{  
            List<ContentDocumentLink> lstCdl;
            List<ContentVersion> lstCVersion;
            List<ContentDistribution> lstCDist;


            lstCdl = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.Description =: description];
           // ContentDocumentLink cdl = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.Title = 'Logo' LIMIT 1];

            if(lstCdl != null && lstCdl.size()>0){
                lstCVersion = [SELECT Id, VersionData, ContentBodyId, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = : lstCdl[0].ContentDocumentId AND IsLatest = true];
            
            // Blob versiondataBlob = cVersion.VersionData;
            // String base64 = EncodingUtil.base64Encode(versiondataBlob);
            // String urlLogo = EncodingUtil.urlEncode(base64, 'UTF-8');
            // ContentDocumentLink cdLink = [SELECT ]; 

                if(lstCVersion != null && lstCVersion.size()>0){
                    String contentVersionId =  lstCVersion[0].Id;//'068P0000000wcezIAA';
                    lstCDist = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId =:contentVersionId LIMIT 1];

                    if(lstCDist != null && lstCDist.size()>0){
                        String baseDomain = URL.getOrgDomainUrl().toExternalForm();
                        baseDomain = baseDomain.substringBefore('.') + '--c.documentforce.com';
                        String originalUrl = String.valueOf(lstCDist[0].DistributionPublicUrl);
                        String cDistParam = originalUrl.substring(originalUrl.indexOf('/a/'));

                        // ContentVersion cvd = [SELECT ContentBodyId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];

                        theUrl = baseDomain + '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg' +
                                '&versionId=' + contentVersionId + '&operationContext=DELIVERY&contentId=' + lstCVersion[0].ContentBodyId +
                                '&page=0&d=' + cDistParam + '&oid=' +  UserInfo.getOrganizationId() + '&dpt=null&viewId=';
                    }
                }
            }

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return theUrl;
    }

    @AuraEnabled
    public static List<ContentDocumentWrapper> getDocumentsOnRecord(String recordId, List<String> lstCategory) {
        List<ContentDocumentWrapper> lstCDocWrp = new List<ContentDocumentWrapper>();
        List<ContentDocumentLink> lstCdl = new List<ContentDocumentLink>();
        Map<Id, ContentDocumentLink> mapCdocIdToCdl = new Map<Id, ContentDocumentLink>();
        List<Id> lstCdocId = new List<Id>();
        List<ContentDistribution> lstCdist = new List<ContentDistribution>();
        List<ContentDistribution> lstCdistTemp1 = new List<ContentDistribution>();
        List<ContentDistribution> lstCdistTemp2 = new List<ContentDistribution>();
        List<Id> lstCDIdTemp1 = new List<Id>();
        Map<Id, ContentDistribution> mapCdIdToCdl = new Map<Id, ContentDistribution>();
        List<ContentVersion> lstCVersion = new List<ContentVersion>();
        Map<Id, ContentVersion> mapCVersionIdToCVersion = new Map<Id, ContentVersion>();

        if(recordId != null){
            lstCdl = new List<ContentDocumentLink>();
            String strQuery = 'SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.Description, ContentDocument.FileType, ContentDocument.ContentModifiedDate, LinkedEntity.Name FROM ContentDocumentLink WHERE LinkedEntityId = \'' + recordId + '\'';

            Integer count = 0;
            if(lstCategory != null && lstCategory.size() > 0){
                strQuery = strQuery + ' AND (';
                for(String eachCategory : lstCategory) {
                    
                    if(count == 0) {
                        strQuery = strQuery + 'ContentDocument.Title LIKE \'%' + eachCategory + '%\'';
                    } else {
                        strQuery = strQuery + ' OR ContentDocument.Title LIKE \'%' + eachCategory + '%\'';
                    }  
                    count += 1;              
                }
                strQuery = strQuery + ')';
            }

            system.debug('strQuery::: ' + strQuery);
            lstCdl = Database.query(strQuery);
        }

        for (ContentDocumentLink eachCdl : lstCdl) {
            mapCdocIdToCdl.put(eachCdl.ContentDocumentId, eachCdl);
            lstCdocId.add(eachCdl.ContentDocumentId);
        }

        if(lstCdocId.size() > 0) {
            system.debug('One::: ');

            lstCVersion = [SELECT Id, VersionData, ContentBodyId, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :lstCdocId AND IsLatest = true];
            system.debug('One::: ');
            system.debug('One::: ');
            for (ContentVersion eachCVersion : lstCVersion) {
                mapCVersionIdToCVersion.put(eachCVersion.ContentDocumentId, eachCVersion);
                //lstCVersionId.add(eachCVersion.ContentDocumentId);
            }


            lstCdistTemp1 = [SELECT Id, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl, ViewCount from ContentDistribution  where ContentDocumentId = :lstCdocId];
            for (ContentDistribution eachCdist : lstCdistTemp1) {
                lstCDIdTemp1.add(eachCdist.ContentDocumentId);
            }

            system.debug('mapCVersionIdToCVersion::: ' + mapCVersionIdToCVersion);
            for (ContentDocumentLink eachCdl : lstCdl) {
                //ContentDocumentWrapper eachCDocWrp = new ContentDocumentWrapper();
               // ContentDocumentLink eachCdl = mapCdocIdToCdl.get(eachCdist.ContentDocumentId);

               system.debug('ONeTwo::: ' + eachCdl);
               if(!lstCDIdTemp1.contains(eachCdl.ContentDocumentId) && mapCVersionIdToCVersion.get(eachCdl.ContentDocumentId) != null){
                system.debug('Two::: ' + eachCdl);

                    ContentDistribution cDist = new ContentDistribution();
                    cDist.Name = 'Foundation Portal';
                    cDist.ContentVersionId = mapCVersionIdToCVersion.get(eachCdl.ContentDocumentId).Id;
                    cDist.PreferencesAllowViewInBrowser= true;
                    cDist.PreferencesLinkLatestVersion=true;
                    cDist.PreferencesNotifyOnVisit=false;
                    cDist.PreferencesPasswordRequired=false;
                    cDist.PreferencesAllowOriginalDownload= true;

                    lstCdistTemp2.add(cDist);
               }
            }
            insert lstCdistTemp2;
            system.debug('lstCdistTemp2 ' + lstCdistTemp2);

            lstCdist = [SELECT Id, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl, ViewCount from  ContentDistribution  where ContentDocumentId = :lstCdocId];
            for (ContentDistribution eachCdist : lstCdist) {
                ContentDocumentWrapper eachCDocWrp = new ContentDocumentWrapper();
                ContentDocumentLink eachCdl = mapCdocIdToCdl.get(eachCdist.ContentDocumentId);

                eachCDocWrp.docId = eachCdl.ContentDocumentId;
                eachCDocWrp.docTitle = eachCdl.ContentDocument.Title;
                eachCDocWrp.docSize = eachCdl.ContentDocument.Description;
                eachCDocWrp.docType = eachCdl.ContentDocument.FileType;
                eachCDocWrp.docModifiedDate = eachCdl.ContentDocument.ContentModifiedDate;
                eachCDocWrp.docViewCount = eachCdist.ViewCount;
                eachCDocWrp.downloadUrl = eachCdist.ContentDownloadUrl;
                eachCDocWrp.publicUrl = eachCdist.DistributionPublicUrl;

                lstCDocWrp.add(eachCDocWrp);
            }
        }

        return lstCDocWrp;
    }

    /*@AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getDocumentsOnRecord(String recordId, List<String> lstCategory) {
        List<ContentDocumentLink> lstCdl = new List<ContentDocumentLink>();

        if(recordId != null){
            lstCdl = new List<ContentDocumentLink>();
            String strQuery = 'SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.Description, ContentDocument.ContentModifiedDate, LinkedEntity.Name FROM ContentDocumentLink WHERE LinkedEntityId = \'' + recordId + '\'';

            Integer count = 0;
            if(lstCategory != null && lstCategory.size() > 0){
                strQuery = strQuery + ' AND (';
                for(String eachCategory : lstCategory) {
                    
                    if(count == 0) {
                        strQuery = strQuery + 'ContentDocument.Title LIKE \'%' + eachCategory + '%\'';
                    } else {
                        strQuery = strQuery + ' OR ContentDocument.Title LIKE \'%' + eachCategory + '%\'';
                    }  
                    count += 1;              
                }
                strQuery = strQuery + ')';
            }

            system.debug('strQuery::: ' + strQuery);
            lstCdl = Database.query(strQuery);
        }

        return lstCdl;
    }*/

    @AuraEnabled(cacheable=true)
    public static List<Task> getTaskList(String recordId, String randomNum) {
        List<Task> lstTask = new List<Task>();    

        if(recordId != null) {
            lstTask = [SELECT Id, Status, Subject, Description, CreatedDate, LastModifiedDate, WhatId FROM Task WHERE WhatId = :recordId ORDER BY Priority, Status DESC, LastModifiedDate, CreatedDate];
        }
                                               
       return lstTask;                
    }

    @AuraEnabled(cacheable=true)
    public static Map < String, String > getStateOptionsList() {
        map<String, String> mapOfValues = new map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            mapOfValues.put(f.getLabel(), f.getValue());
        }
        return mapOfValues;
    }

    
    public class AccountContactWrapper {
        @AuraEnabled public String contactId;
        @AuraEnabled public String Roles;
        @AuraEnabled public String contactName;
   
    }

    public class ContentDocumentWrapper {
        @AuraEnabled public String docId;
        @AuraEnabled public String docTitle;
        @AuraEnabled public String docSize;
        @AuraEnabled public String docType;
        @AuraEnabled public Datetime docModifiedDate;
        @AuraEnabled public Integer docViewCount;
        @AuraEnabled public String downloadUrl;
        @AuraEnabled public String publicUrl;
    }
}