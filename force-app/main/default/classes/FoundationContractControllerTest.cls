@isTest
public class FoundationContractControllerTest {

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
        	tf.Source_Type__c = 'Paypal';
        	tf.Account__c = newAccount.Id;
            insert tf;
       
        
         
    }
    
    
    
            @isTest
    public static void createTransferFundsDataTest(){
        Transfer_Fund__c tf = [Select id, Name from Transfer_Fund__c where Source_Type__c = 'Paypal'];
        Test.startTest();
        FoundationContractController.createTransferFundsData('1234XTdfd', 'Pledge');
        Test.stopTest();
    }
    
        
     @isTest
    public static void getTransferFundsDataTest(){
        Transfer_Fund__c tf = [Select id, Name from Transfer_Fund__c where Source_Type__c = 'Paypal'];
        Test.startTest();
        Transfer_Fund__c id = FoundationContractController.getTransferFundsData(tf.Id);
        Test.stopTest();
    }
    
    
    
    
    
    
      @isTest
    public static void removeSessionCacheTest(){
        Account act = [Select id, Name from Account where Name = 'cfa1'];
        Test.startTest();
        FoundationContractController.removeSessionCache(act.Id);
        Test.stopTest();
    }
    
    
    @isTest
    public static void savePledgeDetailsTest(){
      
         Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        
         Product2 p2 = [Select id, Name from Product2 where Name = 'SecondChoice1' Limit 1];
        
        List<FinServ__FinancialAccount__c> facc = [Select id from FinServ__FinancialAccount__c where FinServ__FinancialAccountType__c='Cash Account' and FinServ__PrimaryOwner__c =:acc.Id Limit 1];
        
        Id idval = CreateFinancialAccount.getCashAccountIdByAccount(acc.Id);   

         List<FinServ__FinancialAccount__c> facc1 = [SELECT Id FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Scholarship' Limit 1];

        
        String objectName = 'Contract';
        String strRecordTypeName = 'Pledge';
        Id idval1 = CreateFinancialAccount.getRecordTypeIdbyName(objectName, strRecordTypeName );       
        
        
        Contract contractRecord = new Contract();
		contractRecord.AccountId = acc.Id;
        contractRecord.RecordTypeId =idval1;
        contractRecord.Product__c = p2.Id;
        contractRecord.Pledge__c= 1000;
        contractRecord.County__c= 'All';
        contractRecord.Zip_Code__c= 'All';
        
              
        Transfer_Fund__c tf = new Transfer_Fund__c();        
            tf.Financial_Account_Cash__c = idval;
            tf.Financial_Account_Investment__c = facc[0].Id;
            tf.Source_Type__c ='Check';
            tf.Transfer_Amount__c = 100;
            tf.Status__c = 'Completed';
            tf.Frequency__c = 'One-Time';
                       tf.Account__c = acc.Id;

        
       FinServ__FinancialAccount__c newBankAccount = new FinServ__FinancialAccount__c();
                   newBankAccount.Name = 'testbank';
                   newBankAccount.Bank_Account_Number__c ='1234567';
                   newBankAccount.FinServ__RoutingNumber__c  = '1234567';
                   newBankAccount.FinServ__FinancialAccountType__c = 'Checking';
	
        String mode = 'Now1';
        Test.startTest();
        Id con = FoundationContractController.savePledgeDetails(contractRecord, tf, mode, newBankAccount);   
        Test.stopTest();
        System.assertEquals(con !=null, true);
    }
    

         @isTest
    public static void savePledgeDetailsTest1(){
      
         Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        
         Product2 p2 = [Select id, Name from Product2 where Name = 'SecondChoice1' Limit 1];
        
        List<FinServ__FinancialAccount__c> facc = [Select id from FinServ__FinancialAccount__c where FinServ__FinancialAccountType__c='Cash Account' and FinServ__PrimaryOwner__c =:acc.Id Limit 1];
        
        Id idval = CreateFinancialAccount.getCashAccountIdByAccount(acc.Id);   

         List<FinServ__FinancialAccount__c> facc1 = [SELECT Id FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Scholarship' Limit 1];
        
        String objectName = 'Contract';
        String strRecordTypeName = 'Pledge';
        Id idval1 = CreateFinancialAccount.getRecordTypeIdbyName(objectName, strRecordTypeName );       
        
        
        Contract contractRecord = new Contract();
		contractRecord.AccountId = acc.Id;
        contractRecord.RecordTypeId =idval1;
        contractRecord.Product__c = p2.Id;
        contractRecord.Pledge__c= 1000;
        contractRecord.County__c= 'All';
        contractRecord.Zip_Code__c= 'All';
        
              
         Transfer_Fund__c tf = new Transfer_Fund__c();  
            tf.Financial_Account_Investment__c = facc1[0].Id;
            tf.Financial_Account_Cash__c = facc[0].Id;
            tf.Source_Type__c ='Check';
            tf.Transfer_Amount__c = 100;
            tf.Status__c = 'Complete';
            tf.Frequency__c = 'One-Time';      
	               tf.Account__c = acc.Id;

        
       FinServ__FinancialAccount__c newBankAccount = new FinServ__FinancialAccount__c();
                   newBankAccount.Name = 'testbank';
                   newBankAccount.Bank_Account_Number__c ='1234567';
                   newBankAccount.FinServ__RoutingNumber__c  = '1234567';
                   newBankAccount.FinServ__FinancialAccountType__c = 'Checking';
        
        String mode = 'Now';
        Test.startTest();
        Id con = FoundationContractController.savePledgeDetails(contractRecord, tf, mode, newBankAccount);   
        Test.stopTest();
        System.assertEquals(con !=null, true);
    }
    
    
          @isTest
    public static void savePledgeDetailsTest2(){
      
         Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        
         Product2 p2 = [Select id, Name from Product2 where Name = 'SecondChoice1' Limit 1];
        
        List<FinServ__FinancialAccount__c> facc = [Select id from FinServ__FinancialAccount__c where FinServ__FinancialAccountType__c='Cash Account' and FinServ__PrimaryOwner__c =:acc.Id Limit 1];
        
        Id idval = CreateFinancialAccount.getCashAccountIdByAccount(acc.Id);   

         List<FinServ__FinancialAccount__c> facc1 = [SELECT Id FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Scholarship' Limit 1];
        
        String objectName = 'Contract';
        String strRecordTypeName = 'Pledge';
        Id idval1 = CreateFinancialAccount.getRecordTypeIdbyName(objectName, strRecordTypeName );       
        
        
        Contract contractRecord = new Contract();
		contractRecord.AccountId = acc.Id;
        contractRecord.RecordTypeId =idval1;
        contractRecord.Product__c = p2.Id;
        contractRecord.Pledge__c= 1000;
        contractRecord.County__c= 'All';
        contractRecord.Zip_Code__c= 'All';
        
       Id rectype= CreateFinancialAccount.getRecordTypeIdbyName('Transfer_Fund__c', 'Pledge');

         Transfer_Fund__c tf = new Transfer_Fund__c();  
           tf.RecordTypeId = rectype;
            tf.Financial_Account_Investment__c = facc1[0].Id;
            tf.Financial_Account_Cash__c = facc[0].Id;
            tf.Source_Type__c ='ACH';
            tf.Transfer_Amount__c = 100;
            tf.Status__c = 'Complete';
            tf.Frequency__c = 'One-Time';   
             tf.Account__c = acc.Id;

	
        
         FinServ__FinancialAccount__c newBankAccount = new FinServ__FinancialAccount__c();
                   newBankAccount.Name = 'testbank';
                   newBankAccount.Bank_Account_Number__c ='1234567';
                   newBankAccount.FinServ__RoutingNumber__c  = '1234567';
                   newBankAccount.FinServ__FinancialAccountType__c = 'Checking';
        
        String mode = 'Now';
        Test.startTest();
        Id con = FoundationContractController.savePledgeDetails(contractRecord, tf, mode, newBankAccount);   
        Test.stopTest();
        System.assertEquals(con !=null, true);
    }
    
        
          @isTest
    public static void savePledgeDetailsTest3(){
      
         Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        
         Product2 p2 = [Select id, Name from Product2 where Name = 'SecondChoice1' Limit 1];
        
        List<FinServ__FinancialAccount__c> facc = [Select id from FinServ__FinancialAccount__c where FinServ__FinancialAccountType__c='Cash Account' and FinServ__PrimaryOwner__c =:acc.Id Limit 1];
        
        Id idval = CreateFinancialAccount.getCashAccountIdByAccount(acc.Id);   

         List<FinServ__FinancialAccount__c> facc1 = [SELECT Id FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Scholarship' Limit 1];
        
        String objectName = 'Contract';
        String strRecordTypeName = 'Pledge';
        Id idval1 = CreateFinancialAccount.getRecordTypeIdbyName(objectName, strRecordTypeName );       
        
        
        Contract contractRecord = new Contract();
		contractRecord.AccountId = acc.Id;
        contractRecord.RecordTypeId =idval1;
        contractRecord.Product__c = p2.Id;
        contractRecord.Pledge__c= 1000;
        contractRecord.County__c= 'All';
        contractRecord.Zip_Code__c= 'All';
        
              
         Transfer_Fund__c tf = new Transfer_Fund__c();  
            tf.Financial_Account_Investment__c = facc1[0].Id;
            tf.Financial_Account_Cash__c = facc[0].Id;
            tf.Source_Type__c ='Paypal';
            tf.Transfer_Amount__c = 100;
            tf.Status__c = 'Complete';
            tf.Frequency__c = 'One-Time';   
             tf.Account__c = acc.Id;

	
        
         FinServ__FinancialAccount__c newBankAccount = new FinServ__FinancialAccount__c();
                   newBankAccount.Name = 'testbank';
                   newBankAccount.Bank_Account_Number__c ='1234567';
                   newBankAccount.FinServ__RoutingNumber__c  = '1234567';
                   newBankAccount.FinServ__FinancialAccountType__c = 'Checking';
        
        String mode = 'Now';
        Test.startTest();
        Id con = FoundationContractController.savePledgeDetails(contractRecord, tf, mode, newBankAccount);   
        Test.stopTest();
        System.assertEquals(con !=null, true);
    }
    
    
    @isTest
    public static void getContractDataTest(){
        Transfer_Fund__c acc = [Select id, Name from Transfer_Fund__c Limit 1];
        Test.startTest();
        Transfer_Fund__c idval = FoundationContractController.getContractData(String.valueOf(acc.Id) );   
        Test.stopTest();
    }
    
        
    @isTest
    public static void getPledgeDataTest(){
        Contract acc = [Select id, Name from Contract Limit 1];
        Test.startTest();
        Contract idval = FoundationContractController.getPledgeData(String.valueOf(acc.Id) );   
        Test.stopTest();
    }
    
    
        @isTest
    public static void saveAddFundsDetailTest(){
        Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        List<FinServ__FinancialAccount__c> facc = [Select id from FinServ__FinancialAccount__c where FinServ__FinancialAccountType__c='Cash Account' and FinServ__PrimaryOwner__c =:acc.Id Limit 1];

        Transfer_Fund__c tf = new Transfer_Fund__c();  
            tf.Financial_Account_Investment__c = facc[0].Id;
            tf.Source_Type__c ='Check';
            tf.Transfer_Amount__c = 100;
            tf.Status__c = 'Complete';
            tf.Frequency__c = 'One-Time';
            tf.Account__c = acc.Id;
        
         FinServ__FinancialAccount__c newBankAccount = new FinServ__FinancialAccount__c();
                   newBankAccount.Name = 'testbank';
                   newBankAccount.Bank_Account_Number__c ='1234567';
                   newBankAccount.FinServ__RoutingNumber__c  = '1234567';
                   newBankAccount.FinServ__FinancialAccountType__c = 'Checking';
        Test.startTest();
        Id idval = FoundationContractController.saveAddFundsDetails(tf, newBankAccount );   
        Test.stopTest();
    }
    
        
        @isTest
    public static void saveAddFundsDetailTestAch(){
        Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        List<FinServ__FinancialAccount__c> facc = [Select id from FinServ__FinancialAccount__c where FinServ__FinancialAccountType__c='Cash Account' and FinServ__PrimaryOwner__c =:acc.Id Limit 1];

        Transfer_Fund__c tf = new Transfer_Fund__c();  
            tf.Financial_Account_Investment__c = facc[0].Id;
            tf.Source_Type__c ='ACH';
            tf.Transfer_Amount__c = 100;
            tf.Status__c = 'Complete';
            tf.Frequency__c = 'One-Time';
           tf.Account__c = acc.Id;
        
         FinServ__FinancialAccount__c newBankAccount = new FinServ__FinancialAccount__c();
                   newBankAccount.Name = 'testbank';
                   newBankAccount.Id =null;
                   newBankAccount.Bank_Account_Number__c ='1234567';
                   newBankAccount.FinServ__RoutingNumber__c  = '1234567';
                   newBankAccount.FinServ__FinancialAccountType__c = 'Checking';
        
        Test.startTest();
        Id idval = FoundationContractController.saveAddFundsDetails(tf, newBankAccount );   
        Test.stopTest();
    }
    
        @isTest
    public static void saveAddFundsDetailTestPaypal(){
        Account acc = [Select id, Name from Account where Name = 'cfa1' Limit 1];
        List<FinServ__FinancialAccount__c> facc = [Select id from FinServ__FinancialAccount__c where FinServ__FinancialAccountType__c='Cash Account' and FinServ__PrimaryOwner__c =:acc.Id Limit 1];

        Transfer_Fund__c tf = new Transfer_Fund__c();  
            tf.Financial_Account_Investment__c = facc[0].Id;
            tf.Source_Type__c ='Paypal';
            tf.Transfer_Amount__c = 100;
            tf.Status__c = 'Complete';
            tf.Frequency__c = 'One-Time';
           tf.Account__c = acc.Id;
        
         FinServ__FinancialAccount__c newBankAccount = new FinServ__FinancialAccount__c();
                   newBankAccount.Name = 'testbank';
                   newBankAccount.Id =null;
                   newBankAccount.Bank_Account_Number__c ='1234567';
                   newBankAccount.FinServ__RoutingNumber__c  = '1234567';
                   newBankAccount.FinServ__FinancialAccountType__c = 'Checking';
        
        Test.startTest();
        Id idval = FoundationContractController.saveAddFundsDetails(tf, newBankAccount );   
        Test.stopTest();
    }
    
    
}