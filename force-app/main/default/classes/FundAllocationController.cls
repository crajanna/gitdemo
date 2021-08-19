/* Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/20/2021   Satish Nikam    10923 - T2 : Age based Portfolio handling based on matriculation date
**/
public without sharing class FundAllocationController {
    
	public String accountId{get;set;}
    public static Integer DEFAULT_MATRICULATION_AGE = 18;
    @AuraEnabled
    public static List<SecurityAllocation> getSecurityAlllocationById(String accountId, String allocationType) {
      return getSecurityAlllocationById(accountId, allocationType, null);
    }

    @AuraEnabled
    public static Boolean hasNoBeneficiary(String accountId) {
        List<FinServ__FinancialAccountRole__c> roleList = [SELECT FinServ__RelatedAccount__r.PersonContact.Birthdate , FinServ__RelatedAccount__r.Matriculation_Date__c,FinServ__Active__c FROM 
        FinServ__FinancialAccountRole__c  WHERE FinServ__FinancialAccount__c = :accountId and
        FinServ__Role__c = 'Beneficiary' LIMIT 1];
        Date dateOfBirth = !roleList.isEmpty() ?  roleList.get(0).FinServ__RelatedAccount__r.PersonContact.Birthdate : null;
        return dateOfBirth==null;
    }

    @AuraEnabled
    public static List<SecurityAllocation> getSecurityAlllocationById(String accountId, String allocationType, String matriculationDate) {
    //public static List<SecurityAllocation> getSecurityAlllocationById(String accountId, String allocationType, String dob) {
        List<SecurityAllocation> saList = new List<SecurityAllocation>();
        Decimal balance = null;
        //Date dateOfBirth = null;
        Date matriculationDt = null;
        String ageFundAbbr ='';
        Map<String, Decimal> holdings = null;
        List<FinServ__Securities__c> securitiesList = null;

        if(accountId != null){
            List<FinServ__FinancialAccountRole__c> roleList = [SELECT FinServ__RelatedAccount__r.PersonContact.Birthdate , FinServ__Active__c,FinServ__RelatedAccount__r.Matriculation_Date__c FROM 
                                                               FinServ__FinancialAccountRole__c  WHERE FinServ__FinancialAccount__c = :accountId and
                                                               FinServ__Role__c = 'Beneficiary' AND FinServ__Active__c = true LIMIT 1];
            balance = [SELECT FinServ__Balance__c from FinServ__FinancialAccount__c where Id =  :accountId LIMIT 1].FinServ__Balance__c;

            matriculationDt = !roleList.isEmpty() ?  roleList.get(0).FinServ__RelatedAccount__r.Matriculation_Date__c : null;
            ageFundAbbr = matriculationDt!=null ? AgeBasedPortfolioUtil.ageSecurityPlan(matriculationDt) : null;

            holdings = getSecHoldings(accountId);
            securitiesList =  [SELECT Id, Name, FinServ__SecuritiesName__c, Fund_Category__c , (SELECT Id , allocation_percentage__c from Fund_Allocations__r 
                                                                                  where Financial_Account__r.Id = :accountId
                                                                                  and Allocation_Type__c= :allocationType
                                                                                  and Active_Indicator__c = 'Yes') from FinServ__Securities__c];
        }else{
            securitiesList =  [SELECT Id, Name, FinServ__SecuritiesName__c, Fund_Category__c from FinServ__Securities__c where Fund_Category__c in ('Individual' , 'Static', 'Age Based')];
            if(matriculationDate!=null){
                matriculationDt = Date.valueOf(matriculationDate);
                ageFundAbbr = matriculationDate!=null ? AgeBasedPortfolioUtil.ageSecurityPlan(matriculationDt) : null;
            } 
            
        }

         for(FinServ__Securities__c item: securitiesList){

            SecurityAllocation saObj = new SecurityAllocation();
            saObj.fundSecId = item.Id;
            saObj.fundName = item.FinServ__SecuritiesName__c;
            saObj.fundAbbr = item.Name;
            saObj.allocationType = allocationType;
            saObj.fundCategory = item.Fund_Category__c;
            saObj.allocationPercentage = 0;

            if(accountId != null){
                    List<Fund_Allocation__c> fa = item.Fund_Allocations__r;
                    if(fa.size() == 1) {
                        saObj.fundAllocId = fa.get(0).Id;
                        saObj.allocationPercentage = fa.get(0).allocation_percentage__c;                                                                    
                    }

                    Decimal existAmount = holdings.get(saObj.fundSecId);
                    if(existAmount!=null && existAmount > 0 && balance!=null && balance>0){
                        Decimal toround = (existAmount/balance) * 100;
                        saObj.marketFAPercentage =  toRound.setScale(2, RoundingMode.HALF_UP);   
                        saObj.marketFAPercentageText = String.Format('Current Market Percentage - {0}%.', new List<Object>{saObj.marketFAPercentage});
                    }   
            }   
            if(saObj.fundAbbr.equals(ageFundAbbr)){
                saObj.currentAgePlan = true;                                                                          
            }                                                                   
            saList.add(saObj);
        }		
        System.debug('getSecurityAlllocationById ... ' +  saList.size());  
        return saList;
    }

    @AuraEnabled
    public static Boolean saveAllocations(String allocations, String accountId){
        System.debug('Inside allocations ... ' +  accountId);  
        List<SecurityAllocation> allocationsList = (List<SecurityAllocation>) JSON.deserialize(allocations, List<SecurityAllocation>.class);
        List<Fund_Allocation__c> updateList = new List<Fund_Allocation__c>(); 
            for(SecurityAllocation allocItem : allocationsList) {
                System.debug('Inside .. ' + accountId + ', ' +  allocItem.fundAllocId + ',' + allocItem.allocationPercentage); 
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
                    updateList.add(fd);
                }
            }
		
        FinServ__FinancialAccount__c finAccount = [SELECT Allocation_Last_Modified_Date__c from FinServ__FinancialAccount__c where Id =  :accountId LIMIT 1];
        finAccount.Allocation_Last_Modified_Date__c = Datetime.now();
        if (Schema.sObjectType.FinServ__FinancialAccount__c.fields.Allocation_Last_Modified_Date__c.isUpdateable()) {
            update finAccount;
        }
        System.debug('Inside allocations updateList ... ' + updateList.size()); 
        if (Schema.sObjectType.Fund_Allocation__c.fields.allocation_percentage__c.isUpdateable() && Schema.sObjectType.Fund_Allocation__c.fields.allocation_percentage__c.isCreateable()) {
            upsert updateList;
        }
        
        return true;
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
        public String marketFAPercentageText;
        @AuraEnabled
        public String allocationType = 'FA';
        @AuraEnabled
        public String activeIndicator = 'Yes';
        @AuraEnabled
        public String fundCategory;
        @AuraEnabled
        public boolean currentAgePlan;
        
       
        @AuraEnabled
        public boolean getStatic(){
            return 'Static'.equals(fundCategory);
        }
        
        @AuraEnabled
        public boolean getIndividual(){
            return 'Individual'.equals(fundCategory);
        }
        
        @AuraEnabled
        public boolean getAgeBased(){
            return 'Age Based'.equals(fundCategory);
        }
    }
    
    /*private static String agePlan(Date dateOfBirth){
        Integer age;
        String ageFundAbbr = null;
        if(dateOfBirth!=null){
            Integer temp = dateOfBirth.daysBetween(Date.Today());
            ageFundAbbr = 'ABM00';
        	age = Integer.valueOf(temp/365);
            if(age>4){
                ageFundAbbr = String.format('ABM{0}', new List<Object>{String.valueOf(age).leftPad(2, '0')});
            }
        }
        return ageFundAbbr;
    }*/

    private static Map<String, Decimal> getSecHoldings(String accountId) {
        Map<String, Decimal> secHoldings = new Map<String, Decimal>();
        for(FinServ__FinancialHolding__c m : [SELECT FinServ__Securities__r.Id, FinServ__MarketValue__c from FinServ__FinancialHolding__c WHERE FinServ__FinancialAccount__C = :accountId]){
            secHoldings.put(m.FinServ__Securities__r.Id, m.FinServ__MarketValue__c);    
        }
        return secHoldings;
    }
}