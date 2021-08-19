public with sharing class CancelPrepaidUnitsController {

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
    public static void cancelUnits( String coveragePlanId,String requestedAmountValue , String requestedUnitsValue){

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

       
    Savepoint sp = Database.setSavepoint(); 
     map < string, object > mapCoverageUnitValue = new map < string, object > ();
     try{
        InsurancePolicyCoverage  insurancePolicyCoverage = [SELECT id,Prepaid_Pricebook_Entry__c,Coverage_Type__c,Tuition__c,
        Tuition_Lower__c,Tuition_Upper__c,Local_Upper__c,Local_Lower__c,
        TDF__c,Local__c,Category,Dormitory__c
                    FROM InsurancePolicyCoverage WHERE id =: coveragePlanId WITH SECURITY_ENFORCED];

            for (string str: CovgUnitList) {
                if (insurancePolicyCoverage.get(str) != null) {
                    mapCoverageUnitValue.put(str, insurancePolicyCoverage.get(str));
                }
            }

            Prepaid_Finance_History__c prepaidFinanceHistory =   [ select Id,Price__c,Total_Principal_Amount_Paid__c ,End_Date__c, 
            Remaining_Balance__c , Premium_Due_Amount__c,Premium_Date__c,Unit_Type__c,Unit_Category__c,Unit_Price__c,No_of_Units__c,Total_Price__c
            from Prepaid_Finance_History__c where Status__c = 'Active' and Insurance_Policy_Coverage__c =: coveragePlanId WITH SECURITY_ENFORCED];

            Double cancellationAmt = 0.0;
            Double coverageUnits = 0.0;
            Double cancellationUnits = 0 ;
            String unitType = prepaidFinanceHistory.Unit_Type__c;
            String category = prepaidFinanceHistory.Unit_Category__c;

            system.debug('unitType >>>>>>>' + unitType + 'category >>>>>>>' + category );
            
            for (string str1: CovgUnitList) {
                if ((Decimal)(mapCoverageUnitValue.get(str1)) > 0){
                    coverageUnits = Double.valueOf((mapCoverageUnitValue.get(str1)));
                    if (coverageUnits >= Double.valueOf(requestedUnitsValue)) {
                                system.debug('coverageUnits >>>>>>>>>' + (Decimal)(mapCoverageUnitValue.get(str1)));
                                cancellationUnits = Double.valueOf(requestedUnitsValue);
                                cancellationAmt = cancellationAmt +  prepaidFinanceHistory.Unit_Price__c * cancellationUnits;
                                system.debug('cancellationAmt >>>>>>>>>' + cancellationAmt);    
                                //insurancePolicyCoverage + '.' +str1 = (Double)coverageUnits - requestedUnitsValue;
                    }else{
                                system.debug('coverageUnits ************' + (Decimal)(mapCoverageUnitValue.get(str1)));
                                cancellationUnits = coverageUnits;
                                cancellationAmt = cancellationAmt +  prepaidFinanceHistory.Unit_Price__c * coverageUnits;
                                system.debug('cancellationAmt ********* ' + cancellationAmt); 
                                //insurancePolicyCoverage + '.' +str1 = 0;   
                    }
                }
            }

                Double newRemainingBalance = 0.0;
                Decimal newNoOfPayments = 0;
                Double financeChargeAmt;
                Double newPremiumAmt;
            // Double financeCharge = prepaidFinanceHistory.Finance_Charge__c;
            
                newRemainingBalance = prepaidFinanceHistory.Remaining_Balance__c - cancellationAmt;
                prepaidFinanceHistory.Remaining_Balance__c = newRemainingBalance;
                system.debug('newRemainingBalance >>>>>>>' + newRemainingBalance);

        
                newNoOfPayments = newRemainingBalance / prepaidFinanceHistory.Premium_Due_Amount__c;
                newNoOfPayments = newNoOfPayments.round(System.RoundingMode.UP);
                system.debug('newNoOfPayments >>>>>>>' + newNoOfPayments);
                String strNewNoOfPayments = String.valueOf(newNoOfPayments);
                Date newEndDate = prepaidFinanceHistory.Premium_Date__c.addMonths(Integer.valueOf(strNewNoOfPayments));
                prepaidFinanceHistory.End_Date__c = newEndDate;
                prepaidFinanceHistory.Cancellation_Amount__c = cancellationAmt;
                prepaidFinanceHistory.No_of_Units__c = prepaidFinanceHistory.No_of_Units__c - cancellationUnits;
                prepaidFinanceHistory.Total_Price__c = prepaidFinanceHistory.Total_Price__c - cancellationAmt;
                system.debug('newEndDate >>>>>>>' + newEndDate);
            
            // newPremiumAmt=calculatePMT(financeCharge,Double.valueOf(strNewNoOfPayments),newRemainingBalance);
                system.debug('newPremiumAmt' + newPremiumAmt);
                if (Schema.sObjectType.Prepaid_Finance_History__c.isUpdateable()) {
                    update prepaidFinanceHistory;
                }

                Prepaid_Finance_History__c newPrepaidFinanceHistory = new Prepaid_Finance_History__c();

                newPrepaidFinanceHistory.Cancellation_Amount__c = cancellationAmt;
                newPrepaidFinanceHistory.Start_Date__c = System.today();
                prepaidFinanceHistory.End_Date__c = System.today();
                newPrepaidFinanceHistory.Status__c = 'Inactive';
                newPrepaidFinanceHistory.Unit_Type__c = prepaidFinanceHistory.Unit_Type__c;
                newPrepaidFinanceHistory.Unit_Category__c = newPrepaidFinanceHistory.Unit_Category__c;
                newPrepaidFinanceHistory.Finance_Charge__c = 0.0;
                if (coverageUnits >= Double.valueOf(requestedUnitsValue)){
                    newPrepaidFinanceHistory.No_of_Units__c = Double.valueOf(requestedUnitsValue); 
                }else{
                    newPrepaidFinanceHistory.No_of_Units__c = 0;
                }
                newPrepaidFinanceHistory.Insurance_Policy_Coverage__c = coveragePlanId;
                newPrepaidFinanceHistory.IsLumpsumPayment__c = true;
                
                if (Schema.sObjectType.Prepaid_Finance_History__c.isCreateable()) {
                    insert newPrepaidFinanceHistory;
                }
                
                if(unitType == 'Tuition'){
                    system.debug('Tuition cancellation Units >>>>>>>>>' + cancellationUnits);  
                    insurancePolicyCoverage.Tuition__c = insurancePolicyCoverage.Tuition__c-cancellationUnits;
                }else if(unitType == 'Local'){
                    system.debug('Local cancellation Units >>>>>>>>>' + cancellationUnits);
                    insurancePolicyCoverage.Local__c = insurancePolicyCoverage.Local__c-cancellationUnits;
                }else if(unitType == 'TDF'){
                    system.debug('TDF cancellation Units >>>>>>>>>' + cancellationUnits);
                    insurancePolicyCoverage.TDF__c = insurancePolicyCoverage.TDF__c-cancellationUnits;
                }else if(unitType == 'Tuition Lower'){
                    system.debug('Tuition Lower cancellation Units >>>>>>>>>' + cancellationUnits);
                    insurancePolicyCoverage.Tuition_Lower__c = insurancePolicyCoverage.Tuition_Lower__c-cancellationUnits;
                }else if(unitType == 'Tuition Upper'){
                    system.debug('Tuition Upper cancellation Units >>>>>>>>>' + cancellationUnits);
                    insurancePolicyCoverage.Tuition_Upper__c = insurancePolicyCoverage.Tuition_Upper__c-cancellationUnits;
                }else if(unitType == 'Local Upper'){
                    system.debug('Local Upper cancellation Units >>>>>>>>>' + cancellationUnits);
                    insurancePolicyCoverage.Local_Upper__c = insurancePolicyCoverage.Local_Upper__c-cancellationUnits;
                }else if(unitType == 'Local Lower'){
                    system.debug('Local Lower cancellation Units >>>>>>>>>' + cancellationUnits);
                    insurancePolicyCoverage.Local_Lower__c = insurancePolicyCoverage.Local_Lower__c-cancellationUnits;
                }
                if (Schema.sObjectType.InsurancePolicyCoverage.isUpdateable()) {
                    update insurancePolicyCoverage;
                }
                
            }catch(dmlexception e){
                Database.rollback(sp);
            }
    }
}