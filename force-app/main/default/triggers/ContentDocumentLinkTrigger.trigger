trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    if(TriggerUtil.isTriggerActive('ContentDocumentLinkTrigger')){
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            
            FP_ContentDocumentLinkTriggerHelper.UpdateContentVisibility(Trigger.New);
            BoardContentDocumentLinkTriggerHelper.UpdateContentVisibility(Trigger.New); 
        }
    }
}