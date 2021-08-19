/*claim Process cmp*/

public inherited sharing class ClaimProcessApex {

    @AuraEnabled
    public static map < string, string > coveragesTypes(string recordIdValue) {
        try {
            List < InsurancePolicyCoverage > insurancePolicyCoveragesList = [SELECT Id,
                coverageName,
                InsurancePolicyId
                FROM InsurancePolicyCoverage
                where InsurancePolicyId =: recordIdValue
            ];

            map < string, string > coverageMap = new map < string, string > ();
            if (!insurancePolicyCoveragesList.isEmpty()) {
                for (InsurancePolicyCoverage pc: insurancePolicyCoveragesList) {
                    coverageMap.put(pc.coverageName, pc.id);
                }
            }
            return coverageMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list < string > claimTerm() {
        try {
            List < String > pickListValuesList = new List < String > ();
            Schema.DescribeFieldResult fieldResult = Claim.Term__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal: ple) {
                pickListValuesList.add(pickListVal.getLabel());
            }
            return pickListValuesList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static map < string, string > paymentMethodology() {
        try {
            map < String, string > pickListValuesMap = new map < String, string > ();
            Schema.DescribeFieldResult fieldResult = Claim.Payment_Methodology__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal: ple) {
                pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
            return pickListValuesMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list < string > claimTypes() {
        try {
            List < String > pickListValuesList = new List < String > ();
            Schema.DescribeFieldResult fieldResult = Claim.ClaimType.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal: ple) {
                pickListValuesList.add(pickListVal.getLabel());
            }
            return pickListValuesList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list < string > claimYears() {
        try {
            List < String > pickListValuesList = new List < String > ();
            Schema.DescribeFieldResult fieldResult = Claim.Year__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal: ple) {
                pickListValuesList.add(pickListVal.getLabel());
            }
            return pickListValuesList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void creatClaimItems(list < string > coveragePlanId, id claimId) {
        list < ClaimItem > claimItemList = new list < ClaimItem > ();
        if (!coveragePlanId.isEmpty()) {
            list < InsurancePolicyCoverage > covgList = [SELECT id
                FROM InsurancePolicyCoverage
                WHERE id IN: coveragePlanId
            ];

            if (!covgList.isEmpty()) {
                for (InsurancePolicyCoverage pc: covgList) {
                    ClaimItem ca = new ClaimItem();
                    ca.ClaimId = claimId;
                    ca.InsurancePolicyCoverageId = pc.id;
                    ca.Name = 'Claim Item - ' + DateTime.now().getTime();

                    claimItemList.add(ca);
                }
                insert claimItemList;
            }
        }
    }

    //public static void claimCalculationsInstitutionCategoryDiff(string paymentMethodval, string institutionType, string termValue, Decimal rateAmountInstitution, Decimal requestedUnitValue, list < string > ratetype, map < string, list < string >> catLevelRate, String category, Decimal ActualUnit, Decimal claimAmount, map < string, list < string > > mapCategoryRateType, Decimal remainingUnits, Boolean Flag, Decimal requestedAmountValue) {
    public static actualUnitClaimAmountWrapper claimCalculationsInstitutionCategoryDiff(string institutionType, string termValue, string Category, Decimal requestedUnitValue, string paymentMethod, decimal requestedAmountValue, list < string > rateTypeLevelList, map < id, map < string, object >> mapCoverageIdAvailableCovgMap, list < string > coverageTypeList, map < id, string > coverageIdTypeMap, Boolean isBundled, map < id, map < string, object >> instBundledMap, map < id, map < string, object >> avgBundledMap, Decimal numberOfYears) {

        decimal totalRateAmount = 0;
        decimal requestedAmount = 0;
        string claimAmountActualUnit;
        decimal claimAmount = 0;
        decimal totalAmount = 0;
        decimal totalAmountUnitsNotAvailable = 0;
        decimal averageAmount = 0;
        decimal ActualUnit;
        map < string, decimal > categoryActualUnitMap = new map < string, decimal > ();
        map < string, decimal > categoryRate = new map < string, decimal > ();
        map < string, decimal > avgRateMap = new map < string, decimal > ();
        map < string, decimal > instituitionRateMap = new map < string, decimal > ();
        actualUnitClaimAmountWrapper wrap = new actualUnitClaimAmountWrapper();
        map < string, decimal > coverageAPIRateMap = new map < string, decimal > ();
        Boolean isUnitsAvailable = True;
        Boolean secondClaimRequired = false;



        //list < Average_School_Rates__c > avgSchoolRates = averageSchoolRates(institutionType, termValue);
        //system.debug('avgSchoolRates' + avgSchoolRates.size());
        list < Average_School_Rates__c > avgSchoolRates = [Select Rate__c,
            Institution_Type__c,
            Coverage_API_Name__c,
            Coverage_Type__c,
            Rate_Level__c
            from Average_School_Rates__c
            where(Institution_Type__c =: 'Average Rate'
                OR Institution_Type__c =: institutionType)
            AND Term__c =: termValue
            AND Coverage_Type__c IN: coverageTypeList
        ];

        list < string > instituitonRateTypeRateLevel = new list < string > ();
        for (id covgid: coverageIdTypeMap.keyset()) {
            string tempCat = coverageIdTypeMap.get(covgid);
            if (institutionType == 'College') {
                if (tempCat == 'Tuition') {
                    instituitonRateTypeRateLevel.add('Tuition Lower Level');
                } else if (tempCat == 'Local') {
                    instituitonRateTypeRateLevel.add('Local Lower Level');
                }
            } else if (institutionType == 'University') {
                if (tempCat == 'Tuition') {
                    instituitonRateTypeRateLevel.add('Tuition University');
                } else if (tempCat == 'Local') {
                    instituitonRateTypeRateLevel.add('Local University');
                } else if (tempCat == 'TDF') {
                    instituitonRateTypeRateLevel.add('TDF University');
                }
            }
        }

        if (!avgSchoolRates.isEmpty()) {
            for (Average_School_Rates__c avgRat: avgSchoolRates) {
                system.debug('avgRat.Institution_Type__c' + avgRat.Institution_Type__c);
                system.debug('Category' + Category);

                if (avgRat.Institution_Type__c == institutionType) {
                    string temp = avgRat.Coverage_Type__c + ' ' + avgRat.Rate_Level__c;
                    if (instituitonRateTypeRateLevel.contains(temp)) {
                        instituitionRateMap.put(avgRat.Coverage_Type__c, avgRat.Rate__c);
                    }
                } else if (avgRat.Institution_Type__c == 'Average Rate') {
                    string temp = avgRat.Coverage_Type__c + ' ' + avgRat.Rate_Level__c;
                    if (rateTypeLevelList.contains(temp)) {
                        coverageAPIRateMap.put(avgRat.Coverage_API_Name__c, avgRat.Rate__c);
                        avgRateMap.put(avgRat.Coverage_Type__c, avgRat.Rate__c);
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

        /*if (isBundled) {
            map<id,list<string,object>> institutionMapBundled = new map<id,list<string,object>>();
            map<id,list<string,object>> averageMapBundled = new map<id,list<string,object>>();

            for (Id ids: mapCoverageIdAvailableCovgMap.keyset()) {
                map < string, object > tempObj = new map < string, object > ();
                map < string, object > mapUnitAvailableValues = mapCoverageIdAvailableCovgMap.get(ids);
                string covgType = coverageIdTypeMap.get(ids);

                for (string str: mapUnitAvailableValues.keyset()) {
                    if (covgType == 'Tuition') {
                        tempObj.put('Tuition_Lower__c', mapUnitAvailableValues.get('Tuition_Lower__c'));
                    } else if (covgType == 'Local') {
                        tempObj.put('Local_Lower__c', mapUnitAvailableValues.get('Tuition_Lower__c'));
                    }
                }
                mapCoverageIdAvailableCovgMap.put(ids, tempObj);
            }
        }*/


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
                    //if (coverageAPIRateMap.containsKey(str)) {
                    /*if (paymentMethod == 'Calculate Based on Units Requested') {
                        totalAmountUnitsNotAvailable = totalAmountUnitsNotAvailable + avgRateMap.get(collegeUniversityMap.get(str)) * (Decimal)(tempMap.get(str));
                        averageAmount = averageAmount + avgRateMap.get(collegeUniversityMap.get(str)) * requestedUnitValue;
                    } else {
                        averageAmount = averageAmount + avgRateMap.get(collegeUniversityMap.get(str)) * (Decimal)(tempMap.get(str));
                    }*/
                    if ((Decimal)(tempMap.get(str)) > 0) {
                        averageAmount = averageAmount + avgRateMap.get(collegeUniversityMap.get(str)) * (Decimal)(tempMap.get(str));
                    }
                }
                // }
            }
        } else {
            for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
                map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
                for (string str: tempMap.keyset()) {
                    if (coverageAPIRateMap.containsKey(str)) {
                        // if (paymentMethod == 'Calculate Based on Units Requested') {
                        //   averageAmount = averageAmount + avgRateMap.get(collegeUniversityMap.get(str)) * requestedUnitValue;
                        // totalAmountUnitsNotAvailable = totalAmountUnitsNotAvailable + avgRateMap.get(collegeUniversityMap.get(str)) * (Decimal)(tempMap.get(str));
                        //} else {
                        if ((Decimal)(tempMap.get(str)) > 0) {
                            averageAmount = averageAmount + avgRateMap.get(collegeUniversityMap.get(str)) * (Decimal)(tempMap.get(str));
                        }
                        // }
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
                            // Decimal actualUnitTemp = (Decimal)(tempMap.get(str)) * 100;
                            if (paymentMethod == 'Calculate Based on Units Requested') {
                                if ((requestedUnitValue * percentageVal) / 100 > (Decimal)(tempMap.get(str))) {
                                    categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                                    //isUnitsAvailable = false;

                                } else {
                                    categoryActualUnitMap.put(str, (requestedUnitValue * percentageVal) / 100);
                                }
                            } else {
                                categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                            }
                        }
                    }
                    //if (isUnitsAvailable) {
                    claimAmount = averageAmount;
                    //} else {
                    //  claimAmount = totalAmountUnitsNotAvailable;
                    //  wrap.claimAmountDifference = totalAmount - totalAmountUnitsNotAvailable;
                    //}

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
                                // Decimal actualUnitTemp = (Decimal)(tempMap.get(str)) * 100;
                                categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                            }
                        }
                    }
                    // if (isUnitsAvailable) {
                    claimAmount = averageAmount;
                    // } else {
                    //claimAmount = totalAmountUnitsNotAvailable;
                    //  }
                    //claimAmount = averageAmount;
                }

            } else {
                if (isBundled || (category == 'College' && numberOfYears > 2)) {
                    for (id coverageId: avgBundledMap.keyset()) {
                        map < string, object > tempMap = avgBundledMap.get(coverageId);
                        for (string str: tempMap.keyset()) {
                            if (coverageAPIRateMap.containsKey(str)) {
                                /*if (paymentMethod == 'Calculate Based on Units Requested') {
                                    Decimal actualUnitTemp = (requestedUnitValue * percentageVal) / 100;
                                    if (actualUnitTemp < (Decimal)(tempMap.get(str))) {
                                        categoryActualUnitMap.put(str, actualUnitTemp);
                                    } else {
                                        categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                                    }
                                } else{
                                    categoryActualUnitMap.put(str, ((Decimal)(tempMap.get(str)) * percentageVal) / 100);
                                }*/
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
                                /* if (paymentMethod == 'Calculate Based on Units Requested') {
                                     Decimal actualUnitTemp = (requestedUnitValue * percentageVal) / 100;
                                     if (actualUnitTemp < (Decimal)(tempMap.get(str))) {
                                         categoryActualUnitMap.put(str, actualUnitTemp);
                                     } else {
                                         categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                                     }
                                 } else {*/
                                categoryActualUnitMap.put(str, ((Decimal)(tempMap.get(str)) * percentageVal) / 100);
                                // }
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




        /* decimal totalRateAmountinstitution = 0;
        decimal totalRateAmountAverageRate = 0;

        string claimAmountActualUnit;
        system.debug('institutionType' + institutionType);
        if (institutionType != 'Average Rate') {
            paymentMethodval = 'Calculate Based on Amount Paid';
            list < string > instRatetype = mapCategoryRateType.get(institutionType);


            list < Average_School_Rates__c > InstavgSchoolRates = [Select Rate__c,
                Coverage_Type__c,
                Rate_Level__c,
                Institution_Type__c
                from Average_School_Rates__c
                where Institution_Type__c =: institutionType
                AND Coverage_Type__c IN: instRatetype
                AND Term__c =: termValue
            ];

            if (!InstavgSchoolRates.isEmpty()) {
                for (Average_School_Rates__c AV: InstavgSchoolRates) {
                    totalRateAmountinstitution += AV.Rate__c;
                }
                rateAmountInstitution = totalRateAmountinstitution;
                totalRateAmountinstitution = totalRateAmountinstitution * requestedUnitValue;
                system.debug('totalRateAmountinstitution' + totalRateAmountinstitution);
            }

            list < Average_School_Rates__c > avgSchoolRates = [Select Rate__c,
                Coverage_Type__c,
                Rate_Level__c,
                Institution_Type__c
                from Average_School_Rates__c
                where Institution_Type__c =: 'Average Rate'
                AND Coverage_Type__c IN: ratetype
                AND Term__c =: termValue
            ];

            if (!avgSchoolRates.isEmpty()) {
                list < string > rateLevelValues = catLevelRate.get(category);
                for (Average_School_Rates__c avgRat: avgSchoolRates) {
                    string temp = avgRat.Coverage_Type__c + ' ' + avgRat.Rate_Level__c;
                    //system.debug('rateLevelValues' + rateLevelValues);
                    //system.debug('Coverage_Type__c' + avgRat.Coverage_Type__c);

                    if (rateLevelValues.contains(temp)) {
                        totalRateAmountAverageRate += avgRat.Rate__c;
                    }
                }
                totalRateAmountAverageRate = totalRateAmountAverageRate * remainingUnits;
                //system.debug('remaining units' + remainingUnits);
                system.debug('totalRateAmountAverageRate' + totalRateAmountAverageRate);
            }

            // system.debug('avgschool rates' + avgSchoolRates);
            decimal tempVar;
            if (Flag) {
                system.debug('claimAmount' + claimAmount);
                tempVar = (claimAmount / totalRateAmountAverageRate) * 100;
                system.debug('tempVar' + tempVar);

            } else {
                tempVar = (totalRateAmountinstitution / totalRateAmountAverageRate) * 100;
                system.debug('tempVar' + tempVar);
            }


            if (tempVar < 100) {
                decimal tempVar2 = (remainingUnits / 100) * tempVar;
                system.debug('tempVar2 value' + tempVar2);

                ActualUnit = tempVar2;
                if (Flag) {
                    claimAmount = claimAmount;
                } else {
                    claimAmount = totalRateAmountinstitution;
                }

            } else {
                claimAmount = totalRateAmountAverageRate;
                ActualUnit = remainingUnits;
            }
            claimAmountActualUnit = string.valueof(claimAmount) + ';' + string.valueof(ActualUnit) + ';' + string.valueof(totalRateAmountinstitution);
            system.debug('claimAmountActualUnit' + claimAmountActualUnit);
        } else {

            list < Average_School_Rates__c > avgSchoolRates = [Select Rate__c,
                Coverage_Type__c,
                Rate_Level__c,
                Institution_Type__c
                from Average_School_Rates__c
                where Institution_Type__c =: 'Average Rate'
                AND Coverage_Type__c IN: ratetype
                AND Term__c =: termValue
            ];

            if (!avgSchoolRates.isEmpty()) {
                list < string > rateLevelValues = catLevelRate.get(category);
                for (Average_School_Rates__c avgRat: avgSchoolRates) {
                    string temp = avgRat.Coverage_Type__c + ' ' + avgRat.Rate_Level__c;
                    //system.debug('rateLevelValues' + rateLevelValues);
                    //system.debug('Coverage_Type__c' + avgRat.Coverage_Type__c);

                    if (rateLevelValues.contains(temp)) {
                        totalRateAmountAverageRate += avgRat.Rate__c;
                    }
                }
                if (paymentMethodval == 'Calculate Based on Units Requested') {
                    if (remainingUnits > requestedUnitValue) {
                        ActualUnit = requestedUnitValue;
                        claimAmount = totalRateAmountAverageRate * requestedUnitValue;
                    } else {
                        ActualUnit = remainingUnits;
                        claimAmount = totalRateAmountAverageRate * remainingUnits;
                    }

                    //claimAmount = totalRateAmount * requestedUnitValue;

                    if (claimAmount < requestedAmountValue) {
                        claimAmount = claimAmount;
                        ActualUnit = ActualUnit;
                    } else if (claimAmount > requestedAmountValue && requestedAmountValue > 0) {
                        claimAmount = requestedAmountValue;
                        ActualUnit = requestedAmountValue / totalRateAmountAverageRate;
                    } else if (claimAmount > requestedAmountValue && (requestedAmountValue <= 0 || requestedAmountValue == null)) {
                        claimAmount = claimAmount;
                        ActualUnit = ActualUnit;
                    }
                } else if (paymentMethodval == 'Calculate Based on Amount Paid') {
                    if (category != 'Bundled') {
                        claimAmount = totalRateAmountAverageRate * remainingUnits;
                        if (claimAmount > requestedAmountValue) {
                            claimAmount = requestedAmountValue;
                            ActualUnit = requestedAmountValue / totalRateAmountAverageRate;
                        } else {
                            claimAmount = remainingUnits * totalRateAmountAverageRate;
                            ActualUnit = remainingUnits;
                        }
                    } else {
                        claimAmount = totalRateAmountAverageRate * remainingUnits;

                        Decimal temp = (requestedAmountValue / claimAmount) * 100;

                        if (temp < 100) {
                            decimal tempVar2 = (remainingUnits / 100) * temp;
                            system.debug('temp' + tempVar2);

                            ActualUnit = tempVar2;
                            claimAmount = requestedAmountValue;
                        }

                    }
                }


                claimAmountActualUnit = string.valueof(claimAmount) + ';' + string.valueof(ActualUnit);
            }
        }
        return claimAmountActualUnit;*/
    }

    public static list < Average_School_Rates__c > averageSchoolRates(string institutionType, string termValue) {
        list < Average_School_Rates__c > avgSchoolRates = [Select Rate__c, Coverage_API_Name__c, Coverage_Type__c, Rate_Level__c
            from Average_School_Rates__c
            where Institution_Type__c =: institutionType
            AND Term__c =: termValue
        ];
        return avgSchoolRates;
    }

    public static decimal calculateUnitsAvailable(list < string > coveragePlanIdList) {

        map < string, map < string, object >> mapCoverageIdAvailableCovgMap = new map < string, map < string, object >> ();
        Decimal unitsAvailable = 0;

        list < string > CovgUnitList = new list < string > {
            'Local__c',
            'Local_Upper__c',
            'Local_Lower__c',
            'Tuition__c',
            'Tuition_Upper__c',
            'Tuition_Lower__c',
            'Dormitory__c',
            'TDF__c'
        };

        if (!coveragePlanIdList.isEmpty()) {
            list < InsurancePolicyCoverage > covgList = [SELECT id,
                Product__c,
                Tuition__c,
                Tuition_Lower__c,
                Tuition_Upper__c,
                Local_Upper__c,
                Local_Lower__c,
                TDF__c,
                Local__c,
                Category,
                Dormitory__c,
                Coverage_Type__c,
                Number_of_Years__c
                FROM InsurancePolicyCoverage
                WHERE id IN: coveragePlanIdList
            ];

            if (!covgList.isEmpty()) {
                for (InsurancePolicyCoverage ic: covgList) {
                    map<string,object> mapCoverageUnitValue = new map<string,object>();
                    for (string str: CovgUnitList) {
                        if (ic.get(str) != null) {
                            mapCoverageUnitValue.put(str, ic.get(str));
                        }
                        mapCoverageIdAvailableCovgMap.put(ic.id, mapCoverageUnitValue);
                    }
                }
            }
        }

        if (!mapCoverageIdAvailableCovgMap.isEmpty()) {
            for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
                map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
                for (string str: tempMap.keyset()) {
                    if ((Decimal)(tempMap.get(str)) > 0) {
                        unitsAvailable += (Decimal)(tempMap.get(str)); 
                    }
                }
            }
        }
        return unitsAvailable;
    }

    //public static string claimCalculations(string institutionType, string termValue, list < string > rateType, string Category, Decimal requestedUnitValue, string paymentMethod, decimal remainingUnits, decimal requestedAmountValue, map < string, list < string >> catLevelRate, map < string, decimal > mapSchoolRatesValue) {
    public static actualUnitClaimAmountWrapper claimCalculations(string institutionType, string termValue, string Category, Decimal requestedUnitValue, string paymentMethod, decimal requestedAmountValue, list < string > rateTypeLevelList, map < id, map < string, object >> mapCoverageIdAvailableCovgMap, decimal numberOfYears, Boolean isBundled, Boolean isSchoolInvoice) {
        decimal totalRateAmount = 0;
        decimal requestedAmount = 0;
        string claimAmountActualUnit;
        decimal claimAmount = 0;
        decimal ActualUnit;
        map < string, decimal > categoryActualUnitMap = new map < string, decimal > ();
        map < string, decimal > categoryRate = new map < string, decimal > ();
        actualUnitClaimAmountWrapper wrap = new actualUnitClaimAmountWrapper();
        Decimal totalAmount = 0;
        Decimal availableAmount = 0;
        map < string, decimal > coverageAPIRateMap = new map < string, decimal > ();
        Decimal avgRateTotal = 0;
        Decimal weightedAvg;


        list < Average_School_Rates__c > avgSchoolRates = averageSchoolRates(institutionType, termValue);
        system.debug('avgSchoolRates' + avgSchoolRates.size());


        if (!avgSchoolRates.isEmpty()) {
            for (Average_School_Rates__c avgRat: avgSchoolRates) {
                string temp = avgRat.Coverage_Type__c + ' ' + avgRat.Rate_Level__c;

                if (rateTypeLevelList.contains(temp)) {
                    coverageAPIRateMap.put(avgRat.Coverage_API_Name__c, avgRat.Rate__c);
                    if (paymentMethod == 'Calculate Based on Units Requested') {
                        totalAmount = totalAmount + requestedUnitValue * avgRat.Rate__c;
                        avgRateTotal = avgRateTotal + avgRat.Rate__c;
                    }
                }
            }
        }
        system.debug('coverageAPIRateMap' + coverageAPIRateMap);


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

        system.debug('availableAmount ##############################' + availableAmount);

        if (isBundled && institutionType == 'Average Rate' && paymentMethod == 'Calculate Based on Units Requested') {
            weightedAvg = availableAmount / avgRateTotal;
            wrap.claimRemainingUnits = weightedAvg;
        }


        if (paymentMethod == 'Calculate Based on Amount Paid') {
            totalAmount = requestedAmountValue;
        }

        system.debug('Total Amount ##################################' + totalAmount);

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

        } else {

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
                            /* if (requestedUnitValue > (Decimal)(tempMap.get(str))) {
                                 wrap.claimRemainingUnits = requestedUnitValue - (Decimal)(tempMap.get(str));
                             } else {
                                 wrap.claimRemainingUnits = 0;
                             }*/
                            // Decimal actualUnitTemp = (Decimal)(tempMap.get(str)) * 100;
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
                            Decimal actualUnitTemp = ((Decimal)(tempMap.get(str)) * percentageVal) / 100;
                            categoryActualUnitMap.put(str, actualUnitTemp);
                        }
                    }
                }
                claimAmount = totalAmount;
            }


            /*for (id coverageId: mapCoverageIdAvailableCovgMap.keyset()) {
                map < string, object > tempMap = mapCoverageIdAvailableCovgMap.get(coverageId);
                for (string str: tempMap.keyset()) {
                    if (requestedUnitValue < (Decimal)(tempMap.get(str))) {
                        categoryActualUnitMap.put(str, requestedUnitValue);
                        claimAmount += categoryRate.get(str) * requestedUnitValue;
                    } else {
                        categoryActualUnitMap.put(str, (Decimal)(tempMap.get(str)));
                        claimAmount += categoryRate.get(str) * (Decimal)(tempMap.get(str));
                    }
                }
            }*/
            system.debug('categoryActualUnitMap' + categoryActualUnitMap);
            system.debug('claimAmount' + claimAmount);
            wrap.mapCoverageActualUnit = categoryActualUnitMap;
            wrap.claimAmountValue = claimAmount;
        }

        return wrap;

        /*   if (paymentMethod == 'Calculate Based on Units Requested') {
                if (remainingUnits > requestedUnitValue) {
                    ActualUnit = requestedUnitValue;
                    claimAmount = totalRateAmount * requestedUnitValue;
                } else {
                    ActualUnit = remainingUnits;
                    claimAmount = totalRateAmount * remainingUnits;
                }

                //claimAmount = totalRateAmount * requestedUnitValue;

                if (claimAmount < requestedAmountValue) {
                    claimAmount = claimAmount;
                    ActualUnit = ActualUnit;
                } else if (claimAmount > requestedAmountValue && requestedAmountValue > 0) {
                    claimAmount = requestedAmountValue;
                    ActualUnit = requestedAmountValue / totalRateAmount;
                } else if (claimAmount > requestedAmountValue && (requestedAmountValue <= 0 || requestedAmountValue == null)) {
                    claimAmount = claimAmount;
                    ActualUnit = ActualUnit;
                }
            } else if (paymentMethod == 'Calculate Based on Amount Paid') {
                if (category != 'Bundled') {
                    claimAmount = totalRateAmount * remainingUnits;
                    if (claimAmount > requestedAmountValue) {
                        claimAmount = requestedAmountValue;
                        ActualUnit = requestedAmountValue / totalRateAmount;
                    } else {
                        claimAmount = remainingUnits * totalRateAmount;
                        ActualUnit = remainingUnits;
                    }
                } else {
                    claimAmount = totalRateAmount * remainingUnits;

                    Decimal temp = (requestedAmountValue / claimAmount) * 100;

                    if (temp < 100) {
                        decimal tempVar2 = (remainingUnits / 100) * temp;
                        system.debug('temp' + tempVar2);

                        ActualUnit = tempVar2;
                        claimAmount = requestedAmountValue;
                    }

                }
            }

        }

        claimAmountActualUnit = string.valueof(claimAmount) + ';' + string.valueof(ActualUnit) + ';' + string.valueof(requestedAmount);
        system.debug('claimAmountActualUnit' + claimAmountActualUnit);
        return claimAmountActualUnit;*/
    }

    public static id newClaim(id nameinsuredId, id schoolId, id policyId, string termValue, string yearValue, string claimTypeValue, Decimal requestedUnitValue, Decimal requestedAmountValue, string paymentMethod, actualUnitClaimAmountWrapper wrap, string batchId, string URL) {

        map < string, decimal > unitNameActualUnit = new map < string, decimal > ();
        unitNameActualUnit = wrap.mapCoverageActualUnit;
        claim cl = new claim();
        cl.AccountId = nameinsuredId;
        cl.Educational_Institutes__c = schoolId;
        cl.Name = 'Claim - ' + DateTime.now().getTime();
        cl.PolicyNumberId = policyId;
        cl.Term__c = termValue;
        cl.Year__c = yearValue;
        cl.Claim_Amount__c = wrap.claimAmountValue;
        cl.ClaimType = claimTypeValue;
        if (!string.isBlank(batchId)) {
            cl.BatchId__c = batchId;
        }

        if (!string.isBlank(URL)) {
            cl.Uploaded_File_Link__c = URL;
        }

        if (requestedUnitValue != null) {
            cl.Estimated_Hours__c = requestedUnitValue;
        }
        cl.Requested_Amount__c = requestedAmountValue;
        cl.Payment_Methodology__c = paymentMethod;

        //system.debug('unitNameActualUnit' + unitNameActualUnit);

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

        insert cl;
        return cl.id;
    }



    @AuraEnabled
    public static actualUnitClaimAmountWrapper actualUnitCalculations(string schoolId, string termValue, string yearValue, string claimTypeValue, decimal requestedUnitValue, list < string > coveragePlanId, List < Map < String, Object >> files, decimal requestedAmountValue, Id policyId, Boolean isSchoolInvoice, Boolean paymentMethodUpdated) {
        try {

            Decimal claimRequestedAmount = requestedAmountValue;
            Decimal remainingUnitsLower;
            string accid;
            id claimId;
            string paymentMethod;
            //Decimal remainingUnitsUpper;
            Decimal numberOfYears;
            Decimal ActualUnit;
            Decimal claimAmountPerUnit;
            String ProductId;
            Boolean isDormClaim = false;
            String category;
            Decimal rateAmountInstitution;
            decimal claimAmount = 0;
            map < string, Decimal > rateLevelRate = new map < string, Decimal > ();
            map < string, list < string >> catLevelRate = new map < string, list < string >> ();
            id nameinsuredId;
            list < claim > subClaimList = new list < claim > ();
            Decimal remainingUniVersityUnit;
            map < string, list < string >> mapCategoryRateType = new map < string, list < string >> ();
            map < id, string > coverageIdTypeMap = new map < id, string > ();
            actualUnitClaimAmountWrapper wrap = new actualUnitClaimAmountWrapper();
            actualUnitClaimAmountWrapper wrap1 = new actualUnitClaimAmountWrapper();
            map < string, decimal > upperClaimValue = new map < string, decimal > ();
            map < string, decimal > lowerClaimValue = new map < string, decimal > ();
            Decimal lowerClaimAmount = 0;
            Decimal upperClaimAmount = 0;
            map < id, map < string, object >> instBundledMap = new map < id, map < string, object >> ();
            map < id, map < string, object >> avgBundledMap = new map < id, map < string, object >> ();
            map < id, map < string, object >> avgCollegeFourYearPlan = new map < id, map < string, object >> ();
            Boolean isBundledTDFCovg = false;


            //get the id of namedInsured
            list < InsurancePolicy > policyList = [select id, Payment_Methodology__c, NameInsuredId from InsurancePolicy where id =: policyId];

            if (!policyList.isEmpty()) {
                nameinsuredId = policyList[0].NameInsuredId;
                if (paymentMethodUpdated) {
                    paymentMethod = 'Calculate Based on Amount Paid';
                } else {
                    paymentMethod = policyList[0].Payment_Methodology__c;
                }

            }

            //get the instituition type
            list < account > instType = [select id, Institution_Type__c from Account where id =: schoolId];
            string institutionType;
            if (!instType.isEmpty()) {
                institutionType = instType[0].Institution_Type__c;
            }

            //get the coverages
            if (!coveragePlanId.isEmpty()) {
                list < InsurancePolicyCoverage > covgList = [SELECT id,
                    Product__c,
                    Tuition__c,
                    Tuition_Lower__c,
                    Tuition_Upper__c,
                    Local_Upper__c,
                    Local_Lower__c,
                    TDF__c,
                    Local__c,
                    Category,
                    Dormitory__c,
                    Coverage_Type__c,
                    Number_of_Years__c
                    FROM InsurancePolicyCoverage
                    WHERE id IN: coveragePlanId
                ];

                //list < string > ratetype = mapCategoryRateType.get(covgList[0].Category);

                if (!covgList.isEmpty()) {

                    //get the number of years value from product
                    ProductId = covgList[0].Product__c;
                    list < product2 > productList = [select id, Number_of_Years__c from Product2 where id =: ProductId];
                    numberOfYears = productList[0].Number_of_Years__c;
                    category = covgList[0].Category;

                    map < id, map < string, object >> mapCoverageIdAvailableCovgMap = new map < id, map < string, object >> ();

                    list < string > CovgUnitList = new list < string > {
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
                    list < string > coverageTypeList = new list < string > ();

                    for (InsurancePolicyCoverage ic: covgList) {
                        coverageIdTypeMap.put(ic.id, ic.Coverage_Type__c);
                        coverageTypeList.add(ic.Coverage_Type__c);
                        if (ic.category == 'University') {
                            if (ic.Coverage_Type__c == 'Tuition') {
                                rateTypeLevelList.add('Tuition University');
                            } else if (ic.Coverage_Type__c == 'Local') {
                                rateTypeLevelList.add('Local University');
                            } else if (ic.Coverage_Type__c == 'TDF') {
                                rateTypeLevelList.add('TDF University');
                            }

                        } else if (ic.category == 'College' || ic.category == 'Bundled') {
                            if (ic.Coverage_Type__c == 'Tuition') {
                                rateTypeLevelList.add('Tuition Lower Level');
                            } else if (ic.Coverage_Type__c == 'Local') {
                                rateTypeLevelList.add('Local Lower Level');
                            } else if (ic.Coverage_Type__c == 'TDF') {
                                isBundledTDFCovg = true;
                                if (ic.category == 'Bundled' && institutionType == 'University') {
                                    rateTypeLevelList.add('TDF University');
                                }
                            }


                        } else if (ic.category == 'Dorm') {
                            rateTypeLevelList.add('Dormitory University');
                        }
                        map < string, object > mapCoverageUnitValue = new map < string, object > ();

                        for (string str: CovgUnitList) {
                            if (ic.get(str) != null) {
                                mapCoverageUnitValue.put(str, ic.get(str));
                            }
                            mapCoverageIdAvailableCovgMap.put(ic.id, mapCoverageUnitValue);
                        }
                    }

                    system.debug('mapAvailableCovgValue' + mapCoverageIdAvailableCovgMap);
                    system.debug('temp unit value' + rateTypeLevelList);


                    if ((category == institutionType || institutionType == 'Average Rate') && category != 'Bundled' && category != 'Dorm') {

                        system.debug('no of years' + numberOfYears);
                        if (category == 'University' || (category == 'College' && numberOfYears < 3)) {
                            wrap = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, numberOfYears, false, isSchoolInvoice);
                            system.debug('wrap value' + wrap);
                        } else if (category == 'College' && numberOfYears > 2) {
                            wrap = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, numberOfYears, false, isSchoolInvoice);
                            system.debug('wrap value ' + wrap);
                            //map<string,decimal> deductedUnits = wrap.mapCoverageActualUnit;
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
                                //wrap = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap,numberOfYears);
                                wrap1 = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, numberOfYears, false, isSchoolInvoice);
                                //wrap1 = claimCalculationsInstitutionCategoryDiff(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap, true, instBundledMap, avgBundledMap, numberOfYears);
                                //upperClaimValue = wrap.mapCoverageActualUnit;
                                upperClaimAmount = wrap1.claimAmountValue;
                                wrap.claimAmountValue = lowerClaimAmount + upperClaimAmount;
                                upperClaimValue = wrap1.mapCoverageActualUnit;
                                wrap.mapCoverageActualUnit.putAll(upperClaimValue);
                            }
                        }

                    } else if (category != institutionType && category != 'Bundled' && category != 'Dorm') {
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
                            wrap = claimCalculationsInstitutionCategoryDiff(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap, true, instBundledMap, avgBundledMap, numberOfYears);





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
                                //wrap = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap,numberOfYears);
                                wrap1 = claimCalculationsInstitutionCategoryDiff(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap, true, instBundledMap, avgCollegeFourYearPlan, numberOfYears);
                                //upperClaimValue = wrap.mapCoverageActualUnit;
                                upperClaimAmount = wrap1.claimAmountValue;
                                wrap.claimAmountValue = lowerClaimAmount + upperClaimAmount;
                                upperClaimValue = wrap1.mapCoverageActualUnit;
                                wrap.mapCoverageActualUnit.putAll(upperClaimValue);
                            }


                        } else {
                            wrap = claimCalculationsInstitutionCategoryDiff(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap, false, instBundledMap, avgBundledMap, numberOfYears);
                        }

                    } else if (category == 'Bundled') {
                        category = 'College';

                        if (category == institutionType || institutionType == 'Average Rate') {

                            Decimal reqUnitVal;
                            wrap = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, numberOfYears, true, isSchoolInvoice);
                            lowerClaimValue = wrap.mapCoverageActualUnit;
                            lowerClaimAmount = wrap.claimAmountValue;


                            if (wrap.claimAmountDifference != null && wrap.claimAmountDifference > 0) {

                                String paymentMethodValue = 'Calculate Based on Amount Paid';
                                requestedAmountValue = wrap.claimAmountDifference;
                                Boolean isTDF = false;

                                for (Id ids: mapCoverageIdAvailableCovgMap.keyset()) {
                                    map < string, object > instMap = new map < string, object > ();
                                    map < string, object > avgMap = new map < string, object > ();
                                    map < string, object > mapUnitAvailableValues = mapCoverageIdAvailableCovgMap.get(ids);
                                    string covgType = coverageIdTypeMap.get(ids);

                                    for (string str: mapUnitAvailableValues.keyset()) {
                                        if (covgType == 'Tuition') {
                                            instMap.put('Tuition_Lower__c', mapUnitAvailableValues.get('Tuition_Lower__c'));
                                            avgMap.put('Tuition__c', mapUnitAvailableValues.get('Tuition__c'));
                                        } else if (covgType == 'Local') {
                                            instMap.put('Local_Lower__c', mapUnitAvailableValues.get('Local_Lower__c'));
                                            avgMap.put('Local__c', mapUnitAvailableValues.get('Local__c'));
                                        } else if (covgType == 'TDF') {
                                            isTDF = true;
                                            //instMap.put('Local_Lower__c', mapUnitAvailableValues.get('Local_Lower__c'));
                                            avgMap.put('TDF__c', mapUnitAvailableValues.get('TDF__c'));
                                        }
                                    }
                                    instBundledMap.put(ids, instMap);
                                    avgBundledMap.put(ids, avgMap);
                                }

                                if (isTDF) {
                                    list < string > tempStringList = new list < string > {
                                        'Tuition University',
                                        'Local University',
                                        'TDF University'
                                    };
                                    rateTypeLevelList = tempStringList;
                                } else {
                                    list < string > tempStringList = new list < string > {
                                        'Tuition University',
                                        'Local University'
                                    };
                                    rateTypeLevelList = tempStringList;
                                }



                                //wrap = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap,numberOfYears);
                                if (institutionType == 'Average Rate') {

                                    if (isBundledTDFCovg) {
                                        list < string > tempStringList = new list < string > {
                                            'Tuition University',
                                            'Local University',
                                            'TDF University'
                                        };
                                        rateTypeLevelList = tempStringList;
                                    } else {
                                        list < string > tempStringList = new list < string > {
                                            'Tuition University',
                                            'Local University'
                                        };
                                        rateTypeLevelList = tempStringList;
                                    }

                                    /*for (Id ids: mapCoverageIdAvailableCovgMap.keyset()) {
                                        string covgType = coverageIdTypeMap.get(ids);
                                        map < string, object > mapUnitAvailableValues = mapCoverageIdAvailableCovgMap.get(ids);


                                        for (string str: mapUnitAvailableValues.keyset()) {
                                            if (covgType == 'TDF') {
                                                mapUnitAvailableValues.put(str, (Decimal) mapUnitAvailableValues.get(str) - (Decimal) lowerClaimValue.get(str));
                                            }
                                        }
                                    }*/

                                    //paymentMethod = 'Calculate Based on Units Requested';

                                    if (wrap.claimRemainingUnits != null && wrap.claimRemainingUnits > 0) {
                                        reqUnitVal = requestedUnitValue - wrap.claimRemainingUnits;
                                        paymentMethodValue = paymentMethod;
                                    }

                                    wrap1 = claimCalculations(institutionType, termValue, Category, reqUnitVal, paymentMethodValue, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, numberOfYears, true, isSchoolInvoice);
                                } else {
                                    wrap1 = claimCalculationsInstitutionCategoryDiff(institutionType, termValue, Category, requestedUnitValue, paymentMethodValue, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap, true, instBundledMap, avgBundledMap, numberOfYears);
                                }


                                //upperClaimValue = wrap.mapCoverageActualUnit;
                                upperClaimAmount = wrap1.claimAmountValue;
                                wrap.claimAmountValue = lowerClaimAmount + upperClaimAmount;
                                upperClaimValue = wrap1.mapCoverageActualUnit;


                                /*for (string upClval: upperClaimValue.keyset()) {
                                    if (wrap.mapCoverageActualUnit.containsKey(upClval)) {
                                        wrap.mapCoverageActualUnit.put(upClval, (Decimal) wrap.mapCoverageActualUnit.get(upClval) + (Decimal) upperClaimValue.get(upClval));

                                    } else {
                                        wrap.mapCoverageActualUnit.put(upClval, upperClaimValue.get(upClval));
                                    }
                                }*/



                                wrap.mapCoverageActualUnit.putAll(upperClaimValue);
                            }

                        } else {


                            for (Id ids: mapCoverageIdAvailableCovgMap.keyset()) {
                                map < string, object > instMap = new map < string, object > ();
                                map < string, object > avgMap = new map < string, object > ();
                                map < string, object > mapUnitAvailableValues = mapCoverageIdAvailableCovgMap.get(ids);
                                string covgType = coverageIdTypeMap.get(ids);

                                for (string str: mapUnitAvailableValues.keyset()) {
                                    if (covgType == 'Tuition') {
                                        instMap.put('Tuition__c', mapUnitAvailableValues.get('Tuition__c'));
                                        avgMap.put('Tuition_Lower__c', mapUnitAvailableValues.get('Tuition_Lower__c'));
                                    } else if (covgType == 'Local') {
                                        instMap.put('Local__c', mapUnitAvailableValues.get('Local__c'));
                                        avgMap.put('Local_Lower__c', mapUnitAvailableValues.get('Local_Lower__c'));
                                    } else if (covgType == 'TDF') {
                                        instMap.put('TDF__c', mapUnitAvailableValues.get('TDF__c'));
                                        //avgMap.put('Local_Lower__c', mapUnitAvailableValues.get('Local_Lower__c'));
                                    }
                                }
                                instBundledMap.put(ids, instMap);
                                avgBundledMap.put(ids, avgMap);
                            }
                            wrap = claimCalculationsInstitutionCategoryDiff(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap, true, instBundledMap, avgBundledMap, numberOfYears);
                            lowerClaimValue = wrap.mapCoverageActualUnit;
                            lowerClaimAmount = wrap.claimAmountValue;
                            if (wrap.claimAmountDifference != null && wrap.claimAmountDifference > 0) {
                                paymentMethod = 'Calculate Based on Amount Paid';
                                requestedAmountValue = wrap.claimAmountDifference;
                                Boolean isTDF = false;

                                for (Id ids: mapCoverageIdAvailableCovgMap.keyset()) {
                                    map < string, object > instMap = new map < string, object > ();
                                    map < string, object > avgMap = new map < string, object > ();
                                    map < string, object > mapUnitAvailableValues = mapCoverageIdAvailableCovgMap.get(ids);
                                    string covgType = coverageIdTypeMap.get(ids);

                                    for (string str: mapUnitAvailableValues.keyset()) {
                                        if (covgType == 'Tuition') {
                                            instMap.put('Tuition__c', mapUnitAvailableValues.get('Tuition__c'));
                                            avgMap.put('Tuition_Upper__c', mapUnitAvailableValues.get('Tuition_Upper__c'));
                                        } else if (covgType == 'Local') {
                                            instMap.put('Local__c', mapUnitAvailableValues.get('Local__c'));
                                            avgMap.put('Local_Upper__c', mapUnitAvailableValues.get('Local_Upper__c'));
                                        } else if (covgType == 'TDF') {
                                            isTDF = true;
                                            instMap.put('TDF__c', mapUnitAvailableValues.get('TDF__c'));
                                            //avgMap.put('TDF__c', mapUnitAvailableValues.get('TDF__c'));
                                        }
                                    }
                                    instBundledMap.put(ids, instMap);
                                    avgBundledMap.put(ids, avgMap);
                                }

                                if (isTDF) {
                                    list < string > tempStringList = new list < string > {
                                        'Tuition University',
                                        'Local University',
                                        'TDF University'
                                    };
                                    rateTypeLevelList = tempStringList;
                                } else {
                                    list < string > tempStringList = new list < string > {
                                        'Tuition University',
                                        'Local University'
                                    };
                                    rateTypeLevelList = tempStringList;
                                }
                                //wrap = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap,numberOfYears);
                                //wrap1 = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, coverageTypeList, coverageIdTypeMap,true,instBundledMap,avgBundledMap);
                                wrap1 = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, numberOfYears, true, isSchoolInvoice);
                                //upperClaimValue = wrap.mapCoverageActualUnit;
                                upperClaimAmount = wrap1.claimAmountValue;
                                wrap.claimAmountValue = lowerClaimAmount + upperClaimAmount;
                                upperClaimValue = wrap1.mapCoverageActualUnit;
                                wrap.mapCoverageActualUnit.putAll(upperClaimValue);
                            }
                        }

                    } else if (category == 'Dorm') {
                        if (institutionType == 'University' || institutionType == 'Average Rate') {
                            wrap = claimCalculations(institutionType, termValue, Category, requestedUnitValue, paymentMethod, requestedAmountValue, rateTypeLevelList, mapCoverageIdAvailableCovgMap, numberOfYears, false, isSchoolInvoice);
                        }
                    }

                }
            }
            return wrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static id processClaim(string schoolId, string termValue, string yearValue, string claimTypeValue, decimal requestedUnitValue, list < string > coveragePlanId, List < Map < String, Object >> files, decimal requestedAmountValue, Id policyId) {

        //create instance of wrapper
        actualUnitClaimAmountWrapper wrap = new actualUnitClaimAmountWrapper();
        string claimId;
        string paymentMethod;
        string nameinsuredId;

        //get the id of namedInsured
        list < InsurancePolicy > policyList = [select id, Payment_Methodology__c, NameInsuredId from InsurancePolicy where id =: policyId];

        if (!policyList.isEmpty()) {
            nameinsuredId = policyList[0].NameInsuredId;
            paymentMethod = policyList[0].Payment_Methodology__c;
        }

        system.debug('paymentMethod >>>>>' + paymentMethod);

        //call claimCalcuations method
        wrap = actualUnitCalculations(schoolId, termValue, yearValue, claimTypeValue, requestedUnitValue, coveragePlanId, files, requestedAmountValue, policyId, false, false);

        //create new claim
        claimId = newClaim(nameinsuredId, schoolId, policyId, termValue, yearValue, claimTypeValue, requestedUnitValue, requestedAmountValue, paymentMethod, wrap, '', '');

        //create claim coverages
        creatClaimItems(coveragePlanId, claimId);

        //upload the files to claim
        uploadfile(files, claimId);

        //return the newly created claim id
        return claimId;
    }

    public static void uploadfile(List < Map < String, Object >> files, id claimId) {
        if (!files.isEmpty()) {
            List < ContentVersion > relatedDocuments = new List < ContentVersion > ();
            for (Map < String, Object > file: files) {
                String fileJson = JSON.serialize(file);
                relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
                ContentVersion contentVersionFile = new ContentVersion();
                contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
                contentVersionFile.Title = relatedDocument.Title;
                contentVersionFile.VersionData = relatedDocument.VersionData;
                relatedDocuments.add(contentVersionFile);
            }

            if (!relatedDocuments.isEmpty()) {
                insert relatedDocuments;
            }

            set < id > contentVersionIds = new set < id > ();
            map < id, id > contentVersionDocMap = new map < id, id > ();
            list < ContentDocumentLink > conDocList = new list < ContentDocumentLink > ();

            for (ContentVersion cv: relatedDocuments) {
                contentVersionIds.add(cv.id);
            }

            list < ContentVersion > docList = [SELECT id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionIds];


            if (!docList.isEmpty()) {
                for (ContentVersion cd: docList) {
                    contentVersionDocMap.put(cd.id, cd.ContentDocumentId);
                }
            }

            if (!contentVersionDocMap.isEmpty()) {
                for (id ids: contentVersionDocMap.keyset()) {
                    ContentDocumentLink cdl = New ContentDocumentLink();
                    cdl.LinkedEntityId = claimId;
                    cdl.ContentDocumentId = contentVersionDocMap.get(ids);
                    cdl.shareType = 'V';
                    conDocList.add(cdl);
                }

                if (!conDocList.isEmpty()) {
                    insert conDocList;
                }
            }
        }
    }

    /*@AuraEnabled
    public static Id createClaim(string schoolId, string termValue, string yearValue, string claimTypeValue, decimal requestedUnitValue, list < string > coveragePlanId, List < Map < String, Object >> files, decimal requestedAmountValue, Id policyId) {
        try {
            Claim cl = new claim();
            Decimal remainingUnits;
            Decimal claimRequestedAmount = requestedAmountValue;
            Decimal remainingUnitsLower;
            string paymentMethod;
            Decimal remainingUnitsUpper;
            Decimal numberOfYears;
            Decimal ActualUnit;
            Decimal claimAmountPerUnit;
            String ProductId;
            Boolean isDormClaim = false;
            String category;
            Decimal rateAmountInstitution;
            decimal claimAmount = 0;
            map < string, Decimal > rateLevelRate = new map < string, Decimal > ();
            map < string, list < string >> catLevelRate = new map < string, list < string >> ();
            id nameinsuredId;
            list < claim > subClaimList = new list < claim > ();
            Decimal remainingUniVersityUnit;
            map<string,list<string>> mapCategoryRateType = new map<string,list<string>>();

            /*map < string, list < string > > mapCategoryRateType = new map < string, list < string > > {
                'University' => new list < string > {
                    'Tuition',
                    'Local',
                    'TDF'
                },

                'Bundled' => new list < string > {
                    'Tuition',
                    'Local',
                    'TDF'
                },
                'College' => new list < string > {
                    'Tuition',
                    'Local'
                },
                'Dorm' => new list < string > {
                    'Dormitory'
                }
            };*/

    //get the id of namedInsured
    /* list < InsurancePolicy > policyList = [select id, Payment_Methodology__c, NameInsuredId from InsurancePolicy where id =: policyId];

     if (!policyList.isEmpty()) {
         nameinsuredId = policyList[0].NameInsuredId;
         paymentMethod = policyList[0].Payment_Methodology__c;
     }

     //get the instituition type
     list < account > instType = [select id, Institution_Type__c from Account where id =: schoolId];
     string institutionType;
     if (!instType.isEmpty()) {
         institutionType = instType[0].Institution_Type__c;
     }

     //get the coverages
     if (!coveragePlanId.isEmpty()) {
         list < InsurancePolicyCoverage > covgList = [SELECT id,
             Product__c,
             Tuition__c,
             Tuition_Lower__c,
             Tuition_Upper__c,
             Local_Upper__c,
             Local_Lower__c,
             TDF__c,
             Local__c,
             Category,
             Dormitory__c,
             Coverage_Type__c,
             Number_of_Years__c
             FROM InsurancePolicyCoverage
             WHERE id IN: coveragePlanId
         ];

         //list < string > ratetype = mapCategoryRateType.get(covgList[0].Category);

         if (!covgList.isEmpty()) {

             //get the number of years value from product
             ProductId = covgList[0].Product__c;
             list < product2 > productList = [select id, Number_of_Years__c from Product2 where id =: ProductId];
             numberOfYears = productList[0].Number_of_Years__c;
             category = covgList[0].Category;

             //Decimal remainingUnits;
             list < string > tempList2 = new list < string > ();
             list<string> rateTypeList = new list<string>();
             map<string,decimal> mapSchoolRatesValue = new map<string,decimal>();

             for (InsurancePolicyCoverage ir: covgList) {
                 rateTypeList.add(ir.Coverage_Type__c);
                 if (ir.category == 'University') {
                     if (ir.Coverage_Type__c == 'Tuition') {
                         tempList2.add('Tuition University');
                         mapSchoolRatesValue.put('Tuition University',ir.Tuition__c);
                         remainingUnits = ir.Tuition__c;
                     } else if (ir.Coverage_Type__c == 'Local') {
                         tempList2.add('Local University');
                         remainingUnits = ir.Local__c;
                         mapSchoolRatesValue.put('Local University',ir.Local__c);
                     } else if (ir.Coverage_Type__c == 'TDF') {
                         tempList2.add('TDF University');
                         remainingUnits = ir.TDF__c;
                         mapSchoolRatesValue.put('TDF University',ir.TDF__c);
                     }

                 } else if (ir.category == 'College' && ir.Number_of_Years__c < 3) {
                     if (ir.Coverage_Type__c == 'Tuition') {
                         tempList2.add('Tuition Lower Level');
                         remainingUnits = ir.Tuition_Lower__c;
                     } else if (ir.Coverage_Type__c == 'Local') {
                         tempList2.add('Local Lower Level');
                         remainingUnits = ir.Local_Lower__c;
                     }
                 } else if (ir.category == 'Bundled') {
                    // if (ir.category == 'University') {
                         if (ir.Coverage_Type__c == 'Tuition') {
                             tempList2.add('Tuition Lower Level');
                             remainingUnitsLower = ir.Tuition_Lower__c;
                             remainingUniVersityUnit = ir.Tuition__c;
                         } else if (ir.Coverage_Type__c == 'Local') {
                             tempList2.add('Local Lower Level');
                             remainingUnitsLower = ir.Local_Lower__c;
                             remainingUniVersityUnit = ir.Local__c;
                         }
                         
                     } else if (ir.category == 'Dorm') {
                         tempList2.add('Dorm University');
                         remainingUnits = ir.Dormitory__c;
                     }
                 
             }
             catLevelRate.put(category, tempList2);
             list < string > ratetype = new list<string>();
             if(category != 'Bundled'){
                 mapCategoryRateType.put(institutionType,rateTypeList);
                 system.debug('mapCategoryRateType'+mapCategoryRateType);
                 ratetype = mapCategoryRateType.get(institutionType);
             }else{
                 mapCategoryRateType.put(category,rateTypeList);
                 system.debug('mapCategoryRateType'+mapCategoryRateType);
                 ratetype = mapCategoryRateType.get(category);
             }
             

             //list < string > ratetype = mapCategoryRateType.get(institutionType);

             /*if (covgList[0].Category == 'University') {
                 category = 'University';
                 list < string > tempList = new list < string > {
                     'Tuition University',
                     'Local University',
                     'TDF University'
                 };
                 catLevelRate.put(covgList[0].Category, tempList);

                 //get the remaining Units
                 remainingUnits = covgList[0].Tuition__c;

             } else if (covgList[0].Category == 'College') {
                 category = 'College';
                 if (numberOfYears > 2) {
                     //remaining units value
                     remainingUnits = covgList[0].Tuition_Lower__c + covgList[0].Tuition_Upper__c;
                     remainingUnitsLower = covgList[0].Tuition_Lower__c;
                     remainingUnitsUpper = covgList[0].Tuition_Upper__c;

                     list < string > tempList = new list < string > {
                         'Tuition Lower Level',
                         'Local Lower Level'
                     };
                     catLevelRate.put(covgList[0].Category, tempList);

                 } else {

                     list < string > tempList = new list < string > {
                         'Tuition Lower Level',
                         'Local Lower Level'
                     };
                     catLevelRate.put(covgList[0].Category, tempList);
                     remainingUnits = covgList[0].Tuition_Lower__c;
                 }
             } else if (covgList[0].Category == 'Bundled') {
                 category = 'Bundled';

                 //remaining units value
                 //remainingUnits = covgList[0].Tuition_Lower__c + covgList[0].Tuition_Upper__c;
                 remainingUnitsLower = covgList[0].Tuition_Lower__c;
                 //remainingUnitsUpper = covgList[0].Tuition_Upper__c;
                 remainingUniVersityUnit = covgList[0].Tuition__c;
                 list < string > tempList = new list < string > {
                     'Tuition Lower Level',
                     'Local Lower Level'
                 };
                 catLevelRate.put(covgList[0].Category, tempList);


             } else if (covgList[0].Category == 'Dorm') {
                 category = 'Dorm';
                 isDormClaim = true;

                 list < string > tempList = new list < string > {
                     'Dormitory University'
                 };
                 catLevelRate.put(covgList[0].Category, tempList);

                 remainingUnits = covgList[0].Dormitory__c;
             }*/

    /*  if (category == institutionType) {
          string str;
          if (category == 'University' || (category == 'College' && numberOfYears <= 2)) {
              str = claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUnits, requestedAmountValue, catLevelRate,mapSchoolRatesValue);
              list < string > tempString = str.split(';');
              claimAmount = Decimal.valueof(tempString[0].trim());
              ActualUnit = Decimal.valueof(tempString[1].trim());
              system.debug('claimAmount' + claimAmount);
              system.debug('ActualUnit' + ActualUnit);

          } else if (category == 'College' && numberOfYears > 2) {
              if (requestedUnitValue < remainingUnitsLower) {
                  claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUnitsLower, requestedAmountValue, catLevelRate,mapSchoolRatesValue);

              } else if (requestedUnitValue > remainingUnitsLower) {
                  str = claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUnitsLower, requestedAmountValue, catLevelRate,mapSchoolRatesValue);
                  list < string > tempString = str.split(';');
                  claimAmount = Decimal.valueof(tempString[0].trim());
                  decimal claimAmountNew = claimAmount;

                  ActualUnit = Decimal.valueof(tempString[1].trim());
                  decimal actualUnitNew = ActualUnit;
                  decimal requestedAmountValueNew = Decimal.valueof(tempString[2].trim());
                  requestedAmountValueNew = requestedAmountValueNew - claimAmount;
                  list < string > tempList = new list < string > {
                      'Tuition Upper Level',
                      'Local Upper Level'
                  };
                  catLevelRate.put(Category, tempList);
                  string str2 = claimCalculationsInstitutionCategoryDiff(paymentMethod, institutionType, termValue, rateAmountInstitution, requestedUnitValue, ratetype, catLevelRate, category, ActualUnit, requestedAmountValueNew, mapCategoryRateType, remainingUnitsUpper, true, requestedAmountValue);
                  system.debug('str2' + str2);
                  list < string > tempString2 = str2.split(';');
                  claimAmount = claimAmountNew + Decimal.valueof(tempString2[0].trim());
                  ActualUnit = actualUnitNew + Decimal.valueof(tempString2[1].trim());
              }

          }

      } else if (category == 'Bundled') {
          string str;
          if (requestedUnitValue < remainingUnitsLower) {
              //str = claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUnitsLower, requestedAmountValue, catLevelRate);
              list<string> rateTypeVales = mapCategoryRateType.get(Category);
              mapCategoryRateType.put(institutionType,rateTypeVales);
              str = claimCalculationsInstitutionCategoryDiff(paymentMethod, institutionType, termValue, rateAmountInstitution, requestedUnitValue, ratetype, catLevelRate, category, ActualUnit, claimAmount, mapCategoryRateType, remainingUnitsLower, false, requestedAmountValue);
              list < string > tempString = str.split(';');
              claimAmount = Decimal.valueof(tempString[0].trim());
              ActualUnit = Decimal.valueof(tempString[1].trim());
              system.debug('claimAmount' + claimAmount);
              system.debug('ActualUnit' + ActualUnit);
          } else if (requestedUnitValue > remainingUnitsLower && requestedUnitValue < remainingUnitsLower + remainingUniVersityUnit) {
              //str = claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUnitsLower, requestedAmountValue, catLevelRate);
              list<string> rateTypeVales = mapCategoryRateType.get(Category);
              mapCategoryRateType.put(institutionType,rateTypeVales);
              str = claimCalculationsInstitutionCategoryDiff(paymentMethod, institutionType, termValue, rateAmountInstitution, requestedUnitValue, ratetype, catLevelRate, category, ActualUnit, claimAmount, mapCategoryRateType, remainingUnitsLower, false, requestedAmountValue);
              list < string > tempString = str.split(';');
              claimAmount = Decimal.valueof(tempString[0].trim());
              ActualUnit = Decimal.valueof(tempString[1].trim());
              decimal remainingAmount = Decimal.valueof(tempString[2].trim());
              system.debug('claimAmount' + claimAmount);
              system.debug('ActualUnit' + ActualUnit);
              Decimal claimAmountCollege = claimAmount;
              Decimal actualUnitCollege = ActualUnit;
              system.debug('claimAmountCollege' + claimAmountCollege);
              system.debug('actualUnitCollege' + actualUnitCollege);

              requestedAmountValue = remainingAmount - claimAmount;
              system.debug('requestedAmountValue' + requestedAmountValue);

              list < string > tempList = new list < string > {
                  'Tuition University',
                  'Local University',
                  'TDF University'
              };
              catLevelRate.put(Category, tempList);
              paymentMethod = 'Calculate Based on Amount Paid';
              string str2 = claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUniVersityUnit, requestedAmountValue, catLevelRate,mapSchoolRatesValue);
              list < string > tempString1 = str2.split(';');
              system.debug('claimamountNew' + Decimal.valueof(tempString1[0].trim()));
              system.debug('actualUnitNew' + Decimal.valueof(tempString1[1].trim()));
              claimAmount = claimAmountCollege + Decimal.valueof(tempString1[0].trim());
              ActualUnit = actualUnitCollege + Decimal.valueof(tempString1[1].trim());
              system.debug('claimAmount' + claimAmount);
              system.debug('ActualUnit' + ActualUnit);

          }

      } else {
          Boolean Flag = false;
          string str;
          if (institutionType != 'Average Rate') {
              paymentMethod = 'Calculate Based on Amount Paid';
          }
          str = claimCalculationsInstitutionCategoryDiff(paymentMethod, institutionType, termValue, rateAmountInstitution, requestedUnitValue, ratetype, catLevelRate, category, ActualUnit, claimAmount, mapCategoryRateType, remainingUnits, Flag, requestedAmountValue);
          list < string > tempString = str.split(';');
          claimAmount = Decimal.valueof(tempString[0].trim());
          ActualUnit = Decimal.valueof(tempString[1].trim());
          system.debug('claimAmount' + claimAmount);
          system.debug('ActualUnit' + ActualUnit);
          /*decimal totalRateAmountinstitution = 0;
          decimal totalRateAmountAverageRate = 0;
          paymentMethodval = 'Calculate Based on Amount Paid';
          list < string > instRatetype = mapCategoryRateType.get(institutionType);

          list < Average_School_Rates__c > InstavgSchoolRates = [Select Rate__c,
              Coverage_Type__c,
              Rate_Level__c,
              Institution_Type__c
              from Average_School_Rates__c
              where Institution_Type__c =: institutionType
              AND Coverage_Type__c IN: instRatetype
              AND Term__c =: termValue
          ];

          if (!InstavgSchoolRates.isEmpty()) {
              for (Average_School_Rates__c AV: InstavgSchoolRates) {
                  totalRateAmountinstitution += AV.Rate__c;
              }
              rateAmountInstitution = totalRateAmountinstitution;
              totalRateAmountinstitution = totalRateAmountinstitution * requestedUnitValue;
              system.debug('totalRateAmountinstitution' + totalRateAmountinstitution);
          }

          list < Average_School_Rates__c > avgSchoolRates = [Select Rate__c,
              Coverage_Type__c,
              Rate_Level__c,
              Institution_Type__c
              from Average_School_Rates__c
              where Institution_Type__c =: 'Average Rate'
              AND Coverage_Type__c IN: ratetype
              AND Term__c =: termValue
          ];

          if (!avgSchoolRates.isEmpty()) {
              list < string > rateLevelValues = catLevelRate.get(category);
              for (Average_School_Rates__c avgRat: avgSchoolRates) {
                  string temp = avgRat.Coverage_Type__c + ' ' + avgRat.Rate_Level__c;
                  system.debug('rateLevelValues' + rateLevelValues);
                  system.debug('Coverage_Type__c' + avgRat.Coverage_Type__c);

                  if (rateLevelValues.contains(temp)) {
                      totalRateAmountAverageRate += avgRat.Rate__c;
                  }
              }
              totalRateAmountAverageRate = totalRateAmountAverageRate * remainingUnits;
              system.debug('remaining units' + remainingUnits);
              system.debug('totalRateAmountAverageRate' + totalRateAmountAverageRate);
          }

          // system.debug('avgschool rates' + avgSchoolRates);
          decimal tempVar = (totalRateAmountinstitution / totalRateAmountAverageRate) * 100;
          system.debug('tempVar' + tempVar);

          if (tempVar < 100) {
              decimal tempVar2 = (remainingUnits / 100) * tempVar;
              system.debug('tempVar2 value' + tempVar2);

              ActualUnit = tempVar2;
              claimAmount = totalRateAmountinstitution;
          }
          else {
                                      ActualUnit = remainingUnits;
                                      claimAmount = totalRateAmountAverageRate;
                                      decimal remainingAmount;
                                      remainingAmount = totalRateAmountinstitution - totalRateAmountAverageRate;
                                      decimal newRemainingUnits;
                                      newRemainingUnits = remainingUniVersityUnit;
                                      decimal tempAmount;
                                      tempAmount = rateAmountInstitution * newRemainingUnits;

                                      decimal tempVar3 = (remainingAmount / tempAmount) * 100;

                                      decimal newActualUnits;
                                      newActualUnits = (newRemainingUnits / 100) * tempVar3;



                                      claim cl2 = new claim();
                                      cl2.AccountId = nameinsuredId;
                                      cl2.Educational_Institutes__c = schoolId;
                                      cl2.Name = 'Claim - ' + DateTime.now().getTime();
                                      cl2.PolicyNumberId = policyId;
                                      cl2.Term__c = termValue;
                                      cl2.Year__c = yearValue;
                                      cl2.Actual_Unit__c = newActualUnits;
                                      cl2.Claim_Amount__c = remainingAmount;
                                      cl2.ClaimType = claimTypeValue;
                                      cl2.Estimated_Hours__c = requestedUnitValue;
                                      //cl.Requested_Amount__c = requestedAmount;
                                      cl2.Requested_Amount__c = requestedAmountValue;
                                      cl2.Payment_Methodology__c = paymentMethodval;
                                      subClaimList.add(cl2);


                                  }*/




    /*  }
                }
            }

            system.debug('selected value' + schoolId);
            cl.AccountId = nameinsuredId;
            cl.Educational_Institutes__c = schoolId;
            cl.Name = 'Claim - ' + DateTime.now().getTime();
            cl.PolicyNumberId = policyId;
            cl.Term__c = termValue;
            cl.Year__c = yearValue;
            cl.Actual_Unit__c = ActualUnit;
            cl.Claim_Amount__c = claimAmount;
            cl.ClaimType = claimTypeValue;
            cl.Estimated_Hours__c = requestedUnitValue;
            //cl.Requested_Amount__c = requestedAmount;
            if (category == 'Bundled') {
                cl.Requested_Amount__c = claimRequestedAmount;
            } else {
                cl.Requested_Amount__c = requestedAmountValue;
            }
            cl.Payment_Methodology__c = paymentMethod;

            insert cl;

            creatClaimItems(coveragePlanId, cl.id);

            if (!subClaimList.isEmpty()) {
                insert subClaimList;
                creatClaimItems(coveragePlanId, subClaimList[0].id);

            }



            if (!files.isEmpty()) {
                List < ContentVersion > relatedDocuments = new List < ContentVersion > ();
                for (Map < String, Object > file: files) {
                    String fileJson = JSON.serialize(file);
                    relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
                    ContentVersion contentVersionFile = new ContentVersion();
                    contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
                    contentVersionFile.Title = relatedDocument.Title;
                    contentVersionFile.VersionData = relatedDocument.VersionData;
                    relatedDocuments.add(contentVersionFile);
                }

                if (!relatedDocuments.isEmpty()) {
                    insert relatedDocuments;
                }

                set < id > contentVersionIds = new set < id > ();
                map < id, id > contentVersionDocMap = new map < id, id > ();
                list < ContentDocumentLink > conDocList = new list < ContentDocumentLink > ();

                for (ContentVersion cv: relatedDocuments) {
                    contentVersionIds.add(cv.id);
                }

                list < ContentVersion > docList = [SELECT id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionIds];


                if (!docList.isEmpty()) {
                    for (ContentVersion cd: docList) {
                        contentVersionDocMap.put(cd.id, cd.ContentDocumentId);
                    }
                }

                if (!contentVersionDocMap.isEmpty()) {
                    for (id ids: contentVersionDocMap.keyset()) {
                        ContentDocumentLink cdl = New ContentDocumentLink();
                        cdl.LinkedEntityId = cl.Id;
                        cdl.ContentDocumentId = contentVersionDocMap.get(ids);
                        cdl.shareType = 'V';
                        conDocList.add(cdl);
                    }

                    if (!conDocList.isEmpty()) {
                        insert conDocList;
                    }
                }
            }
            return cl.id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/

    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }

    public class actualUnitClaimAmountWrapper {
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