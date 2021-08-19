global class ClaimTransferFundBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'select id,Claim_Amount__c,ApprovedAmount,Status,ClaimType,AccountId,Educational_Institutes__c from Claim where Status =\'Granted\' and ClaimType =\'School Invoice\'and AccountId != null and Educational_Institutes__c != null'
        );
    }
    public void execute(Database.BatchableContext bc, List<Claim> records)
    {
        Set<Id> Ben_Accounts = new Set<Id>();
        Set<Id> School_Accounts = new Set<Id>();
        for(Claim cl : records)
        {
            if(String.isNotBlank(cl.AccountId))
            {
                system.debug('account id: '+cl.AccountId);
                Ben_Accounts.add(cl.AccountId); 
            }
            if(String.isNotBlank(cl.Educational_Institutes__c))
                School_Accounts.add(cl.Educational_Institutes__c);
        }
        Map<ID,ID> ClaimBenCashAccountMap= new Map<ID,ID>();
        Map<ID,ID> ClaimSchoolCashAccountMap= new Map<ID,ID>();
        for(FinServ__FinancialAccount__c f_acc : [select FinServ__PrimaryOwner__c,id from FinServ__FinancialAccount__c where FinServ__PrimaryOwner__c =: Ben_Accounts])
        {
            ClaimBenCashAccountMap.put(f_acc.FinServ__PrimaryOwner__c,f_acc.id );
            
        }
        for(FinServ__FinancialAccount__c f_acc1 : [select FinServ__PrimaryOwner__c,id from FinServ__FinancialAccount__c where FinServ__PrimaryOwner__c =: School_Accounts])
        {
            ClaimSchoolCashAccountMap.put(f_acc1.FinServ__PrimaryOwner__c,f_acc1.id );
            
        }
        system.debug('ClaimBenCashAccountMap: '+ClaimBenCashAccountMap);
        system.debug('ClaimSchoolCashAccountMap: '+ClaimSchoolCashAccountMap);
        List<Transfer_Fund__c> new_TransferList = new List<Transfer_Fund__c>(); 
        List<Claim> claim_List = new List<Claim>();
        for(Claim cl : records)
        {              
            transfer_fund__c new_transferFund = new Transfer_Fund__c();
            claim temp_claim = new Claim();
            temp_claim.id = cl.id;
            temp_claim.Status = 'Settled';
            claim_List.add(temp_claim);
            new_transferFund.Claim__c = cl.Id;
            new_transferFund.IsBatch__c = true;
            new_transferFund.Transfer_Amount__c = cl.ApprovedAmount;
            if(String.isNotBlank(ClaimBenCashAccountMap.get(cl.AccountId))){
                system.debug('ClaimBenCashAccountMap.get(cl.AccountId): ' +ClaimBenCashAccountMap.get(cl.AccountId));
                new_transferFund.Financial_Account_Cash__c = ClaimBenCashAccountMap.get(cl.AccountId);
            }
            system.debug('ClaimSchoolCashAccountMap.get(cl.Educational_Institutes__c): '+ClaimSchoolCashAccountMap.get(cl.Educational_Institutes__c));
            if(String.isNotBlank(ClaimSchoolCashAccountMap.get(cl.Educational_Institutes__c)))
                new_transferFund.Financial_Account_Investment__c = ClaimSchoolCashAccountMap.get(cl.Educational_Institutes__c);
            
            new_transferFund.RecordTypeId = Schema.SObjectType.transfer_fund__c.getRecordTypeInfosByName().get('Transfer').getRecordTypeId();
            new_transferFund.Status__c = 'Complete';
            new_transferFund.Frequency__c = 'One-Time';
            new_transferFund.Start_Date__c = Date.today();
            new_TransferList.add(new_transferFund);   
        }
        Integer recordsProcessed = new_TransferList.size();
        insert(new_TransferList);
        update(claim_List) ;
    }
    public void finish(Database.BatchableContext bc)
    {
        
    }
}