global class CreateCashAccountBatch implements
    Database.Batchable<sObject>, Database.Stateful {
    global Integer recordsProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {    
        return Database.getQueryLocator(
            'select FinServ__PrimaryOwner__c from FinServ__FinancialAccount__c where  RecordTypeId = \'0124W000001bAJsQAM\'');  
    }
        
    public void execute(Database.BatchableContext bc, List<FinServ__FinancialAccount__c> records)
    { 
        if(records.size()>0)//batch input is not null
        {   
            List<FinServ__FinancialAccount__c> financialAccList = new List<FinServ__FinancialAccount__c>(); 
      for(FinServ__FinancialAccount__c fa : records)
            {
                FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(
                FinServ__PrimaryOwner__c = fa.FinServ__PrimaryOwner__c,
                Name = 'Cash Account',
                FinServ__FinancialAccountType__c = 'Cash Account',
                RecordTypeId = '0124W000001bAJpQAM',
                FinServ__Status__c = 'Active',
                FinServ__SourceSystemId__c = 'Cash_Account_'+ fa.FinServ__PrimaryOwner__c,
                FinServ__Nickname__c = 'Cash Account');
                financialAccList.add(finAcc);
                recordsProcessed++;
                System.debug('recordsProcessed' + recordsProcessed);
      }
            insert(financialAccList);
        }
    }
    
      
    public void finish(Database.BatchableContext bc){
        
    }
}