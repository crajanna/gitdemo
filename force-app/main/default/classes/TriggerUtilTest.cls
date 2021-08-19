@isTest
public with sharing class TriggerUtilTest {

    private static testMethod void testIsTriggerActive(){
        Boolean isActive;

        Test.startTest();
        isActive = TriggerUtil.isTriggerActive('noofcontacts');
        Test.stopTest();
        
        System.debug('isActive =>'+isActive);
    }
}