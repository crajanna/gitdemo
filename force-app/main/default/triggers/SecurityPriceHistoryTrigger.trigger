trigger SecurityPriceHistoryTrigger on Security_Price_History__c (before insert, after insert, after update, after delete) {
    if(TriggerUtil.isTriggerActive('SecurityPriceHistoryTrigger')){     

        if(Trigger.isAfter){
            if(Trigger.isInsert){
                SecurityPriceHistoryHandler.onAfterInsert(Trigger.New);
            }
        }
    }
}