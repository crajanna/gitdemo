public class TriggerUtil {
    public static Boolean isTriggerActive(String triggerName){
        Trigger_Switch__mdt triggerRecord = String.IsNotBlank(triggerName) ? Trigger_Switch__mdt.getInstance(triggerName):null;
        Boolean isActive = triggerRecord != null ? triggerRecord.Active__c: false;
        return isActive;
    }
}