/* Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/14/2021   Satish Nikam    Task-10817 - T2 - Update Policy Status from Active to Paid in Full
**/
global class PrepaidPremiumPaymentBatch implements
    Database.Batchable<sObject>, Database.Stateful{
    global Integer recordsProcessed = 0;
    public static String STATUS_PAID_IN_FULL = 'Paid in Full';

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            ' select Id,Finance_Charge__c,Insurance_Policy_Coverage__c,Premium_Date__c,Premium_Amount__c,Start_Date__c,Prepaid_Policy__c,' +
            ' Price__c,Insurance_Policy_Coverage__r.Payment_Count__c,Total_Principal_Amount_Paid__c,Finance_Charge_Amount_Paid__c '+
            ' from Prepaid_Finance_History__c where Start_Date__c = Today and Status__c = \'Active\' ');
			
    }
    public void execute(Database.BatchableContext bc, List<Prepaid_Finance_History__c> records){
      Double financeChargeAmt;
      Double principalAmt;
      Decimal paymentCount;
      Double totalPremiumPaid;
      Double remainingBalance;

      Map<Id,InsurancePolicyCoverage> insurancePolicyCoverageMap = new Map<Id,InsurancePolicyCoverage>();
      List<Prepaid_Finance_History__c> prepaidFinHistList = new List<Prepaid_Finance_History__c>();
        
      if(records.size()>0)//batch input is not null
        {   
            Set<Id> prepaidPolicyIdList = new Set<Id>();//Task-10817         
            for(Prepaid_Finance_History__c pfh : records)
            {
                InsurancePolicyCoverage ipc = new InsurancePolicyCoverage();
                financeChargeAmt = 0.0;
                principalAmt = 0.0;
                financeChargeAmt = ((pfh.Price__c - pfh.Total_Principal_Amount_Paid__c) * (pfh.Finance_Charge__c/12))/100;
                principalAmt = pfh.Premium_Amount__c - financeChargeAmt;
                pfh.Total_Principal_Amount_Paid__c = pfh.Total_Principal_Amount_Paid__c + principalAmt;
                pfh.Finance_Charge_Amount_Paid__c = pfh.Finance_Charge_Amount_Paid__c + financeChargeAmt;
                paymentCount = pfh.Insurance_Policy_Coverage__r.Payment_Count__c + 1;
                ipc.Payment_Count__c = paymentCount;
                pfh.Payment_Count__c = paymentCount;
                totalPremiumPaid = pfh.Premium_Amount__c * paymentCount;
                remainingBalance = pfh.Price__c - totalPremiumPaid;
                pfh.Remaining_Balance__c = remainingBalance;
                ipc.id = pfh.Insurance_Policy_Coverage__c;
                Date nextPremiumDueDate = pfh.Premium_Date__c.addMonths(1);
                ipc.Start_Date__c = nextPremiumDueDate;
                pfh.Premium_Date__c = nextPremiumDueDate;
                if(remainingBalance < = 0){
                    ipc.Status__c = STATUS_PAID_IN_FULL;
                }
                insurancePolicyCoverageMap.put(ipc.Id,ipc);
                prepaidFinHistList.add(pfh);
                prepaidPolicyIdList.add(pfh.Prepaid_Policy__c);//Task-10817 
            }
      		List<InsurancePolicyCoverage> noDupes = insurancePolicyCoverageMap.Values();
            System.debug('noDupes-->'+noDupes);
            System.debug('prepaidFinHistList-->'+prepaidFinHistList);
            Savepoint sp = Database.setSavepoint();
            try{
                if(!noDupes.isEmpty() && Schema.sObjectType.InsurancePolicyCoverage.fields.Start_Date__c.isUpdateable()) {
                    update(noDupes);
                }
            }Catch(Exception ex){
                System.debug('Error while updating InsurancePolicyCoverage :'+ ex.getMessage());
                Database.rollback(sp);
                return;
            }
            try{
                if(!prepaidFinHistList.isEmpty() && Schema.sObjectType.Prepaid_Finance_History__c.fields.Total_Principal_Amount_Paid__c.isUpdateable()) {
                    update(prepaidFinHistList);
                }
            }Catch(Exception ex){
                System.debug('Error while updating Prepaid_Finance_History__c :'+ ex.getMessage());
                Database.rollback(sp);
                return;
            }
            
            //Start-Task-10817 
            List<InsurancePolicy> policyRecordsToUpdate = new List<InsurancePolicy>();
            for(InsurancePolicy policyRecord:[Select Id,Price__c,Total_Premium__c,Status 
                                              From InsurancePolicy 
                                              Where Id IN :prepaidPolicyIdList]){

                if(policyRecord.Price__c == policyRecord.Total_Premium__c){
                    policyRecord.Status = STATUS_PAID_IN_FULL;
                    policyRecordsToUpdate.add(policyRecord);
                }
            }

            System.debug('prepaidFinHistList-->'+prepaidFinHistList);
            if(!policyRecordsToUpdate.isEmpty() ){
                try{
                    if(Schema.sObjectType.InsurancePolicy.fields.Price__c.isUpdateable()) {
                        update policyRecordsToUpdate;
                    }
                }Catch(Exception ex){
                    System.debug('Error while updating InsurancePolicy Status :'+ ex.getMessage());
                }
            }
            //End-Task-10817 
        }
    }
    public void finish(Database.BatchableContext bc){
        
    }
}