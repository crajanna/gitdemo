public without sharing class DemiImg {
    
    private static final String  BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();

    private static final String  BASE_URL1 = 
        'https://fpcb--fpcbdevp1--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=';

    
    @AuraEnabled(cacheable=true)
    public static String getLogoUrl(String accountId){
        ContentDocumentLink contentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId, SystemModstamp FROM ContentDocumentLink 
                                                   where LinkedEntityId =:accountId  order by SystemModstamp desc Limit 1];
		
        ContentVersion contentVersion = [SELECT Id, Title, PublishStatus FROM ContentVersion where 
                                         ContentDocumentId =: contentDocumentLink.ContentDocumentId ];
		
        String imgUrl = BASE_URL1 + contentVersion.id;
		
        return imgUrl;
        
	}
   
    
    //Reterives specific file information
  	@AuraEnabled
    public static String GetFile(string contentDocumentId)
    {
        return BASE_URL + '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+contentDocumentId;
    }
   
    public static void test(){
        String s = System.URL.getSalesforceBaseUrl().getHost();
        System.debug('host name: '+s);
    }
}