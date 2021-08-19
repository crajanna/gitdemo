public without sharing class ContractFinancialHoldings {
    public class FlowInputs {
        @InvocableVariable public String contractId;
        @InvocableVariable @AuraEnabled public String accountId;
    }


    @InvocableMethod
    public static GetValuesOutputs[] getFundAllocations (List<FlowInputs> request) {

        String contractId = request[0].contractId;
        String accountId = request[0].accountId;

        Contract contract = [SELECT SP_Selected_Portfolios__c from Contract WHERE Id = : contractId];

        List<SecurityAllocation> allocationsList = (List<SecurityAllocation>) JSON.deserialize(contract.SP_Selected_Portfolios__c, List<SecurityAllocation>.class);
        sObject[] records = new sObject[]{};
        List<Fund_Allocation__c> updateList = new List<Fund_Allocation__c>(); 
        for(SecurityAllocation allocItem : allocationsList) {
            if(allocItem.allocationPercentage>0 || allocItem.fundAllocId !=null){
                Fund_Allocation__c  fd = new Fund_Allocation__c();
                fd.Id = allocItem.fundAllocId;
                fd.allocation_percentage__c = allocItem.allocationPercentage;
                if(allocItem.fundAllocId==null) {
                    fd.Financial_Account__c = accountId;
                    fd.Securities__c = allocItem.fundSecId;
                }
                fd.Active_Indicator__c = allocItem.activeIndicator;
                fd.Allocation_Type__c = allocItem.allocationType;
                records.add(fd);
            }
        }
        GetValuesOutputs obj = new GetValuesOutputs();
        obj.records = records;
        GetValuesOutputs[] result = new GetValuesOutputs[]{};
            result.add(obj);
        return result;
    } 

    public class GetValuesOutputs{
        @InvocableVariable(label='Map Values' required=true)
        public sObject[] records;
    }

    public class SecurityAllocation {
        @AuraEnabled
        public String fundSecId;
        @AuraEnabled
        public String fundName;
        @AuraEnabled
        public String fundAbbr;
        @AuraEnabled
        public String fundAllocId;
        @AuraEnabled
        public Decimal allocationPercentage;
        @AuraEnabled
        public Decimal marketFAPercentage;
        @AuraEnabled
        public String allocationType = 'FA';
        @AuraEnabled
        public String activeIndicator = 'Yes';
    }
}