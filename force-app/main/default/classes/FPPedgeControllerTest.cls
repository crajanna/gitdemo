/**
 * @description       : 
 * @author            : Satishbabu Anupoju@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-07-2021   Satishbabu Anupoju@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class FPPedgeControllerTest {

    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @TestSetup
    public static void makeData()
    {
        Account newAccount = new Account(Name = 'test test', Email__c = 'test@test.com', Phone = '8745147562', Website = 'www.google.com');
        insert newAccount;
        
		Contact newContact = new Contact(FirstName='test76',LastName='test76',Email='test76@test.com', AccountId = newAccount.Id);
        insert newContact;

        User u = TestDataFactory.createPortalUser(true, newContact, 'true');
        
       Id recTypeId = Schema.getGlobalDescribe().get('Product2').getDescribe().getRecordTypeInfosByName().get('Scholarship').getRecordTypeId();
        
        Product2  p2 = new Product2();
		p2.Name = 'FirstChoice';
        p2.spotlight__c = false;
        p2.RecordTypeId = recTypeId;
        p2.Product_Type__c='Scholarship Program';
        p2.Start_Date__c = Date.TODAY().addDays(-1);
        p2.Sort__c = 1;
		insert p2;
        
        Product2  p3 = new Product2();
		p3.Name = 'ThirdChoice';
        p3.spotlight__c = true;
        p3.RecordTypeId = recTypeId;
        p3.Product_Type__c='Scholarship Application';
        p3.Start_Date__c = Date.TODAY().addDays(-1);
        p3.End_Date__c = Date.TODAY().addDays(1);
        p3.Sort__c = 1;
		insert p3;
        
        
        Product2  p = new Product2();
		p.Name = 'SecondChoice';
        p.spotlight__c = false;
		insert p;
        
        /*Product2  p1 = new Product2();
		p1.Name = 'ThirdChoice';
        p1.spotlight__c = true;
		insert p1;*/
		
        Contract contract = new Contract();
		contract.Name = 'Final';
		contract.AccountId = newAccount.Id;
        contract.Donation_Amount__c = 10;
        contract.Pledge__c = 15;
        insert contract;
		
        
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetAgreegatedFundDetails(){
       Account act = [SELECT Id, Name FROM Account];
       Test.startTest();
       Object[] con = FPPedgeController.getAgreegatedFundDetails(act.Id, 'randomNum');   
       Test.stopTest();
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetContract(){
        Account act = [SELECT Id, Name FROM Account];
        Contract contract = [SELECT Id, Name FROM Contract where accountId =: act.Id];
        Test.startTest();
        Contract con = FPPedgeController.getContract(contract.Id);   
        Test.stopTest();
        System.assertEquals(con.Name == 'Final', true);
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetProduct(){
        Product2  product  = [SELECT Id, Name FROM Product2 where Name='SecondChoice'];
        Test.startTest();
        Product2 p = FPPedgeController.getProduct(product.Id);   
        Test.stopTest();
        System.assertEquals(p.Name == 'SecondChoice', true);
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetPledgeList(){
       Account act = [SELECT Id, Name FROM Account];
       Test.startTest();
       List<FPPedgeController.wrapperclass> l = FPPedgeController.getPledgeList(act.Id, false, '123');
       //List<FPPedgeController.wrapperclass> l = FPPedgeController.getPledgeList(act.Id, false);   
        Test.stopTest();
        }
    
    
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetZipCodeList(){
        Test.startTest();
        List<Decimal> conList = FPPedgeController.getZipCode();   
        Test.stopTest();
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetCountyNames(){
       Test.startTest();
       List<String> conList = FPPedgeController.getCountyNames();   
       Test.stopTest();
       //System.assertEquals(conList[0].Name == 'Final', true);
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetCountyZipCode(){
       Test.startTest();
       List<Decimal> conList = FPPedgeController.getCountyZipCode('Bay');   
       Test.stopTest();
    }    
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetChooseProgram(){
       Test.startTest();
       List<Product2> conList = FPPedgeController.getChoosePrograms();   
       Test.stopTest();
        System.debug('conLis: '+conList);
       System.assertEquals(conList[0].Name == 'FirstChoice', true); 
    }
    
    @isTest
    public static void testGetSPChooseProgram(){
       Test.startTest();
       List<FPPedgeController.wrapperclass> conList = FPPedgeController.getSPChoosePrograms();   
       Test.stopTest();
        System.debug('conLis: '+conList);
       System.assertEquals(conList[0].Name == 'ThirdChoice', true); 
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    public static void testGetChooseSpotLightProgram(){
       Test.startTest();
       Product2 prod = FPPedgeController.getChooseSpotLightPrograms();   
       Test.stopTest();
       System.assertEquals(prod.Name == 'ThirdChoice', true); 
    }
       
public class wrapperclass{
        @AuraEnabled
        public String id{get; set;}
        @AuraEnabled
        public String name{get; set;}
        @AuraEnabled
        public string imgUrl{get; set;}
        @AuraEnabled
        public Decimal donationAmount{get; set;}
        @AuraEnabled
        public Decimal pledgeAmount{get; set;}
        public wrapperclass(String i, String n, String m, Decimal d, Decimal p)
        {
            id = i;
            name = n;
            imgUrl = m;
            donationAmount = d;
            pledgeAmount = p;
        }
    }    
}