public class BeneficiaryTriggerHandler {
    private static BeneficiaryTriggerHandler instance = null;
    public BeneficiaryTriggerHandler() {}
    public static BeneficiaryTriggerHandler getInstance(){
        if(instance == null) instance = new BeneficiaryTriggerHandler();
        return instance;
    }

    public void OnBeforeInsert(List <Beneficiary__c> newBeneficiary) {
        system.debug('Beneficiary Trigger On Before Insert');
    }

    public void OnAfterInsert(List <Beneficiary__c> newBeneficiary) {
        system.debug('Beneficiary Trigger On After Insert');
    }

    public void OnBeforeUpdate(List <Beneficiary__c> newBeneficiary, List <Beneficiary__c> oldBeneficiary, Map < ID, Beneficiary__c > newBeneficiaryMap, Map < ID, Beneficiary__c > oldBeneficiaryMap) {
        system.debug('Beneficiary Trigger On Before Update ');
    }

    public void OnAfterUpdate(List <Beneficiary__c> newBeneficiary, List <Beneficiary__c> oldBeneficiary, Map < ID, Beneficiary__c > newBeneficiaryMap, Map < ID, Beneficiary__c > oldBeneficiaryMap) {
        system.debug('Beneficiary Trigger On After Update ');
    }
}