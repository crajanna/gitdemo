@isTest
public class PaypalControllerTest {
    
    @TestSetup
    public static void makeData()
    {
        Account newAccount = new Account(Name = 'cfa1', Email__c = 'test@test.com1', Phone = '87451475621', Website = 'www.google.com1');
        insert newAccount;
        
        Product2  p = new Product2();
		p.Name = 'SecondChoice1';
		insert p;        
        
        //Account newAccount1 = new Account(Name = 'cfa2', Email__c = 'test@test.com2', Phone = '87451475621', Website = 'www.google.com1');
        //insert newAccount1;

		List<FinServ__FinancialAccount__c> lstFinAcc = new List<FinServ__FinancialAccount__c>();        
       	FinServ__FinancialAccount__c faccount = 
            new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='Cash Account',FinServ__PrimaryOwner__c =newAccount.Id, FinServ__FinancialAccountNumber__c = '123456', Name='Cash Account');
        //insert faccount;
        
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
        
       
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
        sessionPart.put('oppid', '12345999');     
    }

    @isTest
    public static void PaypalControllerTest(){
        Test.startTest();
        PaypalController p = new PaypalController(); 
        Test.stopTest();
    }
    
}