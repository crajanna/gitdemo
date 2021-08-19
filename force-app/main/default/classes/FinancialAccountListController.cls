public with sharing class FinancialAccountListController {


    @AuraEnabled(cacheable=true) 
    public static List<FinServ__FinancialAccountRole__c> getSavingsPlanData(String accId){
        System.debug('getSavingsPlanData >>>>' + accId);
        try {
            List<FinServ__FinancialAccountRole__c> savingsPlanDataList = [Select Id,FinServ__FinancialAccount__r.FinServ__PrimaryOwner__r.Name,
            FinServ__RelatedAccount__r.Name ,FinServ__FinancialAccount__r.Id,FinServ__FinancialAccount__r.Name , 
            FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c ,FinServ__FinancialAccount__r.Total_Market_Value__c 
            from FinServ__FinancialAccountRole__c where FinServ__Role__c= 'Beneficiary' and 
            FinServ__Active__c=true and FinServ__FinancialAccount__r.FinServ__PrimaryOwner__r.Id = :accId WITH SECURITY_ENFORCED];
            
            return savingsPlanDataList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}