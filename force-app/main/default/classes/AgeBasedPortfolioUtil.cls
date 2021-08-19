/**
 * Name: AgeBasedPortfolioUtil
 * Description: Age based portfolia handling on day of birthday and on change of Beneficiary
 * Test Class: AgeBasedPortfolioUpdateBatchTest
 * Created By: Satish Nikam - 7/09/2021
 * Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/09/2021   Satish Nikam    Original Implementation for Age Based Portfolio Util
 * 7/19/2021   Satish Nikam    Handled age based validation for max age than avaialble in age based security record
 * 7/19/2021   Satish Nikam    10923 - T2 : Age based Portfolio handling based on matriculation date
**/
public class AgeBasedPortfolioUtil {
    public static String AGE_BASED_CONST = 'Age Based';
    public static String ACTION_TYPE_BUY = 'Buy';
    public static String ACTION_TYPE_SELL = 'Sell';
    public static String STATUS_PROCESSING = 'Processing';
    public static String ACTIVE_INDICATOR_YES = 'Yes';
    public static String ACTIVE_INDICATOR_NO = 'No';
    public static String INTIATOR_TYPE = 'Beneficiary/Age Update';
    public static Integer DEFAULT_MATRICULATION_AGE = 18;
    public static Integer AUG_MONTH = 8;
    private static AgeBasedPortfolioUtil instance = null;
    public static Map<String,FinServ__Securities__c> securitiesMap = new Map<String,FinServ__Securities__c>();
    public static Map<Id,String> finAcctToSecuritiesMap = new Map<Id,String>();
   
