public without sharing class FinHistoryController {
    public String policyId{get;set;}
    @AuraEnabled(cacheable=true)
    public static List<InsurancePolicy > getPrepaidPolicyById(String policyId) {
        System.debug('getPrepaidPolicyById ' + policyId); 
        List<InsurancePolicy> items = [SELECT Id, PremiumAmount, GrossWrittenPremium
                                                    from InsurancePolicy WHERE Id = : policyId];
       System.debug(items);                                        
       return items;                                             

    }
}