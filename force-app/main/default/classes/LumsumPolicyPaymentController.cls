public with sharing class LumsumPolicyPaymentController {

    @AuraEnabled(cacheable=true) 
    public static List<InsurancePolicyCoverage> getPolicyCoverages(String policyId){
        System.debug('getPolicyCoverages >>>>' + policyId);
        try {
            List<InsurancePolicyCoverage> policyCoveragesList = [SELECT Id, CoverageName,InsurancePolicy.Price__c FROM InsurancePolicyCoverage where InsurancePolicyId= :policyId  WITH SECURITY_ENFORCED];
            return policyCoveragesList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void lumpsumPayments( String coveragePlanId,String dueDate , String lumSumAmount,String type){
        Savepoint sp = Database.setSavepoint(); 
        try{
            Prepaid_Finance_History__c prepaidFinanceHistory =   [ select Id,Price__c,Total_Principal_Amount_Paid__c ,End_Date__c, 
            Remaining_Balance__c , Premium_Due_Amount__c,Premium_Date__c,Unit_Type__c,Unit_Category__c,Finance_Charge__c
            from Prepaid_Finance_History__c where Status__c = 'Active' and Insurance_Policy_Coverage__c =: coveragePlanId WITH SECURITY_ENFORCED];

            Double newRemainingBalance = 0.0;
            Decimal newNoOfPayments = 0;
            Double financeChargeAmt;
            Double newPremiumAmt;
            Double financeCharge = prepaidFinanceHistory.Finance_Charge__c;

            
            if(type == 'Reversal'){
                newRemainingBalance = prepaidFinanceHistory.Remaining_Balance__c + Double.valueOf(lumSumAmount);
            }else{
                newRemainingBalance = prepaidFinanceHistory.Remaining_Balance__c - Double.valueOf(lumSumAmount);
            }
            prepaidFinanceHistory.Remaining_Balance__c = newRemainingBalance;
            system.debug('newRemainingBalance >>>>>>>' + newRemainingBalance);

            if(newRemainingBalance > 0){
                newNoOfPayments = newRemainingBalance / prepaidFinanceHistory.Premium_Due_Amount__c;
                newNoOfPayments = newNoOfPayments.round(System.RoundingMode.UP);
                system.debug('newNoOfPayments >>>>>>>' + newNoOfPayments);
                String strNewNoOfPayments = String.valueOf(newNoOfPayments);
                Date newEndDate = prepaidFinanceHistory.Premium_Date__c.addMonths(Integer.valueOf(strNewNoOfPayments));
                prepaidFinanceHistory.End_Date__c = newEndDate;
                //prepaidFinanceHistory.Lumpsum_Amount__c = Double.valueOf(lumSumAmount);
                system.debug('newEndDate >>>>>>>' + newEndDate);
                financeChargeAmt = ((newRemainingBalance) * (prepaidFinanceHistory.Finance_Charge__c/12))/100;
                system.debug('financeChargeAmt >>>>>>>' + financeChargeAmt);

            // newPremiumAmt=calculatePMT(financeCharge,Double.valueOf(strNewNoOfPayments),newRemainingBalance);
                system.debug('newPremiumAmt' + newPremiumAmt);

                update prepaidFinanceHistory;
            
            }

            Prepaid_Finance_History__c newPrepaidFinanceHistory = new Prepaid_Finance_History__c();
            if(type == 'Reversal'){
                newPrepaidFinanceHistory.Lumpsum_Amount__c = Double.valueOf(lumSumAmount) * -1 ;
            }else{
                newPrepaidFinanceHistory.Lumpsum_Amount__c = Double.valueOf(lumSumAmount);
            }
            Date transactionDate = Date.valueOf(dueDate);
            system.debug('startDate >>>>>>>' + transactionDate);
            newPrepaidFinanceHistory.Start_Date__c = transactionDate;
            prepaidFinanceHistory.End_Date__c = transactionDate;
            newPrepaidFinanceHistory.Status__c = 'Inactive';
            newPrepaidFinanceHistory.Unit_Type__c = prepaidFinanceHistory.Unit_Type__c;
            newPrepaidFinanceHistory.Unit_Category__c = newPrepaidFinanceHistory.Unit_Category__c;
            newPrepaidFinanceHistory.Finance_Charge__c = 0.0;
            newPrepaidFinanceHistory.Insurance_Policy_Coverage__c = coveragePlanId;
            newPrepaidFinanceHistory.IsLumpsumPayment__c = true;

            insert newPrepaidFinanceHistory;
        }catch(dmlexception e){
            Database.rollback(sp);
        }
    }

    /*
     * 
     * Calculate monthly payments
     * 
     * @param rate
       *     Annual interest rate divided by 12 is the monthly interest rate
     * @param nper
           * The total number of payments. 
     * @param pv
           * current value of a series of future payments, also known as the principal. 
     * @return
     * 
     */
    private static Double calculatePMT(Double rate, Double nper, Double pv) {
        Double v = (1 + (rate / 12));
        Double t = (-(nper / 12) * 12);
        Double result = (pv * (rate / 12)) / (1 - Math.pow(v, t));
        return result;
    }


}