/**
 * Name: FinancialAccountRoleCustomTrigger
 * Description: apex based sharing implementation for security work
 * Test Class: FinancialAccountRoleHandlerTest
 * Created By: Satish Nikam - 8/13/2021
 * Modifications Log: 
 * Date         Modified By    Modification Details
 * 8/13/2021   Satish Nikam    Original Implementation for apex based sharing
**/
trigger FinancialAccountRoleCustomTrigger on FinServ__FinancialAccountRole__c (after insert, after update, before insert, before update,after delete)  {

    FinancialAccountRoleHandler handler = FinancialAccountRoleHandler.getInstance();

    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            //handler.OnBeforeInsert(trigger.New);
        } else {
            handler.OnAfterInsert(trigger.New);
        }
    }else if (Trigger.isDelete) {
        if (Trigger.isAfter) {
            handler.OnAfterDelete(trigger.Old);
        }
    }else if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            //handler.OnBeforeUpdate(trigger.New, trigger.Old, Trigger.NewMap, Trigger.OldMap);
        } else {
            //handler.OnAfterUpdate(trigger.New, trigger.Old, Trigger.NewMap, Trigger.OldMap);
        }
    }
}