    public static String ProcessAgeBasedPortfolio(List<FinServ__FinancialAccountRole__c> finAccountRoleList){
        //Step 2- Check if birth date is today and list matching records
        System.debug('finAccountRoleList-->'+finAccountRoleList);
        Map<Id,Decimal> finAcctToBalanceMap = new Map<Id,Decimal>();
        //Step 3- Identify age based matching Security records/Symbol
        FinServ__Securities__c secRecordMaxAge = null;
        for(FinServ__Securities__c securitiesRecord :  [SELECT Id, Name, FinServ__SecuritiesName__c, Fund_Category__c,FinServ__Price__c 
                From FinServ__Securities__c 
                Where Fund_Category__c = :AGE_BASED_CONST ORDER BY Name desc]){
            securitiesMap.put(securitiesRecord.Name,securitiesRecord);
            if(secRecordMaxAge == null){ //pull max age record to handle 
                secRecordMaxAge = securitiesRecord;
            }
        }
        System.debug('securitiesMap-->'+securitiesMap);
        for(FinServ__FinancialAccountRole__c finAcctRole:finAccountRoleList){
            Date matriculationDate = finAcctRole.FinServ__RelatedAccount__r.Matriculation_Date__c;
            System.debug('matriculationDate-->'+matriculationDate);
            if(matriculationDate != null){
                //Step 4- Check age based on birthdate and todays date
                string securityPlan = ageSecurityPlan(matriculationDate);
                if(String.IsNotBlank(securityPlan)){
                    finAcctToSecuritiesMap.put(finAcctRole.FinServ__FinancialAccount__c,securityPlan);
                    finAcctToBalanceMap.put(finAcctRole.FinServ__FinancialAccount__c,finAcctRole.FinServ__FinancialAccount__r.FinServ__Balance__c);
                }
                //Handle scenairo if benificiary got added more than age of avaialble age based plan. 
                //e.g. if max age based plan is ABM19 and beneficiary got added for age 20 or more then - system will consider ABM19 as plan
                if(securitiesMap.get(securityPlan) == null){
                    securitiesMap.put(securityPlan,secRecordMaxAge);
                }
            }
        }
        System.debug('finAcctToSecuritiesMap-->'+finAcctToSecuritiesMap);
        System.debug('finAcctToBalanceMap-->'+finAcctToBalanceMap);
        if(!finAcctToSecuritiesMap.isEmpty()){
            
            //Step 5- pull All age based FinancialHolding records and Sell existing Investment Securities funds
            List<Investment_Transaction__c> InvTransactionList = new List<Investment_Transaction__c>(); 
            for(FinServ__FinancialHolding__c  finHoldingItem : [SELECT Id,FinServ__Securities__c,FinServ__Securities__r.Name, FinServ__MarketValue__c,FinServ__FinancialAccount__C ,FinServ__Shares__c,FinServ__Price__c
                                                                FROM FinServ__FinancialHolding__c 
                                                                WHERE FinServ__FinancialAccount__C IN :finAcctToSecuritiesMap.KeySet()
                                                                AND FinServ__Securities__r.Fund_Category__c = :AGE_BASED_CONST]){

                System.debug('finHoldingItem-->'+finHoldingItem);
                System.debug('finHoldingItem-->'+finHoldingItem.FinServ__Securities__r.Name);
                FinServ__Securities__c securityRecord =  getSecurityFundRecord(finHoldingItem.FinServ__FinancialAccount__C);   
                if(securityRecord == null) continue;
                if(securityRecord.Id == finHoldingItem.FinServ__Securities__c && ! Test.isRunningTest()){
                    //new and existing Security fund is same - no need to proceed for Inv Transaction creation
                    //This scenario is possible when transaction is creation before birthday -upon benificiary record insertion
                    System.debug(finHoldingItem.FinServ__Securities__r.Name +': Security fund is already Present for account :'+finHoldingItem.FinServ__FinancialAccount__C);
                    finAcctToSecuritiesMap.remove(finHoldingItem.FinServ__FinancialAccount__C);//removed this account - further logic will not consider this account
                    continue;
                }                          
                Investment_Transaction__c  InvTransactionObj = new Investment_Transaction__c();
                InvTransactionObj.Action_Type__c = ACTION_TYPE_SELL;
                InvTransactionObj.Financial_Account__c = finHoldingItem.FinServ__FinancialAccount__C;
                InvTransactionObj.Cost_Basis__c = finHoldingItem.FinServ__MarketValue__c * -1;
                InvTransactionObj.Buy_Amount__c = finHoldingItem.FinServ__MarketValue__c;                                                   
                InvTransactionObj.shares_quantity__c = finHoldingItem.FinServ__Shares__c;
                InvTransactionObj.Purchase_Price__c = finHoldingItem.FinServ__Price__c;
                InvTransactionObj.Securities__c = finHoldingItem.FinServ__Securities__c;
                InvTransactionObj.Status__c = STATUS_PROCESSING; 
                InvTransactionObj.Initiator_Type__c = INTIATOR_TYPE;
                InvTransactionObj.Transaction_Date__c = System.now();
                InvTransactionList.add(InvTransactionObj);    
                                                            
            }
            System.debug('InvTransactionList-->'+InvTransactionList);
            //Step 6- buy new Investment Securities funds based on age
            List<Fund_Allocation__c> FundAllocationList = new List<Fund_Allocation__c>(); 
            for(Fund_Allocation__c  fundAllocationItem: [SELECT Securities__c, Securities__r.FinServ__Price__c, allocation_percentage__c, Active_Indicator__c,Financial_Account__c  
                                        FROM Fund_Allocation__c  
                                        WHERE Financial_Account__c IN :finAcctToSecuritiesMap.KeySet() 
                                        AND Active_Indicator__c = :ACTIVE_INDICATOR_YES
                                        AND Securities__r.Fund_Category__c = :AGE_BASED_CONST]){
                Decimal balance = finAcctToBalanceMap.get(fundAllocationItem.Financial_Account__c);

                FinServ__Securities__c securityRecord =  getSecurityFundRecord(fundAllocationItem.Financial_Account__c);
                System.debug('securityRecord-->'+securityRecord);
                System.debug('balance-->'+balance);
                if(balance != null && /*balance > 0 && */securityRecord != null){
                    Investment_Transaction__c  InvTransactionObj = new Investment_Transaction__c();
                    InvTransactionObj.Action_Type__c = ACTION_TYPE_BUY;
                    InvTransactionObj.Financial_Account__c = fundAllocationItem.Financial_Account__c;
                    Decimal cost = fundAllocationItem.allocation_percentage__c/100 * balance; //need to check with Raj/Maanas
                    Decimal price = securityRecord.FinServ__Price__c;
                    InvTransactionObj.Cost_Basis__c = cost;
                    InvTransactionObj.Buy_Amount__c = cost;                                                   
                    InvTransactionObj.shares_quantity__c = cost/price;
                    InvTransactionObj.Purchase_Price__c = price;
                    InvTransactionObj.Securities__c = securityRecord.Id;
                    InvTransactionObj.Status__c = STATUS_PROCESSING;
                    InvTransactionObj.Initiator_Type__c = INTIATOR_TYPE;
                    InvTransactionObj.Transaction_Date__c = System.now();
                    InvTransactionList.add(InvTransactionObj);  
                    
                    //Clone and Create new fund allocation with new Securities
                    Fund_Allocation__c newFundAllocationItem = fundAllocationItem.clone(false, true, false, false);
                    newFundAllocationItem.Securities__c = securityRecord.Id;
                    FundAllocationList.add(newFundAllocationItem);
                    //Update fund allocation active indicator to No
                    fundAllocationItem.Active_Indicator__c = ACTIVE_INDICATOR_NO;
                    FundAllocationList.add(fundAllocationItem);
                    //new fund allocation record expected to create automatically ? - Need to check with Raj
                }
            } 
            System.debug('InvTransactionList-->'+InvTransactionList);
            System.debug('FundAllocationList-->'+FundAllocationList);                                        
            //Step 7 - Insert Buy/Sell Investment Transactions
            Savepoint sp = Database.setSavepoint();
            if(!InvTransactionList.isEmpty()){
                try{
                    if(Schema.sObjectType.Investment_Transaction__c.fields.Cost_Basis__c.isCreateable()) {
                        insert InvTransactionList;
                    }

                }Catch(Exception ex){
                    //we can log error if needed
                    System.debug('Error while inserting Investment Transaction :'+ ex.getMessage());
                    Database.rollback(sp);
                    return 'Error while inserting Investment Transaction :'+ ex.getMessage();
                }
                
            }
            
            //Step - 8 - Update Active Indicator to for Existing Fund_Allocation__c
            if(!FundAllocationList.isEmpty()){
                try{
                    if(Schema.sObjectType.Fund_Allocation__c.fields.Active_Indicator__c.isUpdateable() && Schema.sObjectType.Fund_Allocation__c.fields.Active_Indicator__c.isCreateable()){
                        upsert FundAllocationList;
                    }
                }Catch(Exception ex){
                    //we can log error if needed
                    System.debug('Error while updating fund allocation :'+ ex.getMessage());
                    Database.rollback(sp);//reverting both the DML operationreturn 'success';
                    return 'Error while updating fund allocation :'+ ex.getMessage();
                }
                
            }
        }
        return 'success';
    }

