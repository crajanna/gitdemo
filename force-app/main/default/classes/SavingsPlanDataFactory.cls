@isTest
public with sharing class SavingsPlanDataFactory {
    
    public static void view529SavingsPlanList(){

        Id accountId = createPersonAccount();
        Id cashAccountId = createCashAccount(accountId);
        Id fin529AccountId = create529Account(accountId);
    }

    private static Id createPersonAccount(){
        Id recordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Integer year = Datetime.now().Year();
        Date birthDate = Date.newInstance(year-9, Datetime.now().Month(), Datetime.now().Day());
        Account newAccount = new Account(FirstName='FTestName',
                                         LastName='LName',
                                         Email__c = 'test@test.com', 
                                         Phone = '999999999', 
                                         SSN2__pc = '9999',
                                         PersonBirthdate = birthDate,
                                         RecordTypeId = recordTypeId);
        insert newAccount;
        return  newAccount.Id;
    }

    private static Id createCashAccount(Id id){
        Id recordTypeId = FinServ__FinancialAccount__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('General Account').getRecordTypeId();
        FinServ__FinancialAccount__c cashAccount = 
            new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='Cash Account',
            FinServ__PrimaryOwner__c =id, 
            FinServ__FinancialAccountNumber__c = '123456', 
            FinServ__CashBalance__c = 1000,
            Name='Cash Account',
            RecordTypeId = recordTypeId);
            insert cashAccount;
            return  cashAccount.Id;
    }

    private static Id create529Account(Id id){
        Id recordTypeId = FinServ__FinancialAccount__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        FinServ__FinancialAccount__c faccount = 
            new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='Regular',
            FinServ__PrimaryOwner__c =id, 
            FinServ__FinancialAccountNumber__c = '99999', 
            Name='Florida 529 Savings Plan',
            RecordTypeId = recordTypeId);
            insert faccount;
            return  faccount.Id;
    }
}