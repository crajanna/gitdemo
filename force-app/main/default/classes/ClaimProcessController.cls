/**
* 
* @author : Manas Shinde
* Class contains the logic to calculate the claim amount submitted by 
* Account Owner or School based on either units or amount for the rates of the School.
* 
*/

public inherited sharing class ClaimProcessController {

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

/**
 * 
 * @param institutionType  - Type of Institution (In State vs Out State)
 * @param termValue - (Spring/Summer/Fall)
 * @param yearValue 
 * @param schoolId (Id of Eduacational Institute)
 * @param rateCodeList (Rate Codes associated with the school)
 * @return  `list < School_Rate__c >`
 */
public static list < School_Rate__c > getSchoolRates(string institutionType, string termValue , String yearValue , String schoolId,List<String> rateCodeList) {
    list < School_Rate__c > schoolRates;

    if(rateCodeList != null && rateCodeList.size() > 0){
        schoolRates = [Select Actual_Rate__c, Coverage_Type__c,  Rate_Type__c,Rate_Code__c,Rate_Code__r.Calculation_Method__c from School_Rate__c 
        where  Term__c =: termValue AND Year__c =: yearValue and Rate_Code__c =: rateCodeList  WITH SECURITY_ENFORCED];
    }
    /*else{
        schoolRates = [Select Actual_Rate__c, Coverage_Type__c, Rate_Type__c,Rate_Code__c,Rate_Code__r.Calculation_Method__c from School_Rate__c 
        where Educational_Institutes__c =: schoolId and Rate_Type__c = : institutionType AND Term__c =: termValue AND Year__c =: yearValue 
        and Default_Ind__c = true WITH SECURITY_ENFORCED];
    }*/
    return schoolRates;
}

/** Method called from LWC Component and it reads the data for the creation of the claim.
 * 
 * @param strClaimData 
 * @param coveragePlanId 
 * @param coveragesPlans 
 * @return  `id`
 */
@AuraEnabled
public static id submitClaim(string strClaimData,list<string> coveragePlanId,list<string> coveragesPlans) {

    //create instance of wrapper

    string claimId;
    string paymentMethod;
    string nameinsuredId;
    Decimal requestedUnitValue;
    Decimal requestedAmountValue;
    List < Map < String, Object >> files;
    map < string, string > coverageIdRateCodeMap = new map < string, string > ();
    Map<String, Object> claimData = (Map<String, Object>)JSON.deserializeUntyped(strClaimData);
    String policyId = String.valueOf(claimData.get('policyId'));
    String schoolId = String.valueOf(claimData.get('schoolId'));
    String termValue = String.valueOf(claimData.get('termValue'));
    String yearValue = String.valueOf(claimData.get('yearValue'));
    String strRequestedUnits = String.valueOf(claimData.get('requestedUnitValue'));
    String rateCodeValue = String.valueOf(claimData.get('rateCodeValue'));
    String schoolInvoiceId = String.valueOf(claimData.get('schoolInvoiceId'));
    String batchId = String.valueOf(claimData.get('batchId'));
    List<String> rateCodeList = new List<String>();

    if(String.isNotBlank(rateCodeValue)){
        rateCodeList.add(rateCodeValue);
    }

    if(String.isNotBlank(strRequestedUnits)){
        requestedUnitValue = Integer.valueOf(strRequestedUnits);
    }
    String strRequestedAmount = String.valueOf(claimData.get('requestedAmountValue'));
    if(String.isNotBlank(strRequestedAmount)){
        requestedAmountValue = Integer.valueOf(strRequestedAmount);
    }
    String claimTypeValue = String.valueOf(claimData.get('claimTypeValue'));
    //call claimCalcuations method

    Account  instType = [select id, Institution_Type__c,Sub_Type__c from Account where id =: schoolId WITH SECURITY_ENFORCED];

    string institutionType;

    if (instType != null) {
        institutionType = instType.Institution_Type__c;
    }
    
    //get the instituition type of the School
    list < School_Rate__c > schoolRates = getSchoolRates(institutionType, termValue,yearValue,schoolId,rateCodeList);

            
   /* if (requestedUnitValue != null && paymentMethod == 'Calculate Based on Units Requested') {        
         wrap = calculateClaimAmount(schoolRates,requestedUnitValue);
    }*/

    claimId = newClaim(schoolId, termValue, yearValue, claimTypeValue, requestedUnitValue, requestedAmountValue, batchId, '',schoolInvoiceId);

    return claimId;
}

/** Method which creates the claim record based on the inputs from LWC 
 * 
 * @param schoolId 
 * @param termValue (Spring/Summer/Fall)
 * @param yearValue 
 * @param claimTypeValue (School Invoice / Account Owner Reimbursement)
 * @param requestedUnitValue (Hours submitted for the claim calculation)
 * @param requestedAmountValue (Amount Billed for the claim)
 * @param wrap 
 * @param batchId (Auto generated number)
 * @param URL 
 * @param schoolInvoiceId 
 * @return  `id`
 */
public static id newClaim(String schoolId, string termValue, string yearValue, string claimTypeValue, Decimal requestedUnitValue, Decimal requestedAmountValue, string batchId, string URL,String schoolInvoiceId) {

    map < string, decimal > unitNameActualUnit = new map < string, decimal > ();
    claim cl = new claim();
    cl.Educational_Institutes__c = schoolId;
    cl.Name = 'CL - ' + DateTime.now().millisecond();
    cl.Term__c = termValue;
    cl.Year__c = yearValue;
   // cl.Claim_Amount__c = wrap.claimAmountValue;
    cl.ClaimType = claimTypeValue;
    if (!string.isBlank(batchId)) {
        cl.BatchId__c = batchId;
    }
    if (string.isNotBlank(schoolInvoiceId)) {
        cl.School_Invoice__c = schoolInvoiceId;
    }

    
    if (requestedUnitValue != null) {
        cl.Estimated_Hours__c = requestedUnitValue;
    }

    if (requestedAmountValue != null) {
        cl.Requested_Amount__c = requestedAmountValue;
    }


    insert cl;
    return cl.id;
}

/**
 * Logic to calculate claim amount based on requested units and school rate.
 * @param requestedUnitValue 
 * @return  `ActualUnitClaimAmountWrapper`
 */
/*public static ActualUnitClaimAmountWrapper calculateClaimAmount(list < School_Rate__c > schoolRates,Decimal requestedUnitValue){

    Decimal totalUnitCost = 0.0;
    Decimal claimAmount = 0.0;
    ActualUnitClaimAmountWrapper wrap = new ActualUnitClaimAmountWrapper();
    map < string, string > coverageTypeRateCodeMap = new map < string, string > ();
    for (School_Rate__c schoolRate: schoolRates) {        
        totalUnitCost = totalUnitCost + schoolRate.Actual_Rate__c;
        coverageTypeRateCodeMap.put(schoolRate.Coverage_Type__c, schoolRate.Rate_Code__c);
    }
        claimAmount = totalUnitCost * requestedUnitValue;
        system.debug('claimAmount >>>>>>'+ claimAmount);
        wrap.claimAmountValue = claimAmount;
        wrap.mapCoverageTypeRateCode = coverageTypeRateCodeMap;
        return wrap;   
}*/

    @AuraEnabled(cacheable=true)
    public static List<Rate_Code__c> getClaimRateCodes(String schoolId) {
        try {
            Account  instType = [select id, Institution_Type__c,Sub_Type__c from Account where id =: schoolId WITH SECURITY_ENFORCED];
            List < Rate_Code__c > relationList ;
            
            relationList = [Select id, Name From Rate_Code__c where Educational_Institutes__c  = :schoolId 
            WITH SECURITY_ENFORCED ];          
                   
            return relationList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }       
    }
}