public without sharing class FpDashboardContactController {

    @AuraEnabled
    public static Contact createContact(){

        Contact newContact = new Contact();
        newContact.LastName = 'Nwangwu234';
        newContact.AccountId = '001P000001nnauDIAQ';//
        newContact.RecordTypeId = '0124W000001bAJfQAM';
        try {
            insert newContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return newContact;
    }

    public FpDashboardContactController() {

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

    @AuraEnabled
    public static Account getDefaultAccountData(String recordId){
        Account getAccount;
        if(recordId!='' && recordId!=null){
            getAccount = [SELECT Id, Name, Email__c, Phone, Website, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Id=:recordId];
        }
        return getAccount;
    }

    @AuraEnabled(cacheable=true)
    public static String findImageByRecord(String recordId){ 
        String theUrl = '';
        
        try{  
            List<ContentDocumentLink> lstCdl;
            List<ContentVersion> lstCVersion;
            List<ContentDistribution> lstCDist;


            lstCdl = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :recordId LIMIT 1];
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

}