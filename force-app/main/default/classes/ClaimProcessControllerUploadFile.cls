/* Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/29/2021   Satish Nikam    11237 - T2 - Claim processing File Upload functionality Customization
**/

public with sharing class ClaimProcessControllerUploadFile {
    //Start-11237
    @AuraEnabled(cacheable=true) 
    public static List<file> getRelatedFiles(String recordId,list<string> claimFileIds){
        List<File> files = new List<File>();
        if(claimFileIds != null && !claimFileIds.isEmpty()){
            for(ContentVersion conVersion : [SELECT ContentDocumentId,CreatedDate,Description,FileExtension,FileType,Id,Title,VersionNumber FROM ContentVersion WHERE Id IN : claimFileIds ]){
                File file = new File();
                file.Title = conVersion.Title;
                file.Id = conVersion.ContentDocumentId;
                file.recordId = conVersion.Id;
                file.CreatedDate = conVersion.CreatedDate;
                file.Type = conVersion.FileType;
                files.add(file);
            }
        }
        return files;
    }

    public class File{
        @AuraEnabled public String Title;
        @AuraEnabled public String Type;
        @AuraEnabled public Id Id;
        @AuraEnabled public Id recordId;
        @AuraEnabled public Datetime CreatedDate;
    }
    //End-11237
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
    public static id createClaim(string strClaimData,list<string> coveragePlanId,list<string> coveragesPlans,list<string> claimFileIds) {

        List<ClaimInputData> flowClaimData = new List<ClaimInputData>();

        // Call the Flow
        Map<String, Object> params = new Map<String, Object>();
        params.put('claimDataList', flowClaimData);
        Flow.Interview.Claim_Creation_Flow claimFlow = new Flow.Interview.Claim_Creation_Flow(params);
        claimFlow.start();
        ///////////////////////////////////////////
        string claimId;
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

        map < string, decimal > upperClaimValue = new map < string, decimal > ();
        map < string, decimal > lowerClaimValue = new map < string, decimal > ();

        ActualUnitClaimAmountWrapper wrap = new ActualUnitClaimAmountWrapper();
        ActualUnitClaimAmountWrapper wrap1 = new ActualUnitClaimAmountWrapper();

        map < string, decimal > coverageAPIRateMap = new map < string, decimal > ();
        map < id, map < string, object >> mapCoverageIdAvailableCovgMap = new map < id, map < string, object >> ();
        map < string, object > mapCoverageUnitValue = new map < string, object > ();

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

        Map<String, Object> claimData = (Map<String, Object>)JSON.deserializeUntyped(strClaimData);
        String policyId = String.valueOf(claimData.get('policyId'));
        String schoolId = String.valueOf(claimData.get('schoolId'));
        String termValue = String.valueOf(claimData.get('termValue'));
        String yearValue = String.valueOf(claimData.get('yearValue'));
        Decimal requestedUnitValue = Integer.valueOf(claimData.get('requestedUnitValue'));
        Decimal requestedAmountValue = Integer.valueOf(claimData.get('requestedAmountValue'));
        String claimTypeValue = String.valueOf(claimData.get('claimTypeValue'));

        claim cl = new claim();

        //get the id of namedInsured (Account Owner)
         InsurancePolicy policy = [select id, Payment_Methodology__c, NameInsuredId from InsurancePolicy where id =: policyId WITH SECURITY_ENFORCED];

        if (policy != null) {
            nameinsuredId = policy.NameInsuredId;
            paymentMethod = policy.Payment_Methodology__c;
        }
        System.debug('schoolId >>' + schoolId);

        //get the instituition type of the School
        Account  instType = [select id, Institution_Type__c from Account where id =: schoolId WITH SECURITY_ENFORCED];
        string institutionType;
        if (instType != null) {
            institutionType = instType.Institution_Type__c;
            System.debug('institutionType >>' + institutionType);
        }


         list < School_Rate__c > schoolRates = getSchoolRates(institutionType, termValue,yearValue,schoolId);
        system.debug('avgSchoolRates' + schoolRates.size());
        
        system.debug('coveragePlanId' + coveragePlanId); 
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
                for (string str: CovgUnitList) {
                    if (ic.get(str) != null && (Decimal) ic.get(str) > 0) {
                        rateTypeLevelList.add(ic.Coverage_Type__c+'__c'+ ' '+ Category);
                        mapCoverageUnitValue.put(str, ic.get(str));
                    }
                    mapCoverageIdAvailableCovgMap.put(ic.id, mapCoverageUnitValue);
                }
            }

            rateTypeLevelList.add('Block '+ Category);
        }


            if ((category == institutionType || institutionType == 'Average Rate') && (category == 'University' || (category == 'College' && numberOfYears < 3))) {
                wrap = claimCalculations(institutionType, schoolRates, rateTypeLevelList, category,  requestedUnitValue,  paymentMethod,  requestedAmountValue, mapCoverageIdAvailableCovgMap, numberOfYears, false, false);
                system.debug('wrap value' + wrap);
            }else if (category == 'College' && numberOfYears > 2) {
                if((category == institutionType || institutionType == 'Average Rate')){
                    wrap = claimCalculations(institutionType, schoolRates, rateTypeLevelList, category,  requestedUnitValue,  paymentMethod,  requestedAmountValue, mapCoverageIdAvailableCovgMap, numberOfYears, false, false);
                    system.debug('wrap value ' + wrap);
                }
                lowerClaimValue = wrap.mapCoverageActualUnit;
                lowerClaimAmount = wrap.claimAmountValue;

                if (wrap.claimAmountDifference != null && wrap.claimAmountDifference > 0) {
                    paymentMethod = 'Calculate Based on Amount Paid';
                    requestedAmountValue = wrap.claimAmountDifference;
                    list < string > tempStringList = new list < string > {
                        'Tuition Upper Level',
                        'Local Upper Level'
                    };
                    rateTypeLevelList = tempStringList;
                    
                    
                    wrap1 = claimCalculations(institutionType, schoolRates, rateTypeLevelList, category,  requestedUnitValue,  paymentMethod,  requestedAmountValue, mapCoverageIdAvailableCovgMap, numberOfYears, false, false);

                    upperClaimAmount = wrap1.claimAmountValue;
                    wrap.claimAmountValue = lowerClaimAmount + upperClaimAmount;
                    upperClaimValue = wrap1.mapCoverageActualUnit;
                    wrap.mapCoverageActualUnit.putAll(upperClaimValue);
                }
            }
            else if ((institutionType == 'University' || institutionType == 'Average Rate') && category == 'Dorm') {
                wrap = claimCalculations(institutionType, schoolRates, rateTypeLevelList, category,  requestedUnitValue,  paymentMethod,  requestedAmountValue, mapCoverageIdAvailableCovgMap, numberOfYears, false, false);
            }

        
                
        if (requestedUnitValue != null) {
            cl.Estimated_Hours__c = requestedUnitValue;
        }

        cl.AccountId = nameinsuredId;
        cl.Educational_Institutes__c = schoolId;
        cl.Name = 'Claim - ' + DateTime.now().getTime();
        cl.PolicyNumberId = policyId;
        cl.Term__c = termValue;
        cl.Year__c = yearValue;
        cl.Claim_Amount__c = wrap.claimAmountValue;
        cl.ClaimType = claimTypeValue;
        cl.Requested_Amount__c = requestedAmountValue;
        cl.Payment_Methodology__c = paymentMethod;

        map < string, decimal > unitNameActualUnit = new map < string, decimal > ();
        unitNameActualUnit = wrap.mapCoverageActualUnit;

        if (unitNameActualUnit.containsKey('Tuition__c')) {
            cl.Tuition__c = unitNameActualUnit.get('Tuition__c');
        }

        if (unitNameActualUnit.containsKey('Tuition_Lower__c')) {
            cl.Tuition_Lower__c = unitNameActualUnit.get('Tuition_Lower__c');
        }

        if (unitNameActualUnit.containsKey('Tuition_Upper__c')) {
            cl.Tuition_Upper__c = unitNameActualUnit.get('Tuition_Upper__c');
        }

        if (unitNameActualUnit.containsKey('Local__c')) {
            cl.Local__c = unitNameActualUnit.get('Local__c');
        }

        if (unitNameActualUnit.containsKey('Local_Lower__c')) {
            cl.Local_Lower__c = unitNameActualUnit.get('Local_Lower__c');
        }

        if (unitNameActualUnit.containsKey('Local_Upper__c')) {
            cl.Local_Upper__c = unitNameActualUnit.get('Local_Upper__c');
        }

        if (unitNameActualUnit.containsKey('TDF__c')) {
            cl.TDF__c = unitNameActualUnit.get('TDF__c');
        }

        if (unitNameActualUnit.containsKey('Dormitory__c')) {
            cl.Dormitory__c = unitNameActualUnit.get('Dormitory__c');
        }

        //insert cl; 
        updateAttachemnts(claimFileIds,cl.id);//Task-11237
            //return the newly created claim id
            return cl.id;
    }
    //Task-11237 - Start
    public static void updateAttachemnts(List<string> claimFileIds, Id claimId){
        //update attachment owners
        if(claimFileIds != null && !claimFileIds.isEmpty() && String.IsNotBlank(claimId)){
            List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
            for(ContentVersion conVersion : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN :claimFileIds]){
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conVersion.ContentDocumentId;
                cDe.LinkedEntityId = claimId;
                cDe.ShareType = 'I';
                cDe.Visibility = 'AllUsers';
                cdLinkList.add(cDe);
        }

        if(!cdLinkList.isEmpty()){
            try{
                insert cdLinkList;//linking contentversion with claim
            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while linking contentversion with claim :'+ ex.getMessage());
            }
        }
            /*List<ContentDocumentLink> claimAttachments = new List<ContentDocumentLink>();
            List<ContentDocumentLink> policyAttachments = new List<ContentDocumentLink>();
            for(ContentDocumentLink  linkRecord :[SELECT ContentDocument.Id,ContentDocument.Title,ContentDocument.CreatedDate, ContentDocument.FileType,LinkedEntityId 
                                                  FROM ContentDocumentLink 
                                                  WHERE LinkedEntityId IN :claimFileIds]){
                ContentDocumentLink  newLinkRecord = linkRecord.clone(false, true, false, false);
                newLinkRecord.LinkedEntityId = claimId;
                claimAttachments.add(newLinkRecord);
                policyAttachments.add(linkRecord);
            }

            if(!claimAttachments.isEmpty()){
                try{
                    insert claimAttachments;//need to confirm with Manas in we need try catch here or do we need tp thwon an aura exception to the clien side
                }Catch(Exception ex){
                    //we can log error if needed
                    System.debug('Error while inserting Claim attachments :'+ ex.getMessage());
                    return;//if insert attachement fails on claim, no need to delete attachments from parent
                    //return 'Error while inserting Claim attachments :'+ ex.getMessage();
                }
            }*/

            /*if(!policyAttachments.isEmpty()){
                try{
                    delete policyAttachments;
                }Catch(Exception ex){
                    //we can log error if needed
                    System.debug('Error while remove policy attachments :'+ ex.getMessage());
                    //return 'Error while removing attachments from policy :'+ ex.getMessage();
                }
            }*/
        }       
    }
    //Task-11237 - End
    public static list < School_Rate__c > getSchoolRates(string institutionType, string termValue , String yearValue , String schoolId) {
        list < School_Rate__c > schoolRates;
        if(String.IsNotBlank(schoolId)){
            schoolRates = [Select Actual_Rate__c, Coverage_Type__c , Rate_Type__c from School_Rate__c 
            where Rate_Type__c = : institutionType AND Term__c =: termValue AND (Year__c =: yearValue) WITH SECURITY_ENFORCED];
        }else{
            schoolRates = [Select Actual_Rate__c, Coverage_Type__c from School_Rate__c where Rate_Type__c = : institutionType
            AND Term__c =: termValue AND (Year__c =: yearValue) WITH SECURITY_ENFORCED];
        }
        return schoolRates;
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

        /* Calculate the total Claim Amount based on Requested Units and 
         Rate from School Rate object if paymentMethod == 'Calculate Based on Units Requested' */
        if (!schoolRates.isEmpty()) {
            for (School_Rate__c schoolRate: schoolRates) {
                string temp = schoolRate.Coverage_Type__c + ' ' + schoolRate.Rate_Type__c;
                if (rateTypeLevelList.contains(temp)) {
                    coverageAPIRateMap.put(schoolRate.Coverage_Type__c, schoolRate.Actual_Rate__c);
                    if (paymentMethod == 'Calculate Based on Units Requested') {
                        if(schoolRate.Coverage_Type__c == 'Block'){
                            totalAmount = totalAmount + schoolRate.Actual_Rate__c;
                        }else{
                            totalAmount = totalAmount + (requestedUnitValue * schoolRate.Actual_Rate__c);
                        }
                        avgRateTotal = avgRateTotal + schoolRate.Actual_Rate__c;
                    }
                }
            }
        }

        system.debug('totalAmount >>>>>>>>>>> ' + totalAmount);

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
            //wrap.claimRemainingUnits = weightedAvg;
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
                system.debug('actualUnitTemp>>>>>>>>>>>>>>' + actualUnitTemp);
                claimAmount = totalAmount;
            }
        }

        system.debug('categoryActualUnitMap' + categoryActualUnitMap);
        system.debug('claimAmount' + claimAmount);
        wrap.mapCoverageActualUnit = categoryActualUnitMap;
        wrap.claimAmountValue = claimAmount;

        return wrap;
    }

    public static actualUnitClaimAmountWrapper claimCalculationsInstitutionCategoryDiff(list < School_Rate__c > schoolRates,string institutionType, string termValue, string Category, Decimal requestedUnitValue, string paymentMethod, decimal requestedAmountValue, list < string > rateTypeLevelList, map < id, map < string, object >> mapCoverageIdAvailableCovgMap, list < string > coverageTypeList, map < id, string > coverageIdTypeMap, Boolean isBundled, map < id, map < string, object >> instBundledMap, map < id, map < string, object >> avgBundledMap, Decimal numberOfYears) {

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
                    instituitonRateTypeRateLevel.add('Tuition__c University');
                } else if (tempCat == 'Local') {
                    instituitonRateTypeRateLevel.add('Local__c University');
                } else if (tempCat == 'TDF') {
                    instituitonRateTypeRateLevel.add('TDF__c University');
                }
            }
        }

        if (!schoolRates.isEmpty()) {
            for (School_Rate__c schoolRate: schoolRates) {
                system.debug('schoolRate.Rate_Type__c' + schoolRate.Rate_Type__c);
                system.debug('Category' + Category);

                if (schoolRate.Rate_Type__c == institutionType) {
                    string temp = schoolRate.Coverage_Type__c + ' ' + schoolRate.Rate_Type__c;
                    if (instituitonRateTypeRateLevel.contains(temp)) {
                        instituitionRateMap.put(schoolRate.Coverage_Type__c, schoolRate.Actual_Rate__c);
                        
                    }
                } else if (schoolRate.Rate_Type__c == 'Average Rate') {
                    string temp = schoolRate.Coverage_Type__c + ' ' + schoolRate.Rate_Type__c;
                    if (instituitonRateTypeRateLevel.contains(temp)) {
                        coverageAPIRateMap.put(schoolRate.Coverage_Type__c, schoolRate.Actual_Rate__c);
                        avgRateMap.put(schoolRate.Coverage_Type__c, schoolRate.Actual_Rate__c);
                    }
                }
            }
        }

        system.debug('instituitionRateMap' + instituitionRateMap);
        system.debug('avgRateMap' + avgRateMap);
        system.debug('coverageAPIRateMap' + coverageAPIRateMap);


        map < string, string > collegeUniversityMap = new map < string, string > {
            'Tuition__c' => 'Tuition',
            'Local__c' => 'Local',
            'Tuition_Lower__c' => 'Tuition',
            'Local_Lower__c' => 'Local',
            'Tuition_Upper__c' => 'Tuition',
            'Local_Upper__c' => 'Local',
            'TDF__c' => 'TDF'
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

        public Decimal claimAmountDifference {
            get;
            set;
        }

        public Decimal claimRemainingUnits {
            get;
            set;
        }

    }

}