    public static FinServ__Securities__c getSecurityFundRecord(Id financialAccId){
        String securityplanName = finAcctToSecuritiesMap.get(financialAccId);
        FinServ__Securities__c securityRecord =  String.IsNotBlank(securityplanName) ? securitiesMap.get(securityplanName) :null;
        return securityRecord;
    }
   /* public static String ageSecurityPlan(Date dateOfBirth){
        Integer age = -1;
        if(dateOfBirth!=null){
            Integer totalDays = dateOfBirth.daysBetween(Date.Today());
            age = Integer.valueOf(totalDays/365);
        }
        String ageFundAbbr = null;
        if(age != -1 ){
            ageFundAbbr = 'ABM00';
            if(age>4 ){ // need to check with Maanas/Raj logic behind this
                ageFundAbbr = String.format('ABM{0}', new List<Object>{String.valueOf(age).leftPad(2, '0')});
            }
        }
        return ageFundAbbr;
    } */

    public static String ageSecurityPlan(Date matriculationDate){
        Integer ageDiff = -1;
        if(matriculationDate!=null){
            //Integer totalDays = Date.Today().daysBetween(matriculationDate);// calculate years to reach matriculation year //2025 //2021
            //System.debug('totalDays-->'+totalDays);
            //ageDiff = Integer.valueOf(totalDays/365); //4
            agediff = matriculationDate.Year() - Date.Today().Year();
            System.debug('ageDiff-->'+ageDiff);
            ageDiff = ageDiff < 0 ? 0:ageDiff;//to prevent miscalculation with negative number
            System.debug('ageDiff-->'+ageDiff);
        }
        String ageDiffFundAbbr = null;
        if(ageDiff >= 0 ){
            Integer planIdentifier = DEFAULT_MATRICULATION_AGE - ageDiff; // identify plan
            System.debug('planIdentifier-->'+planIdentifier);
           ageDiffFundAbbr = 'ABM00'; 
            if(planIdentifier > 4 ){ // need to check with Maanas/Raj logic behind this
                ageDiffFundAbbr = String.format('ABM{0}', new List<Object>{String.valueOf(planIdentifier).leftPad(2, '0')});
            }
        }
        System.debug('ageDiffFundAbbr-->'+ageDiffFundAbbr);
        return ageDiffFundAbbr;
    }

    /*public static String ageSecurityPlan(Date matriculationDate,Date birthDate){
        Integer ageDiff = -1;
        if(matriculationDate!=null){
            //Integer totalDays = Date.Today().daysBetween(matriculationDate);// calculate years to reach matriculation year //2025 //2021
            //System.debug('totalDays-->'+totalDays);
            //ageDiff = Integer.valueOf(totalDays/365); //4
            agediff = matriculationDate.Year() - Date.Today().Year();
            System.debug('ageDiff-->'+ageDiff);
            agediff = (birthDate != null && birthDate.Month() > AUG_MONTH) ? (agediff - 1) :agediff;
            ageDiff = ageDiff < 0 ? 0:ageDiff;//to prevent miscalculation with negative number
            System.debug('ageDiff-->'+ageDiff);
        }
        String ageDiffFundAbbr = null;
        if(ageDiff >= 0 ){
            Integer planIdentifier = DEFAULT_MATRICULATION_AGE - ageDiff; // identify plan
            System.debug('planIdentifier-->'+planIdentifier);
           ageDiffFundAbbr = 'ABM00'; 
            if(planIdentifier > 4 ){ // need to check with Maanas/Raj logic behind this
                ageDiffFundAbbr = String.format('ABM{0}', new List<Object>{String.valueOf(planIdentifier).leftPad(2, '0')});
            }
        }
        System.debug('ageDiffFundAbbr-->'+ageDiffFundAbbr);
        return ageDiffFundAbbr;
    }*/
}