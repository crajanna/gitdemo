global class CashAccountLateFeesBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Integer txnRrecordsCreated = 0;
    global Integer Transfer_cashAccProcessed = 0;
    public List<Profile> syspid = [select id from Profile where Profile.Name = 'System Administrator'];
    Decimal LateFeeCharges = Static_Values__c.getInstance(syspid[0].Id).Late_Fee__c;
    
   	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
           'select id,FinServ__Status__c,Available_Balance__c from FinServ__FinancialAccount__c where RecordType.Name = \'General Account\' and FinServ__Status__c =\'Active\' and Available_Balance__c <0'
        );
        
    }    
    public void execute(Database.BatchableContext bc, List<FinServ__FinancialAccount__c> records)
    {
        
        if(LateFeeCharges == null)
           LateFeeCharges = 0;
       
        if(records.size()>0)//batch input is not null
        {
       	     	List<FinServ__FinancialAccountTransaction__c> finTranscList = new List<FinServ__FinancialAccountTransaction__c>(); 
            for(FinServ__FinancialAccount__c ca : records)
            {
            	FinServ__FinancialAccountTransaction__c tempFin_txn = new FinServ__FinancialAccountTransaction__c(); 
                FinServ__FinancialAccount__c temp_cashAcc = ca;
                system.debug('late fee charges: '+LateFeeCharges);
                tempFin_txn.FinServ__Amount__c = LateFeeCharges;
                tempFin_txn.FinServ__PostDate__c = DateTime.now();
                tempFin_txn.FinServ__TransactionType__c = 'Debit';
                tempFin_txn.FinServ__TransactionSubtype__c = 'Fee';
				tempFin_txn.Sub_Type_Description__c = 'Late Fee';
                tempFin_txn.Source_Type__c = 'Cash Account';
               	tempFin_txn.FinServ__FinancialAccount__c = ca.id;
                tempFin_txn.FinServ__TransactionStatus__c = 'Posted';
                tempFin_txn.FinServ__TransactionDate__c = DateTime.now();
  		          finTranscList.add(tempFin_txn);   
            }
               txnRrecordsCreated = finTranscList.size();
               Transfer_cashAccProcessed = records.size();
                insert(finTranscList);
        }
        }
    
    public void finish(Database.BatchableContext bc)
    {
          AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        //JobEmailUtility.sendMessage(job, txnRrecordsCreated);
    }
}