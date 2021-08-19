public class BoardContentDocumentLinkTriggerHelper {
	public static void UpdateContentVisibility(List<ContentDocumentLink> lstCdl){ 
        List<Id> lstCdocIds = new List<Id>();
        Map<Id, ContentDocument> mapCDocIdToCDoc = new Map<Id, ContentDocument>();
        
        for(ContentDocumentLink eachCdl : lstCdl) {
            String sObjectName = eachCdl.LinkedEntityId.getSObjectType().getDescribe().getName();
            System.debug('sObjectName => '+sObjectName);
            if(sObjectName == 'Event') {
            	lstCdocIds.add(eachCdl.ContentDocumentId);
            }
        }
        
        if(lstCdocIds.size() > 0 ) {
            mapCDocIdToCDoc = new Map<Id, ContentDocument>([SELECT Id, Title, Description FROM ContentDocument WHERE Id = :lstCdocIds]);
            
            for(ContentDocumentLink eachCdl : lstCdl) {
                System.debug('CDL Id:'+eachCdl.Id+' --- LinkedEntityId: '+eachCdl.LinkedEntityId+' --- Visibility : '+eachCdl.Visibility );
                System.debug('Before :'+eachCdl.Visibility);
                ContentDocument eachCDoc = mapCDocIdToCDoc.get(eachCdl.ContentDocumentId);
                //if(eachCDoc != null && (eachCDoc.Title.contains('Board Meeting') || eachCDoc.Title.contains('Audit Committee') || eachCDoc.Title.contains('Investment Committee') || eachCDoc.Title.contains('Workshop'))) {
                    eachCdl.Visibility = 'AllUsers';
                //}
                System.debug('After: '+eachCdl.Visibility);
            }
        }
    }
}