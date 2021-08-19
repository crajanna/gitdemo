public with sharing class claimApprovalApex {

    @AuraEnabled
    public static map < string, string > claimTypes() {
        try {
            map<string,string> mapClaimType = new map<string,string>();
            Schema.DescribeFieldResult fieldResult = Claim.ClaimType.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal: ple) {
                mapClaimType.put(pickListVal.getLabel(),pickListVal.getValue());
            }
            return mapClaimType;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static map < string, string > claimPaymentMethod() {
        try {
            map<string,string> mapPaymentMethod = new map<string,string>();
            Schema.DescribeFieldResult fieldResult = Claim.Payment_Methodology__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal: ple) {
                mapPaymentMethod.put(pickListVal.getLabel(),pickListVal.getValue());
            }
            return mapPaymentMethod;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static claim claimRecord(id recordId) {
        try {
            
            claim cm = [SELECT Id,
            Estimated_Hours__c,
            Requested_Amount__c,
            ClaimType,
            Payment_Methodology__c,
            Status,
            Claim_Amount__c
            From claim 
            WHERE id =: recordId];

            return cm;

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
            //ClaimUnitValues c = (ClaimUnitValues) JSON.deserializeUntyped(claimUnits, ClaimUnitValues.class);
            //List<Object> listObj = (List<Object>)System.JSON.deserializeUntyped(t);
            //system.debug('c..............'+c);
            list<claim> cm = [SELECT Id,
            Estimated_Hours__c,
            Requested_Amount__c,
            ClaimType,
            Payment_Methodology__c,
            Tuition__c,
            Tuition_Lower__c,
            Tuition_Upper__c,
            Local__c,
            Local_Lower__c,
            Local_Upper__c,
            Dormitory__c,
            TDF__c
            From claim 
            WHERE id =: recordId];

           // if(requestedUnitValue != cm[0].Estimated_Hours__c || requestedAmountVal != cm[0].Requested_Amount__c || claimType != cm[0].ClaimType || paymentType != cm[0].Payment_Methodology__c){
                 cm[0].Estimated_Hours__c = requestedUnitValue;
                 cm[0].Requested_Amount__c = requestedAmountVal;
                 cm[0].ClaimType = claimType;
                 cm[0].Payment_Methodology__c = paymentType;
                 //cm[0].Restrict_Update__c = true;
                 cm[0].Claim_Amount__c = claimAmountValue;
                 cm[0].Actual_Unit__c = actualUnitValue;

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
           // }
            str = 'Success';
            return str;

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

    /*@AuraEnabled
    public static string policyPaymentMethod(id recordId) {
        try {
            
            string paymentType;
            list<claim> cm = [SELECT Id,PolicyNumberId
            
            From claim 
            WHERE id =: recordId];

            if(!cm.isEmpty()){
                system.debug('ddd'+cm[0].PolicyNumberId);
                List<InsurancePolicy> policyList = [SELECT id,
                Payment_Methodology__c 
                FROM InsurancePolicy 
                WHERE id =: cm[0].PolicyNumberId];

                if(!policyList.isEmpty()){
                    paymentType = policyList[0].Payment_Methodology__c;
                }
            }

            return paymentType;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/

    @AuraEnabled
    public static  map < string, decimal > recalculateClaim(id recordId,decimal requestedUnitValue, decimal requestedAmountVal,string claimType, string paymentType) {
        try {
            
            string str;
            map < string, decimal > unitNameActualUnit = new map < string, decimal > ();

            list<claim> cm = [SELECT Id,
            PolicyNumberId,
            Educational_Institutes__c,
            Term__c,
            Year__c
            From claim 
            WHERE id =: recordId];

            if(!cm.isEmpty()){
                list < insurancePolicy > policyList = [Select id,
                    NameInsuredId,
                    Payment_Methodology__c,
                    (Select id,
                        Product__c,
                        Tuition__c,
                        Tuition_Lower__c,
                        Tuition_Upper__c,
                        Local_Upper__c,
                        Local_Lower__c,
                        TDF__c,
                        Local__c,
                        Category,
                        Coverage_Type__c,
                        Number_of_Years__c,
                        Dormitory__c FROM InsurancePolicyCoverages)
                    From insurancePolicy
                    Where id =: cm[0].PolicyNumberId];

                List<String> coveragePlanId = new List<String>();
                for(InsurancePolicyCoverage ipc : policyList[0].InsurancePolicyCoverages)  
                {
                    coveragePlanId.add(ipc.Id);
                } 

                //str = createClaim(cm[0].Educational_Institutes__c,cm[0].Term__c,cm[0].Year__c,claimType,requestedUnitValue,requestedAmountVal,policyList[0]);
                ClaimProcessApex.actualUnitClaimAmountWrapper wrapper = ClaimProcessApex.actualUnitCalculations(cm[0].Educational_Institutes__c,cm[0].Term__c,cm[0].Year__c,claimType,requestedUnitValue, coveragePlanId, null, requestedAmountVal, policyList[0].Id,false,false);
                unitNameActualUnit = wrapper.mapCoverageActualUnit;
                System.debug('unitNameActualUnit................'+unitNameActualUnit);
                
            }
            return unitNameActualUnit;

            //return str;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public Map<String, Decimal> calculateUnit (string schoolId, string termValue, string yearValue, string claimTypeValue, decimal requestedUnitValue, decimal requestedAmountValue, Id policyId)
    {
        Map<String,Decimal> mapUnit = new Map<String,Decimal>();

        return mapUnit;
    }

    public static string createClaim(string schoolId, string termValue, string yearValue, string claimTypeValue, decimal requestedUnitValue, decimal requestedAmountValue, InsurancePolicy policy) {
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


            nameinsuredId = policy.NameInsuredId;
            paymentMethod = policy.Payment_Methodology__c;


            //get the instituition type
            list < account > instType = [select id, Institution_Type__c from Account where id =: schoolId];
            string institutionType;
            if (!instType.isEmpty()) {
                institutionType = instType[0].Institution_Type__c;
            }

            //get the coverages
            list < InsurancePolicyCoverage > covgList = policy.InsurancePolicyCoverages;

            list < string > coveragePlanId = new list < string > ();
            for (InsurancePolicyCoverage ic: covgList) {
                coveragePlanId.add(ic.id);
            }

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

                 for (InsurancePolicyCoverage ir: covgList) {
                     rateTypeList.add(ir.Coverage_Type__c);
                     if (ir.category == 'University') {
                         if (ir.Coverage_Type__c == 'Tuition') {
                             tempList2.add('Tuition University');
                             remainingUnits = ir.Tuition__c;
                         } else if (ir.Coverage_Type__c == 'Local') {
                             tempList2.add('Local University');
                             remainingUnits = ir.Local__c;
                         } else if (ir.Coverage_Type__c == 'TDF') {
                             tempList2.add('TDF University');
                             remainingUnits = ir.TDF__c;
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

                if (category == institutionType) {
                    string str;
                    if (category == 'University' || (category == 'College' && numberOfYears <= 2)) {
                        str = SchoolInvoiceCalculations.claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUnits, requestedAmountValue, catLevelRate);
                        list < string > tempString = str.split(';');
                        claimAmount = Decimal.valueof(tempString[0].trim());
                        ActualUnit = Decimal.valueof(tempString[1].trim());
                        system.debug('claimAmount' + claimAmount);
                        system.debug('ActualUnit' + ActualUnit);

                    } else if (category == 'College' && numberOfYears > 2) {
                        if (requestedUnitValue < remainingUnitsLower) {
                            SchoolInvoiceCalculations.claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUnitsLower, requestedAmountValue, catLevelRate);

                        } else if (requestedUnitValue > remainingUnitsLower) {
                            str = SchoolInvoiceCalculations.claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUnitsLower, requestedAmountValue, catLevelRate);
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
                            string str2 = SchoolInvoiceCalculations.claimCalculationsInstitutionCategoryDiff(paymentMethod, institutionType, termValue, rateAmountInstitution, requestedUnitValue, ratetype, catLevelRate, category, ActualUnit, requestedAmountValueNew, mapCategoryRateType, remainingUnitsUpper, true, requestedAmountValue);
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
                        str = SchoolInvoiceCalculations.claimCalculationsInstitutionCategoryDiff(paymentMethod, institutionType, termValue, rateAmountInstitution, requestedUnitValue, ratetype, catLevelRate, category, ActualUnit, claimAmount, mapCategoryRateType, remainingUnitsLower, false, requestedAmountValue);
                        list < string > tempString = str.split(';');
                        claimAmount = Decimal.valueof(tempString[0].trim());
                        ActualUnit = Decimal.valueof(tempString[1].trim());
                        system.debug('claimAmount' + claimAmount);
                        system.debug('ActualUnit' + ActualUnit);
                    } else if (requestedUnitValue > remainingUnitsLower && requestedUnitValue < remainingUnitsLower + remainingUniVersityUnit) {
                        //str = claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUnitsLower, requestedAmountValue, catLevelRate);
                        str = SchoolInvoiceCalculations.claimCalculationsInstitutionCategoryDiff(paymentMethod, institutionType, termValue, rateAmountInstitution, requestedUnitValue, ratetype, catLevelRate, category, ActualUnit, claimAmount, mapCategoryRateType, remainingUnitsLower, false, requestedAmountValue);
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
                        string str2 = SchoolInvoiceCalculations.claimCalculations(institutionType, termValue, rateType, Category, requestedUnitValue, paymentMethod, remainingUniVersityUnit, requestedAmountValue, catLevelRate);
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
                    str = SchoolInvoiceCalculations.claimCalculationsInstitutionCategoryDiff(paymentMethod, institutionType, termValue, rateAmountInstitution, requestedUnitValue, ratetype, catLevelRate, category, ActualUnit, claimAmount, mapCategoryRateType, remainingUnits, Flag, requestedAmountValue);
                    list < string > tempString = str.split(';');
                    claimAmount = Decimal.valueof(tempString[0].trim());
                    ActualUnit = Decimal.valueof(tempString[1].trim());
                    system.debug('claimAmount' + claimAmount);
                    system.debug('ActualUnit' + ActualUnit);

                }
            }
            string claimAmountActualUnit = string.valueof(claimAmount) + ';' + string.valueof(actualUnit);
            system.debug('claim amount and actual unit values'+claimAmountActualUnit);
            return claimAmountActualUnit;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ClaimUnitValues {
        public String label {get; set;}
        public String value {get; set;}
    }
}