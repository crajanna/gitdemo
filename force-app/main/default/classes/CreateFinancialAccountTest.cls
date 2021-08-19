@isTest
public class CreateFinancialAccountTest {

      @TestSetup
    public static void makeData()
    {
      Account newAccount = new Account(Name = 'cfa1', Email__c = 'test@test.com1', Phone = '87451475621', Website = 'www.google.com1');
        insert newAccount;
        
       // Id rid= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Id rid = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
        
         Account newAccount1= new Account(Name = 'cfa12', Email__c = 'test@test.com2', Phone = '87451475621', Website = 'www.google.com1', RecordTypeId = rid);
        insert newAccount1;
        
        Account newAccount2 = new Account(Name = 'cfa3', Email__c = 'test@test.com1', Phone = '87451475621', Website = 'www.google.com1');
        insert newAccount2;
        
        Product2  p = new Product2();
		p.Name = 'SecondChoice1';
		insert p;        
        
        //Account newAccount1 = new Account(Name = 'cfa2', Email__c = 'test@test.com2', Phone = '87451475621', Website = 'www.google.com1');
        //insert newAccount1;

		List<FinServ__FinancialAccount__c> lstFinAcc = new List<FinServ__FinancialAccount__c>();        
       	FinServ__FinancialAccount__c faccount = 
            new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='Cash Account',FinServ__PrimaryOwner__c =newAccount.Id, FinServ__FinancialAccountNumber__c = '123456', Name='Cash Account');
        //insert faccount;
        
        FinServ__FinancialAccount__c sroaccount =
		new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='SRO',FinServ__PrimaryOwner__c =newAccount.Id, FinServ__FinancialAccountNumber__c = '123456', Name='SRO Account');
        
        
        FinServ__FinancialAccount__c faccountrecordType = 
            new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c ='Scholarship', 
                                             FinServ__PrimaryOwner__c= newAccount.Id, FinServ__FinancialAccountNumber__c = '123456',
                                             Name='Cash Account');
        
        lstFinAcc.add(faccount);
        lstFinAcc.add(faccountrecordType);
        insert lstFinAcc;
        
        Contract contract = new Contract();
		contract.Name = 'Final';
		contract.AccountId = newAccount.Id;
		insert contract;
        
      
        
        Transfer_Fund__c tf = new Transfer_Fund__c();        
            tf.Financial_Account_Investment__c = faccountrecordType.Id;           
            tf.Transfer_Amount__c = 100;
            insert tf;
       
        
                 
    }
    
       
        
            @isTest
    public static void getAccountIdTest(){
         Test.startTest();
        Id id = CreateFinancialAccount.getAccountId(UserInfo.getUserId());   
        Test.stopTest();
    }
        
    @isTest
    public static void saveCashAccount1Test(){
         Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        FinServ__FinancialAccount__c financialCashAccount = [Select id, Name from FinServ__FinancialAccount__c where FinServ__FinancialAccountType__c = 'Cash Account' Limit 1];
        
        Test.startTest();
        Id id = CreateFinancialAccount.saveCashAccount1(financialCashAccount, acc.Id);   
        Test.stopTest();
    }
    
    @isTest
    public static void saveCashAccount2Test(){
         Account acc = [Select id, Name from Account where Name = 'cfa3' Limit 1];
        
        FinServ__FinancialAccount__c cashAccount = new FinServ__FinancialAccount__c(
            FinServ__FinancialAccountType__c='Cash Account',
            FinServ__PrimaryOwner__c =acc.Id, 
            FinServ__FinancialAccountNumber__c = '123456', 
            Name='Cash Account');
        
        Test.startTest();
        Id id = CreateFinancialAccount.saveCashAccount1(cashAccount, acc.Id);   
        Test.stopTest();
    }
    
   
    
    
    
    @isTest
    public static void saveSROAccount2Test(){
         Account acc = [Select id, Name from Account where Name = 'cfa3' Limit 1];
        
        FinServ__FinancialAccount__c cashAccount = new FinServ__FinancialAccount__c(
            FinServ__FinancialAccountType__c='SRO',
            FinServ__PrimaryOwner__c =acc.Id, 
            FinServ__FinancialAccountNumber__c = '123456', 
            Name='SRO Account');
        
        Test.startTest();
        Id id = CreateFinancialAccount.saveSROAccount1(cashAccount, acc.Id);   
        Test.stopTest();
    }
    
    
    
    
    
      @isTest
    public static void getCashBalanceByAccountIdTest(){
         Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        
        Test.startTest();
        Decimal con = CreateFinancialAccount.getCashBalanceByAccountId(acc.Id);   
        Test.stopTest();
    }
    
    @isTest
    public static void getCashAccountNumberByAccountIdTest(){
         Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        Test.startTest();
        String con = CreateFinancialAccount.getCashAccountNumberByAccountId(acc.Id); 
        List<FinServ__FinancialAccount__c > lstFinAcc = CreateFinancialAccount.getFinancialAccountsById(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getCashAccountIdByAccountTest(){
        Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        List<FinServ__FinancialAccount__c> facc = [Select id from FinServ__FinancialAccount__c where FinServ__FinancialAccountType__c='Cash Account' and FinServ__PrimaryOwner__c =:acc.Id Limit 1];
        Test.startTest();
        Id idval = CreateFinancialAccount.getCashAccountIdByAccount(acc.Id);   
        Test.stopTest();
    }
    
        @isTest
    public static void getScholarshipFinAccountTest(){
        Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        List<FinServ__FinancialAccount__c> facc = [SELECT Id FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Scholarship' Limit 1];
        Test.startTest();
        Id idval = CreateFinancialAccount.getScholarshipFinAccount();   
        Test.stopTest();
    }
    
            @isTest
    public static void getRecordTypeIdbyName(){
        String objectName = 'Account';
        String rname = 'IndustriesBusiness';
        Test.startTest();
        Id idval = CreateFinancialAccount.getRecordTypeIdbyName(objectName, rname );   
        Test.stopTest();
    }
    
    
  
    
    
}