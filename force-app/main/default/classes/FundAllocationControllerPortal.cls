public without sharing class FundAllocationControllerPortal {

    @AuraEnabled(cacheable=true)
    public static List<SecurityAllocationPortal> getSecurityAlllocations() {
        List<SecurityAllocationPortal> saList = new List<SecurityAllocationPortal>();
        for(FinServ__Securities__c item: [SELECT Id, Name, FinServ__SecuritiesName__c, Fund_Category__c from FinServ__Securities__c where Fund_Category__c in ('Individual' , 'Static', 'Age Based')]){
        
            SecurityAllocationPortal saObj = new SecurityAllocationPortal();
            saObj.fundSecId = item.Id;
            saObj.fundCategory = item.Fund_Category__c;
            saObj.fundName = item.FinServ__SecuritiesName__c;
            saObj.fundAbbr = item.Name;
            saObj.allocationPercentage = 0;                                                                      
            saList.add(saObj);

        }
                                                      
       return saList;                                             

    }

    public class SecurityAllocationPortal {
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
        @AuraEnabled
        public String fundCategory;
    }


}