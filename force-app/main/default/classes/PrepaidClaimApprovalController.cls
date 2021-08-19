public with sharing class PrepaidClaimApprovalController {
    
    @AuraEnabled
    public static claim claimRecord(id recordId) {
        try {
            
            claim cm = [SELECT Id,Estimated_Hours__c,Requested_Amount__c,ClaimType,Payment_Methodology__c,
            Status,Claim_Amount__c,Tuition__c,Tuition_Lower__c,Tuition_Upper__c,Local__c,Local_Lower__c,
            Local_Upper__c,Dormitory__c,TDF__c From claim WHERE id =: recordId];
            return cm;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string approvalProcess(id recordId) {      
        try {
            string str;
            
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Please approve the claim');
            id userId = UserInfo.getUserId();
            req1.setObjectId(recordId);

            // Submit on behalf of a specific submitter
            req1.setSubmitterId(userId);

            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Claim_Approval_2');
            //req1.setSkipEntryCriteria(true);

            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);

            // Verify the result
            System.assert(result.isSuccess());

            // Approve the submitted request
            // First, get the ID of the newly created item
            List < Id > newWorkItemIds = result.getNewWorkitemIds();

            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 =new Approval.ProcessWorkitemRequest();
            req2.setComments('Approved');
            req2.setAction('Approve');
           
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));

            // Submit the request for approval
            Approval.ProcessResult result2 = Approval.process(req2);

            str = 'Success';
            return str;

        } catch (Exception e) {           
            throw new AuraHandledException(e.getMessage());      
        }
    }

    @AuraEnabled
    public static  map < string, decimal > recalculateClaim(id recordId,Decimal requestedUnitValue, Decimal requestedAmountValue,string claimTypeValue, string paymentType) {
        try {            
            string str;
            String policyId;
            String schoolId;
            String termValue;
            String yearValue;
            List < Map < String, Object >> files;
            map < string, decimal > claimUnitAmountMap = new map < string, decimal > ();
            list<string> coveragesPlans  = new List<String>();
            List<Object> objList = new List<Object>();

            List<claim> cm = [SELECT Id,PolicyNumberId,Educational_Institutes__c,Term__c,Year__c From claim WHERE id =: recordId WITH SECURITY_ENFORCED];

            if(!cm.isEmpty()){
                policyId = cm[0].PolicyNumberId;
                schoolId = cm[0].Educational_Institutes__c;
                termValue = cm[0].Term__c;
                yearValue = cm[0].Year__c;
                list < InsurancePolicyCoverage > policyCoverageList = [Select id,Coverage_Type__c FROM InsurancePolicyCoverage where InsurancePolicyId =: policyId WITH SECURITY_ENFORCED];

                List<String> coveragePlanId = new List<String>();
                for(InsurancePolicyCoverage ipc : policyCoverageList)  
                {
                    coveragePlanId.add(ipc.Id);
                    coveragesPlans.add(ipc.Coverage_Type__c);
                } 

                List<String> rateCodeList = new List<String>();
                

                ActualUnitClaimAmountWrapper wrapper = processClaims(schoolId, termValue, yearValue, rateCodeList,claimTypeValue, requestedUnitValue, 
                coveragePlanId, coveragesPlans,files, requestedAmountValue, policyId, false, false);
    
                claimUnitAmountMap = wrapper.mapCoverageActualUnit;
                //System.debug('unitNameActualUnit................'+unitNameActualUnit);
                
                claimUnitAmountMap.put('ApprovedAmt' , wrapper.claimAmountValue);
            }
            return claimUnitAmountMap;

            //return str;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateClaim(id recordId,decimal requestedUnitValue, decimal requestedAmountVal,string claimType, string paymentType, Decimal claimAmountValue, Decimal actualUnitValue, String claimUnits){
        
        try {
            string str = '';
            List<ClaimUnitValues> c = (List<ClaimUnitValues>) JSON.deserialize(claimUnits, List<ClaimUnitValues>.class);
            system.debug('c..............'+c);
            System.debug('claimUnits........'+claimUnits);
            Map<String, Decimal> unitNameActualUnit = new Map<String, Decimal> ();
            for(ClaimUnitValues cvaal : c) {
                unitNameActualUnit.put(cvaal.label, Decimal.valueOf(cvaal.value));

            }
            list<claim> cm = [SELECT Id, Estimated_Hours__c,Requested_Amount__c, ClaimType, Payment_Methodology__c,
            Tuition__c,Tuition_Lower__c,Tuition_Upper__c, Local__c, Local_Lower__c, Local_Upper__c,Dormitory__c,TDF__c
            From claim  WHERE id =: recordId];
                 cm[0].Estimated_Hours__c = requestedUnitValue;
                 cm[0].Requested_Amount__c = requestedAmountVal;
                 cm[0].ClaimType = claimType;
                 cm[0].Payment_Methodology__c = paymentType;
                 //cm[0].Restrict_Update__c = true;
                 cm[0].Claim_Amount__c = claimAmountValue;
                 cm[0].Actual_Unit__c = actualUnitValue;
                // cm[0].ApprovedAmount = wrapper.claimAmountValue
                 if (unitNameActualUnit.containsKey('Tuition__c')) {
                    cm[0].Tuition__c = unitNameActualUnit.get('Tuition__c');
                }
        
                if (unitNameActualUnit.containsKey('Tuition_Lower__c')) {
                    cm[0].Tuition_Lower__c = unitNameActualUnit.get('Tuition_Lower__c');
                }
        
                if (unitNameActualUnit.containsKey('Tuition_Upper__c')) {
                    cm[0].Tuition_Upper__c = unitNameActualUnit.get('Tuition_Upper__c');
                }
        
                if (unitNameActualUnit.containsKey('Local__c')) {
                    cm[0].Local__c = unitNameActualUnit.get('Local__c');
                }
        
                if (unitNameActualUnit.containsKey('Local_Lower__c')) {
                    cm[0].Local_Lower__c = unitNameActualUnit.get('Local_Lower__c');
                }
        
                if (unitNameActualUnit.containsKey('Local_Upper__c')) {
                    cm[0].Local_Upper__c = unitNameActualUnit.get('Local_Upper__c');
                }
        
                if (unitNameActualUnit.containsKey('TDF__c')) {
                    cm[0].TDF__c = unitNameActualUnit.get('TDF__c');
                }
        
                if (unitNameActualUnit.containsKey('Dormitory__c')) {
                    cm[0].Dormitory__c = unitNameActualUnit.get('Dormitory__c');
                }

                 update cm[0];
            str = 'Success';
            return str;
        } catch (Exception e) {          
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ClaimUnitValues {
        public String label {get; set;}
        public String value {get; set;}
    }

    public static list < School_Rate__c > getSchoolRates(string institutionType, string termValue , String yearValue , String schoolId,List<String> rateCodeList) {
        list < School_Rate__c > schoolRates;
    
        if (institutionType == 'Average Rate'){
            schoolId = null;
        }
    
        if(rateCodeList != null && rateCodeList.size() > 0){
            schoolRates = [Select Actual_Rate__c, Coverage_Type__c,  Rate_Type__c,Rate_Code__c,Rate_Code__r.Calculation_Method__c from School_Rate__c 
            where (Rate_Code__r.Educational_Institutes__c =: schoolId and Rate_Type__c = : institutionType 
            AND Term__c =: termValue AND Year__c =: yearValue and Rate_Code__c =: rateCodeList)  WITH SECURITY_ENFORCED];
        }
        else{
            schoolRates = [Select Actual_Rate__c, Coverage_Type__c, Rate_Type__c,Rate_Code__c,Rate_Code__r.Calculation_Method__c from School_Rate__c 
            where Rate_Code__r.Educational_Institutes__c =: schoolId and Rate_Type__c = : institutionType AND Term__c =: termValue AND Year__c =: yearValue 
            and Default_Ind__c = true WITH SECURITY_ENFORCED];
        }
        return schoolRates;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Rate_Code__c> getClaimRateCodeCalculationMethod(List<String> claimRateCode) {
        try {
           
                List<Rate_Code__c> relationList = [Select Id,Calculation_Method__c From Rate_Code__c where id IN :claimRateCode
                WITH SECURITY_ENFORCED ];          
                  
            return relationList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }       
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Rate_Code__c> getClaimRateCodes(String schoolId) {
        try {
            Account  instType = [select id, Institution_Type__c,Sub_Type__c from Account where id =: schoolId WITH SECURITY_ENFORCED];
            List < Rate_Code__c > relationList ;
            
            relationList = [Select id, Name From Rate_Code__c where Educational_Institutes__c = :schoolId 
            WITH SECURITY_ENFORCED ];          
                   
            return relationList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }       
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ClaimItem> getClaimItem(List<String> insurancePolicyCoverageId , String year) {
        try {
                List<ClaimItem>  claimItems = [Select Rate_Code__c From  ClaimItem 
                        where InsurancePolicyCoverageId IN :insurancePolicyCoverageId and Year__c= :year 
                        and Rate_Code__c IN (Select Id from
                        Rate_Code__c where Calculation_Method__c = 'Year')   WITH SECURITY_ENFORCED];       
                return claimItems;
            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }       
    }

    public static void creatClaimItems(list < string > coveragePlanId, id claimId,map < string, string > coverageIdRateCodeMap,string termValue,string yearValue) {
        list < ClaimItem > claimItemList = new list < ClaimItem > ();
        if (!coveragePlanId.isEmpty()) {
            list < InsurancePolicyCoverage > covgList = [SELECT id,Coverage_Type__c
                FROM InsurancePolicyCoverage
                WHERE id IN: coveragePlanId
            ];
    
            if (!covgList.isEmpty()) {
                for(Integer i=0; i<covgList.size(); i++) {
                    ClaimItem ca = new ClaimItem();
                    ca.ClaimId = claimId;
                    ca.InsurancePolicyCoverageId = covgList[i].id;
                    ca.Name = 'CI - ' + DateTime.now().millisecond() + i;
                    ca.Term__c = termValue;
                    ca.Year__c = yearValue;
                    if(null != coverageIdRateCodeMap){
                        ca.Rate_Code__c = (String) coverageIdRateCodeMap.get(covgList[i].Coverage_Type__c + '__c');
                    }
                    claimItemList.add(ca);
                }
                insert claimItemList;
            }
        }
    }

    @AuraEnabled
public static ActualUnitClaimAmountWrapper processClaims(string schoolId, string termValue, string yearValue, List<String> rateCodeList ,string claimTypeValue, 
                        Decimal requestedUnitValue, list < string > coveragePlanId, list<string> coveragesPlans,List < Map < String, Object >> files, Decimal requestedAmountValue, 
                        String policyId, Boolean isSchoolInvoice, Boolean paymentMethodUpdated) {

    Id claimId;
    string paymentMethod;
    string nameinsuredId;
    String category;
    Decimal numberOfYears;
    Decimal avgRateTotal = 0;
    Decimal totalAmount = 0;
    Decimal availableAmount = 0;
    Decimal lowerClaimAmount = 0;
    Decimal upperClaimAmount = 0;
    Boolean isBundledTDFCovg = false;
    Boolean isHousingPrePaymentExists = false;
    map < string, decimal > upperClaimValue = new map < string, decimal > ();
    map < string, decimal > lowerClaimValue = new map < string, decimal > ();
    ActualUnitClaimAmountWrapper wrap = new ActualUnitClaimAmountWrapper();
    ActualUnitClaimAmountWrapper wrap1 = new ActualUnitClaimAmountWrapper();
    map < string, decimal > coverageAPIRateMap = new map < string, decimal > ();
    map < id, map < string, object >> mapCoverageIdAvailableCovgMap = new map < id, map < string, object >> ();
    map < string, object > mapCoverageUnitValue = new map < string, object > ();
    map < id, string > coverageIdTypeMap = new map < id, string > ();       
    list < string > coverageTypeList = new list < string > ();
    map < id, map < string, object >> instBundledMap = new map < id, map < string, object >> ();
    map < id, map < string, object >> avgBundledMap = new map < id, map < string, object >> ();
    map < id, map < string, object >> avgCollegeFourYearPlan = new map < id, map < string, object >> ();
    

    list < string > covgUnitList = new list < string > {
        'Local__c',
        'Local_Upper__c',
        'Local_Lower__c',
        'Tuition__c',
        'Tuition_Upper__c',
        'Tuition_Lower__c',
        'Dormitory__c',
        'TDF__c'
    };

    list < string > rateTypeLevelList = new list < string > ();
    try
    {          
        InsurancePolicy policy = [select id, Payment_Methodology__c,NameInsuredId from InsurancePolicy where id =: policyId WITH SECURITY_ENFORCED];

        List<Authorization_Exception__c> authorizeExceptions = [select Policy_Payment_Method__c from Authorization_Exception__c where Insurance_Policy__c =: policyId and Account__c = :schoolId WITH SECURITY_ENFORCED];
        
        Account  instType = [select id, Institution_Type__c,Sub_Type__c from Account where id =: schoolId WITH SECURITY_ENFORCED];
        string institutionType;
        String subType = 'In State';
        if (instType != null) {
            institutionType = instType.Institution_Type__c;
            subType = instType.Sub_Type__c;
        }

        if (policy != null) {
            nameinsuredId = policy.NameInsuredId;
            //paymentMethod = policy.Payment_Methodology__c;
        }

        if(!authorizeExceptions.isEmpty()){
            paymentMethod = authorizeExceptions[0].Policy_Payment_Method__c;
        }else if (subType == 'In State'){
            paymentMethod = 'Calculate Based on Units Requested';
        }else {
            paymentMethod = 'Do Not Pay';
        }
          //Logic to check if Prepayment for Housing exists for the academic year
          if(coveragesPlans.contains('Dormitory')){
            String method;
            List<Rate_Code__c> claimRateCodes = getClaimRateCodeCalculationMethod(rateCodeList);

             method = claimRateCodes[0].Calculation_Method__c;
            
            if(method == 'Year'){
                List<ClaimItem> claimItems = getClaimItem(coveragePlanId,yearValue);
                if(null != claimItems && claimItems.size() >0){
                    paymentMethod = 'Do Not Pay';
                    isHousingPrePaymentExists = true;
                }
            }
         } 
            //get the instituition type of the School
            list < School_Rate__c > schoolRates = getSchoolRates(institutionType, termValue,yearValue,schoolId,rateCodeList);

            List <InsurancePolicyCoverage> covgList = new list<InsurancePolicyCoverage>();
            //get the coverages for the Policy
            if (!coveragePlanId.isEmpty()) {
                covgList = [SELECT id,Product__c,Tuition__c,
                    Tuition_Lower__c,Tuition_Upper__c,Local_Upper__c,Local_Lower__c,
                    TDF__c,Local__c,Category,Dormitory__c,Coverage_Type__c,Number_of_Years__c
                    FROM InsurancePolicyCoverage WHERE id IN: coveragePlanId WITH SECURITY_ENFORCED];
            }

            if (!covgList.isEmpty()) {
                numberOfYears = covgList[0].Number_of_Years__c;
                category = covgList[0].Category;   
                        
                for (InsurancePolicyCoverage ic: covgList) {
                    mapCoverageUnitValue = new map<string,object>();
                    coverageIdTypeMap.put(ic.id, ic.Coverage_Type__c);
                    coverageTypeList.add(ic.Coverage_Type__c);
                    if (ic.category == 'College' || ic.category == 'Bundled') {
                        if (ic.Coverage_Type__c == 'Tuition') {
                            rateTypeLevelList.add('Tuition_Lower__c');
                        } else if (ic.Coverage_Type__c == 'Local') {
                            rateTypeLevelList.add('Local_Lower__c');
                        }
                    }else{
                        rateTypeLevelList.add(ic.Coverage_Type__c+'__c');
                    }
                    for (string str: CovgUnitList) {
                        if (ic.get(str) != null && (Decimal) ic.get(str) > 0) {
                            mapCoverageUnitValue.put(str, ic.get(str));
                        }
                        mapCoverageIdAvailableCovgMap.put(ic.id, mapCoverageUnitValue);
                    }
                }

                rateTypeLevelList.add('Block');
            }

            list < string > universityCovgList = new list < string > {
                'Tuition__c',
                'Local__c',
                'TDF__c'
            };

            list < string > collegeCovgList = new list < string > {
                'Tuition__c',
                'Local__c'
            };
            
            if ((category == institutionType || institutionType == 'Average Rate') && category != 'Bundled' && category != 'Dormitory') {
                system.debug('no of years' + numberOfYears);
                if (category == 'University' || (category == 'College' && numberOfYears < 3)) {
                    wrap = claimCalculations(institutionType, schoolRates, rateTypeLevelList, category,  requestedUnitValue,  paymentMethod,  requestedAmountValue,  mapCoverageIdAvailableCovgMap, numberOfYears, false, isSchoolInvoice);
                    system.debug('wrap value' + wrap);
                } else if (category == 'College' && numberOfYears > 2) {
                    wrap = claimCalculations(institutionType, schoolRates, rateTypeLevelList, category,  requestedUnitValue,  paymentMethod,  requestedAmountValue,  mapCoverageIdAvailableCovgMap, numberOfYears, false, isSchoolInvoice);
                    system.debug('wrap value ' + wrap);
                    lowerClaimValue = wrap.mapCoverageActualUnit;
                    lowerClaimAmount = wrap.claimAmountValue;
                    if (wrap.claimAmountDifference != null && wrap.claimAmountDifference > 0) {
                        paymentMethod = 'Calculate Based on Amount Paid';
                        requestedAmountValue = wrap.claimAmountDifference;
                        list < string > tempStringList = new list < string > {
                            'Tuition_Upper_Level__c College',
                            'Local_Upper_Level__c College'
                        };
                        rateTypeLevelList = tempStringList;
                        wrap1 = claimCalculations(institutionType, schoolRates, rateTypeLevelList, category,  requestedUnitValue,  paymentMethod,  requestedAmountValue,  mapCoverageIdAvailableCovgMap, numberOfYears, false, isSchoolInvoice);
                        upperClaimAmount = wrap1.claimAmountValue;
                        wrap.claimAmountValue = lowerClaimAmount + upperClaimAmount;
                        upperClaimValue = wrap1.mapCoverageActualUnit;
                        wrap.mapCoverageActualUnit.putAll(upperClaimValue);
                    }
                }
            } 
            else if (category != institutionType && category != 'Bundled' && category != 'Dormitory') {
                if (category == 'College' && numberOfYears > 2) {
                    for (Id ids: mapCoverageIdAvailableCovgMap.keyset()) {
                        map < string, object > instMap = new map < string, object > ();
                        map < string, object > avgMap = new map < string, object > ();
                        map < string, object > avgCollegeMap = new map < string, object > ();

                        map < string, object > mapUnitAvailableValues = mapCoverageIdAvailableCovgMap.get(ids);
                        string covgType = coverageIdTypeMap.get(ids);

                        for (string str: mapUnitAvailableValues.keyset()) {
                            if (covgType == 'Tuition') {
                                instMap.put('Tuition__c', mapUnitAvailableValues.get('Tuition__c'));
                                avgMap.put('Tuition_Lower__c', mapUnitAvailableValues.get('Tuition_Lower__c'));
                                avgCollegeMap.put('Tuition_Upper__c', mapUnitAvailableValues.get('Tuition_Upper__c'));
                            } else if (covgType == 'Local') {
                                instMap.put('Local__c', mapUnitAvailableValues.get('Local__c'));
                                avgMap.put('Local_Lower__c', mapUnitAvailableValues.get('Local_Lower__c'));
                                avgCollegeMap.put('Local_Upper__c', mapUnitAvailableValues.get('Local_Upper__c'));
                            }
                        }
                        instBundledMap.put(ids, instMap);
                        avgBundledMap.put(ids, avgMap);
                        avgCollegeFourYearPlan.put(ids, avgCollegeMap);
                    }
                    wrap = claimCalculationsInstitutionCategoryDiff(schoolRates,institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap, true, instBundledMap, avgBundledMap, numberOfYears);

                    lowerClaimValue = wrap.mapCoverageActualUnit;
                    lowerClaimAmount = wrap.claimAmountValue;
                    if (wrap.claimAmountDifference != null && wrap.claimAmountDifference > 0) {
                        paymentMethod = 'Calculate Based on Amount Paid';
                        requestedAmountValue = wrap.claimAmountDifference;
                        list < string > tempStringList = new list < string > {
                            'Tuition_Upper_Level__c College',
                            'Local_Upper_Level__c College'
                        };
                        rateTypeLevelList = tempStringList;
                        wrap1 = claimCalculationsInstitutionCategoryDiff(schoolRates,institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap, true, instBundledMap, avgCollegeFourYearPlan, numberOfYears);
                        upperClaimAmount = wrap1.claimAmountValue;
                        wrap.claimAmountValue = lowerClaimAmount + upperClaimAmount;
                        upperClaimValue = wrap1.mapCoverageActualUnit;
                        wrap.mapCoverageActualUnit.putAll(upperClaimValue);
                    }
                } else{
                        wrap = claimCalculationsInstitutionCategoryDiff(schoolRates,institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap, false, instBundledMap, avgBundledMap, numberOfYears);
                    }
            } 
            else if (category == 'Dormitory' && (institutionType == 'University' || institutionType == 'Average Rate')) {
                    wrap = claimCalculations(institutionType, schoolRates, rateTypeLevelList, category,  requestedUnitValue,  paymentMethod,  requestedAmountValue,  mapCoverageIdAvailableCovgMap, numberOfYears, false, isSchoolInvoice);  
            }

            if(paymentMethod == 'Do Not Pay' || String.isBlank(paymentMethod)){
                wrap.claimStatus = 'Rejected - Authorization not on record';
            }

            if(isHousingPrePaymentExists){
                wrap.claimStatus = 'Rejected - Housing Prepayment exists for academic year.';
            }

            wrap.paymentMethod = paymentMethod;
            wrap.nameInsuredId = nameinsuredId;

    }catch (Exception e){
        String errorMsg = e.getMessage();
        throw new AuraHandledException(errorMsg);
    }
        return wrap;
}

public static ActualUnitClaimAmountWrapper claimCalculations(String institutionType, list < School_Rate__c > schoolRates, list<string> rateTypeLevelList,string category, Decimal requestedUnitValue, string paymentMethod, decimal requestedAmountValue, map < id, map < string, object >> mapCoverageIdAvailableCovgMap, decimal numberOfYears, Boolean isBundled, Boolean isSchoolInvoice) {
    Decimal totalAmount = 0;
    Decimal availableAmount = 0;
    map < string, decimal > coverageAPIRateMap = new map < string, decimal > ();
    Decimal avgRateTotal = 0;
    Decimal weightedAvg;
    ActualUnitClaimAmountWrapper wrap = new ActualUnitClaimAmountWrapper();
    map < string, decimal > categoryActualUnitMap = new map < string, decimal > ();
    Decimal actualUnitTemp = 0;
    decimal claimAmount = 0;
    decimal blockAmount = 0 ;
    decimal maxDormRate = 0;

    map < string, string > coverageTypeRateCodeMap = new map < string, string > ();

    /* Calculate the total Claim Amount based on Requested Units and 
     Rate from School Rate object if paymentMethod == 'Calculate Based on Units Requested' */
    if (!schoolRates.isEmpty()) {
        for (School_Rate__c schoolRate: schoolRates) {
            //string temp = schoolRate.Coverage_Type__c + ' ' + schoolRate.Rate_Type__c;
            string temp = schoolRate.Coverage_Type__c;
            system.debug('rateTypeLevelList >>>>>>'+ rateTypeLevelList);
            if (rateTypeLevelList.contains(temp)) {
                coverageAPIRateMap.put(schoolRate.Coverage_Type__c, schoolRate.Actual_Rate__c);
                coverageTypeRateCodeMap.put(schoolRate.Coverage_Type__c, schoolRate.Rate_Code__c);
                if(schoolRate.Rate_Code__r.Calculation_Method__c == 'Flat' && category != 'Dormitory' 
                    && institutionType == schoolRate.Rate_Type__c && paymentMethod != 'Do Not Pay'){
                    blockAmount = blockAmount + schoolRate.Actual_Rate__c;
                    system.debug('Block Fee >>>>>>'+ blockAmount);
                }
                
                if((schoolRate.Rate_Code__r.Calculation_Method__c == 'Semester' || schoolRate.Rate_Code__r.Calculation_Method__c == 'Year')
                    && paymentMethod != 'Do Not Pay'){
                        totalAmount = totalAmount + schoolRate.Actual_Rate__c;
                        system.debug('Semester >>>>>>'+ totalAmount);
                    
                }
                if (paymentMethod == 'Calculate Based on Units Requested') {
                    if(schoolRate.Rate_Code__r.Calculation_Method__c == 'Hour'){
                        totalAmount = totalAmount + (requestedUnitValue * schoolRate.Actual_Rate__c);
                        avgRateTotal = avgRateTotal + schoolRate.Actual_Rate__c;
                    }                       
                }
            }
        }
    }

    system.debug('totalAmount >>>>>>>>>>> ' + totalAmount);
    system.debug('coverageTypeRateCodeMap >>>>>>'+ coverageTypeRateCodeMap);
    /* Get the available amount based on available units on the coverage 
      and the rate from School Rate for those Coverage Units */
    for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
        map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
        for (string str: tempMap.keyset()) {
            if (coverageAPIRateMap.containsKey(str)) {
                if ((Decimal)(tempMap.get(str)) > 0) {
                    availableAmount = availableAmount + (Decimal)(tempMap.get(str)) * coverageAPIRateMap.get(str);
                }
            }
        }
    }
    system.debug('availableAmount>>>>>>>>>>>>>>' + availableAmount);

    if (isBundled && institutionType == 'Average Rate' && paymentMethod == 'Calculate Based on Units Requested') {
        weightedAvg = availableAmount / avgRateTotal;
    }

    if (paymentMethod == 'Calculate Based on Amount Paid' && requestedAmountValue > 0) {
        totalAmount = requestedAmountValue;
    }

    if (availableAmount == 0) {
        for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
            map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
            for (string str: tempMap.keyset()) {
                if (coverageAPIRateMap.containsKey(str)) {
                    categoryActualUnitMap.put(str, 0);
                }
            }
        }

        wrap.mapCoverageActualUnit = categoryActualUnitMap;
        wrap.claimAmountValue = 0;

        if ((category == 'College' && numberOfYears > 2) || isBundled || isSchoolInvoice) {
            wrap.claimAmountDifference = totalAmount - availableAmount;
        }
    }else {

        Decimal percentageVal = (totalAmount / availableAmount) * 100;
        system.debug('percentageVal' + percentageVal);

        if (percentageVal >= 100) {
            if ((category == 'College' && numberOfYears > 2) || isBundled || isSchoolInvoice) {
                wrap.claimAmountDifference = totalAmount - availableAmount;
            }
            for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
                map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
                for (string str: tempMap.keyset()) {
                    if (coverageAPIRateMap.containsKey(str)) {
                        categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                    }
                }
            }
            claimAmount = availableAmount;

        } else {
            for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
                map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
                for (string str: tempMap.keyset()) {
                    if (coverageAPIRateMap.containsKey(str)) {
                        actualUnitTemp = ((Decimal)(tempMap.get(str)) * percentageVal) / 100;
                        categoryActualUnitMap.put(str, actualUnitTemp);
                    }
                }
            }
            claimAmount = totalAmount ;
        }
    }

    //uncomment for block logic
  /*  if(blockAmount >0){
        claimAmount = claimAmount + blockAmount;
    }*/


    system.debug('categoryActualUnitMap' + categoryActualUnitMap);
    system.debug('claimAmount' + claimAmount);
    wrap.mapCoverageActualUnit = categoryActualUnitMap;
    wrap.claimAmountValue = claimAmount;
    wrap.mapCoverageTypeRateCode = coverageTypeRateCodeMap;

    return wrap;
}

public static ActualUnitClaimAmountWrapper claimCalculationsInstitutionCategoryDiff(list < School_Rate__c > schoolRates,string institutionType, string termValue, string Category, Decimal requestedUnitValue, string paymentMethod, decimal requestedAmountValue, list < string > rateTypeLevelList, map < id, map < string, object >> mapCoverageIdAvailableCovgMap, list < string > coverageTypeList, map < id, string > coverageIdTypeMap, Boolean isBundled, map < id, map < string, object >> instBundledMap, map < id, map < string, object >> avgBundledMap, Decimal numberOfYears) {

    decimal totalRateAmount = 0;
    decimal requestedAmount = 0;
    string claimAmountActualUnit;
    decimal claimAmount = 0;
    decimal totalAmount = 0;
    decimal totalAmountUnitsNotAvailable = 0;
    decimal averageAmount = 0;

    map < string, decimal > categoryActualUnitMap = new map < string, decimal > ();
    map < string, decimal > categoryRate = new map < string, decimal > ();
    map < string, decimal > avgRateMap = new map < string, decimal > ();
    map < string, decimal > instituitionRateMap = new map < string, decimal > ();
    actualUnitClaimAmountWrapper wrap = new actualUnitClaimAmountWrapper();
    map < string, decimal > coverageAPIRateMap = new map < string, decimal > ();
    Boolean isUnitsAvailable = True;
    Boolean secondClaimRequired = false;

    list < string > instituitonRateTypeRateLevel = new list < string > ();
    for (id covgid: coverageIdTypeMap.keyset()) {
        string tempCat = coverageIdTypeMap.get(covgid);
        if (institutionType == 'College') {
            if (tempCat == 'Tuition') {
                instituitonRateTypeRateLevel.add('Tuition_Lower_Level__c');
            } else if (tempCat == 'Local') {
                instituitonRateTypeRateLevel.add('Local_Lower_Level__c');
            }
        } else if (institutionType == 'University') {
            if (tempCat == 'Tuition') {
                instituitonRateTypeRateLevel.add('Tuition__c');
            } else if (tempCat == 'Local') {
                instituitonRateTypeRateLevel.add('Local__c');
            } else if (tempCat == 'TDF') {
                instituitonRateTypeRateLevel.add('TDF__c');
            }
        }
    }

    if (!schoolRates.isEmpty()) {
        for (School_Rate__c schoolRate: schoolRates) {
            if (schoolRate.Rate_Type__c == institutionType) {
                string temp = schoolRate.Coverage_Type__c;
                if (instituitonRateTypeRateLevel.contains(temp)) {
                    instituitionRateMap.put(schoolRate.Coverage_Type__c, schoolRate.Actual_Rate__c);
                    
                }
            } else if (schoolRate.Rate_Type__c == 'Average Rate') {
                //string temp = schoolRate.Coverage_Type__c + ' ' + schoolRate.Rate_Type__c;
                string temp = schoolRate.Coverage_Type__c;
                if (rateTypeLevelList.contains(temp)) {
                    coverageAPIRateMap.put(schoolRate.Coverage_Type__c, schoolRate.Actual_Rate__c);
                    avgRateMap.put(schoolRate.Coverage_Type__c, schoolRate.Actual_Rate__c);
                }
            }else if (schoolRate.Rate_Type__c != institutionType) {
                string temp = schoolRate.Coverage_Type__c;
                if (instituitonRateTypeRateLevel.contains(temp)) {
                    instituitionRateMap.put(schoolRate.Coverage_Type__c, schoolRate.Actual_Rate__c);
                    
                }
            }
        }
    }

    system.debug('instituitionRateMap >>>>>>>>>>>>' + instituitionRateMap + 'avgRateMap >>>>>>>>>>>>>>>' + avgRateMap + 'coverageAPIRateMap' + coverageAPIRateMap);

    map < string, string > collegeUniversityMap = new map < string, string > {
        'Tuition__c' => 'Tuition__c',
        'Local__c' => 'Local__c',
        'Tuition_Lower__c' => 'Tuition__c',
        'Local_Lower__c' => 'Local__c',
        'Tuition_Upper__c' => 'Tuition__c',
        'Local_Upper__c' => 'Local__c',
        'TDF__c' => 'TDF__c'
    };

    if (isBundled || (category == 'College' && numberOfYears > 2)) {
        for (id coverageId: instBundledMap.keyset()) {
            map < string, object > tempMap = instBundledMap.get(coverageId);
            for (string str: tempMap.keyset()) {
                if (instituitionRateMap.containsKey(collegeUniversityMap.get(str))) {
                    if (paymentMethod == 'Calculate Based on Units Requested') {
                        totalAmount = totalAmount + instituitionRateMap.get(collegeUniversityMap.get(str)) * requestedUnitValue;
                    }
                }
            }
        }
    } else {
        for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
            map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
            for (string str: tempMap.keyset()) {
                if (instituitionRateMap.containsKey(collegeUniversityMap.get(str))) {
                    if (paymentMethod == 'Calculate Based on Units Requested') {
                        totalAmount = totalAmount + instituitionRateMap.get(collegeUniversityMap.get(str)) * requestedUnitValue;
                    }
                }
            }
        }
    }

    if (paymentMethod == 'Calculate Based on Amount Paid') {
        totalAmount = requestedAmountValue;
    }

    system.debug('totalAmount' + totalAmount);

    if (isBundled || (category == 'College' && numberOfYears > 2)) {
        for (id coverageId: avgBundledMap.keyset()) {
            map < string, object > tempMap = avgBundledMap.get(coverageId);
            for (string str: tempMap.keyset()) {
                if ((Decimal)(tempMap.get(str)) > 0) {
                    averageAmount = averageAmount + avgRateMap.get(collegeUniversityMap.get(str)) * (Decimal)(tempMap.get(str));
                }
            }
        }
    } else {
        for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
            map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
            for (string str: tempMap.keyset()) {
                if (coverageAPIRateMap.containsKey(str)) {
                    if ((Decimal)(tempMap.get(str)) > 0) {
                        averageAmount = averageAmount + avgRateMap.get(collegeUniversityMap.get(str)) * (Decimal)(tempMap.get(str));
                    }
                }
            }
        }
    }
    system.debug('averageAmount' + averageAmount);

    if (averageAmount == 0) {
        for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
            map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
            for (string str: tempMap.keyset()) {
                categoryActualUnitMap.put(str, 0);
            }
        }

        wrap.mapCoverageActualUnit = categoryActualUnitMap;
        wrap.claimAmountValue = 0;

        if (category == 'College' && numberOfYears > 2 || isBundled) {
            wrap.claimAmountDifference = totalAmount - averageAmount;
        }

    } else {
        Decimal percentageVal = (totalAmount / averageAmount) * 100;
        system.debug('percentageVal' + percentageVal);

        if (category == 'College' && numberOfYears > 2 || isBundled) {
            wrap.claimAmountDifference = totalAmount - averageAmount;
        }

        if (percentageVal >= 100) {
            if (isBundled || (category == 'College' && numberOfYears > 2)) {
                secondClaimRequired = true;
                for (id coverageId: avgBundledMap.keyset()) {
                    map < string, object > tempMap = avgBundledMap.get(coverageId);
                    for (string str: tempMap.keyset()) {
                        if (paymentMethod == 'Calculate Based on Units Requested') {
                            if ((requestedUnitValue * percentageVal) / 100 > (Decimal)(tempMap.get(str))) {
                                categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                            } else {
                                categoryActualUnitMap.put(str, (requestedUnitValue * percentageVal) / 100);
                            }
                        } else {
                            categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                        }
                    }
                }
                claimAmount = averageAmount;                 
                if (!secondClaimRequired) {
                    wrap.claimAmountDifference = 0;
                }

            } else {
                for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
                    map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
                    for (string str: tempMap.keyset()) {
                        if (paymentMethod == 'Calculate Based on Units Requested') {
                            if ((requestedUnitValue * percentageVal) / 100 > (Decimal)(tempMap.get(str))) {
                                categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                                isUnitsAvailable = false;
                            } else {
                                categoryActualUnitMap.put(str, (requestedUnitValue * percentageVal) / 100);
                            }
                        } else {
                            categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                        }
                    }
                }
                claimAmount = averageAmount;
            }

        } else {
            if (isBundled || (category == 'College' && numberOfYears > 2)) {
                for (id coverageId: avgBundledMap.keyset()) {
                    map < string, object > tempMap = avgBundledMap.get(coverageId);
                    for (string str: tempMap.keyset()) {
                        if (coverageAPIRateMap.containsKey(str)) {
                            categoryActualUnitMap.put(str, ((Decimal)(tempMap.get(str)) * percentageVal) / 100);
                        }
                    }
                }
                claimAmount = totalAmount;
            } else {
                for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
                    map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
                    for (string str: tempMap.keyset()) {
                        if (coverageAPIRateMap.containsKey(str)) {
                            categoryActualUnitMap.put(str, ((Decimal)(tempMap.get(str)) * percentageVal) / 100);
                        }
                    }
                }
                claimAmount = totalAmount;
            }
        }
        system.debug('categoryActualUnitMap' + categoryActualUnitMap);
        system.debug('claimAmount' + claimAmount);
        wrap.mapCoverageActualUnit = categoryActualUnitMap;
        wrap.claimAmountValue = claimAmount;
    }

    return wrap;
}

public class ActualUnitClaimAmountWrapper {
    public Decimal claimAmountValue {
        get;
        set;
    }
    public map < string, decimal > mapCoverageActualUnit {
        get;
        set;
    }

    public map < string, string > mapCoverageTypeRateCode {
        get;
        set;
    }

    public Decimal claimAmountDifference {
        get;
        set;
    }

    public Decimal claimRemainingUnits {
        get;
        set;
    }

    public String claimStatus {
        get;
        set;
    }

    public String paymentMethod {
        get;
        set;
    }

    public String nameInsuredId {
        get;
        set;
    }
}

}