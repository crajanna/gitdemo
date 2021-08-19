public with sharing class beneficiaryPolicyContorller {
  
    @AuraEnabled(cacheable = true)
    public static List<InsurancePolicy> fetchPoliciesDetails(Id accountId){
        List<InsurancePolicy> policyList = [SELECT Id, Name,PolicyName,Status, Enrollment__c,Policy_Premium_Amount__c,EffectiveDate,ExpirationDate,Beneficiary_Account__c
                                    FROM InsurancePolicy WHERE NameInsuredId=:accountId];
                  Set<Id> policiesIdWithBen = new Set<Id>();
    for(InsurancePolicyParticipant IP: [Select id, name,InsurancePolicyId from InsurancePolicyParticipant where InsurancePolicyId in :policyList])
        {
                policiesIdWithBen.add(IP.InsurancePolicyId);

        }

        List<InsurancePolicy> policyListWithoutBen = new List<InsurancePolicy>();
        for(InsurancePolicy p : policyList)
        {
            if(!policiesIdWithBen.contains(p.id))
            policyListWithoutBen.add(p);
        }
         return policyListWithoutBen;
    }

    @AuraEnabled
    public static void savePolicies(List<InsurancePolicy> policyList){
           list<InsurancePolicyParticipant> newPArticipantList = new List<InsurancePolicyParticipant>();

         for(InsurancePolicy P : policyList)
         {
             InsurancePolicyParticipant tempIP = new InsurancePolicyParticipant();
             tempIP.InsurancePolicyId = p.Id;
             tempIP.PrimaryParticipantAccountId = p.Beneficiary_Account__c;
             tempIP.IsActiveParticipant = true;
             newPArticipantList.add(tempIP);

         }
         insert newPArticipantList;
        
    }
}