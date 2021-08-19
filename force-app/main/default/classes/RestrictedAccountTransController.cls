public with sharing class RestrictedAccountTransController {
    
  /*  @AuraEnabled(cacheable=true) 
    public static List<FinServ__FinancialAccount__c> getRestrictedAccountBalances(String policyId){
        System.debug('getRestrictedAccountBalances >>>>' + policyId);
        try {
            List<FinServ__FinancialAccount__c> restrictedAccountBalanceList = [select Id,Name,SRO_Funds__c,Gardner_Funds__c,Flag_Court_Order_Funds__c,Donations_Pledge_Funds__c from FinServ__FinancialAccount__c where FinServ__PrimaryOwner__c IN 
                            (select NameInsuredId from InsurancePolicy where id = :policyId) and FinServ__FinancialAccountType__c = 'Cash Account'  WITH SECURITY_ENFORCED];
            return restrictedAccountBalanceList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/

    @AuraEnabled(cacheable=true) 
    public static List<InsurancePolicyCoverage> getPolicyCoverages(String policyId){
        System.debug('getPolicyCoverages >>>>' + policyId);
        try {
            List<InsurancePolicyCoverage> policyCoveragesList = [SELECT Id, CoverageName FROM InsurancePolicyCoverage where InsurancePolicyId= :policyId  WITH SECURITY_ENFORCED];
            return policyCoveragesList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id createRestrictedAccountTransactions(string strData,String strPageRef) {
        Date currentDate = System.Today();
        Restricted_Account_Transaction__c rat = new Restricted_Account_Transaction__c();
        try {
            Map<String, Object> raData = (Map<String, Object>)JSON.deserializeUntyped(strData);

            Map<String, Object> pageRef = (Map<String, Object>)JSON.deserializeUntyped(strPageRef);
            Map<String, Object> attributes = (Map<String, Object>) pageRef.get('attributes');
            system.debug('attributes>>>>'+attributes.get('objectApiName'));
            String objectApiName = String.valueOf(attributes.get('objectApiName'));  
            String sourceCategory = String.valueOf(raData.get('sourceCategoryValue'));
            rat.Restriction_Date__c = currentDate;
            rat.Source_Category__c = sourceCategory;
            rat.Source_Sub_Category__c = String.valueOf(raData.get('sourceSubCategoryValue'));
            rat.Transaction_Type__c = String.valueOf(raData.get('transactionTypeValue'));
            rat.Amount__c = Double.valueOf(raData.get('amount'));
        // rat.Insurance_Policy_Coverage__c = String.valueOf(raData.get('recordId'));
            system.debug('objectApiName' + objectApiName);
            if(objectApiName == 'InsurancePolicy'){
                rat.Insurance_Policy_Coverage__c = String.valueOf(raData.get('selectedCoveragesValues'));
            }else if(objectApiName == 'Contract'){
                if(sourceCategory == 'Budget'){
                    rat.Contract__c = String.valueOf(raData.get('contractId'));
                    rat.Month__c = String.valueOf(raData.get('transactionMonthValue'));
                    rat.Year__c = String.valueOf(raData.get('transactionYearValue'));
                }
            }else{
                rat.Financial_Account__c = String.valueOf(raData.get('recordId'));
                if(sourceCategory == 'Budget'){
                    rat.Contract__c = String.valueOf(raData.get('contractId'));
                    rat.Month__c = String.valueOf(raData.get('transactionMonthValue'));
                    rat.Year__c = String.valueOf(raData.get('transactionYearValue'));
                }
            }
            if (Schema.sObjectType.Restricted_Account_Transaction__c.isCreateable()) {
                insert rat;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return rat.Id;
    }

}