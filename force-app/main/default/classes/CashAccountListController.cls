public with sharing class CashAccountListController {
    @AuraEnabled(cacheable=true) 
    public static List<FinServ__FinancialAccount__c> getCashAccount(String accId){
        System.debug('getCashAccount >>>>' + accId);
        try {
            List<FinServ__FinancialAccount__c> cashAccountDataList = [Select Id,Name,FinServ__PrimaryOwner__r.Name , FinServ__CashBalance__c ,FinServ__FinancialAccountNumber__c
            from FinServ__FinancialAccount__c where FinServ__PrimaryOwner__r.Id = :accId and FinServ__FinancialAccountType__c = 'Cash Account' WITH SECURITY_ENFORCED];
            return cashAccountDataList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}