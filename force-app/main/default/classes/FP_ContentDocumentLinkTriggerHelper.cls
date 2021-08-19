public class FP_ContentDocumentLinkTriggerHelper {
    
    public static void UpdateContentVisibility(List<ContentDocumentLink> lstCdl){
        List<Id> lstCdocIds = new List<Id>();
        Map<Id, ContentDocument> mapCDocIdToCDoc = new Map<Id, ContentDocument>();
        
        for(ContentDocumentLink eachCdl : lstCdl) {
            String sObjectName = eachCdl.LinkedEntityId.getSObjectType().getDescribe().getName();
            if(sObjectName == 'Account') {
            	lstCdocIds.add(eachCdl.ContentDocumentId);
            }
        }
        
        if(lstCdocIds.size() > 0 ) {
            mapCDocIdToCDoc = new Map<Id, ContentDocument>([SELECT Id, Title, Description FROM ContentDocument WHERE Id = :lstCdocIds]);
            
            for(ContentDocumentLink eachCdl : lstCdl) {
                ContentDocument eachCDoc = mapCDocIdToCDoc.get(eachCdl.ContentDocumentId);
                if(eachCDoc != null && (eachCDoc.Title.contains('Invoice') || eachCDoc.Title.contains('Receipt'))) {
                    eachCdl.Visibility = 'AllUsers';
                }
            }
        }
        
        //return lstCdl2;
    }
}