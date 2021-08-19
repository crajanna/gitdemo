@isTest
public with sharing class PrepaidPolicyControllerTest {
    
    public static testMethod void testPrepaid(){


         //create new account
  		Account a  = new Account();  
        a.name = 'test account';
        a.RecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']; 
        insert a;


          //create new account
  		Account a1  = new Account();  
      a1.name = 'test beneficiary';
      a1.RecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account']; 
      insert a1;
       
        //create product2

        product2 p1 = new product2();
        p1.Contract_Year__c = '2021';
        p1.Description = '30 UNIVERSITY HOURS';
        p1.Credit_Hours__c = 30;
        p1.Dormitory__c = 0;
        p1.IsActive = true;
        p1.Local__c = 30;
        p1.Name = '1-Year Florida University';
        p1.Number_of_Years__c = 4;
        p1.PEY__c = '2038';
        p1.Product_Type__c = 'Prepaid Plan';
        p1.TDF__c = 30;
        p1.Tuition__c = 30;
        p1.Family = 'University';
  

        insert p1;

        //create price book entry

        Pricebook2 pr1 = new Pricebook2();

        pr1.Contract_Year__c = '2021';
        pr1.IsActive = true;
        pr1.Name = '2021 Fee Schedule';

        insert pr1;
       
        //create prepaid price book entry

        Prepaid_Pricebook_Entry__c ppe1 = new Prepaid_Pricebook_Entry__c();

        ppe1.Dorm_Fee__c = 0;
        ppe1.Local_Fee__c = 71.3013333333333;
        ppe1.Local_Lower_Fee__c = 60;
        ppe1.Local_Upper_Fee__c = 0;
        ppe1.Lump_Sum_Price__c = 22881.11;
        ppe1.TDF_Fee__c = 71.3013333333333;
        ppe1.Tuition_Lower_Fee__c = 60;
        ppe1.Tuition_Upper_Fee__c = 0;
        ppe1.Tution__c = 95.0683333333333;
        ppe1.Name = '2and2 Florida College (2+2 Bundled)-2021-PEY2038';
        ppe1.PEY__c = '2038';
        ppe1.Price_Book__c = pr1.id;
        ppe1.Product__c = p1.id;

        insert ppe1;

        //create coverage Type

        CoverageType c1 = new CoverageType();
        c1.Name = 'Dormitory';
        insert c1;

         CoverageType c2 = new CoverageType();
        c2.Name = 'Local';
        insert c2;

         CoverageType c3 = new CoverageType();
        c3.Name = 'Tuition';
        insert c3;

         CoverageType c4 = new CoverageType();
        c4.Name = 'TDF';
        insert c4;

        // create ProductCoverage
        ProductCoverage PC1 = new ProductCoverage();
        PC1.CoverageTypeId = c1.id;
        PC1.ProductId = p1.id;
        insert PC1;

        ProductCoverage PC2 = new ProductCoverage();
        PC2.CoverageTypeId = c2.id;
        PC2.ProductId = p1.id;
        insert PC2;

        ProductCoverage PC3 = new ProductCoverage();
        PC3.CoverageTypeId = c3.id;
        PC3.ProductId = p1.id;
        insert PC3;

        Test.startTest();
        string numberofPolicy = '2';
        List<Product2> p_prepaid =  PrepaidPolicyController.prepaidPlans('2021');

        Map<String, Object> mapData = new Map<String, Object>();
        mapData.put('numberofPolicy', '1');
        mapData.put('accId', a.Id);
        mapData.put('pey', '2038');
        mapData.put('contractYear', '2021');
        mapData.put('productId', p1.id);
        mapData.put('family', 'University');
        mapData.put('policyPurchaseType', 'Individual');
        mapData.put('PricebkSubType', 'TypeA');
        mapData.put('beneficiaryId', a1.id);

        String jsonString = JSON.Serialize(mapData);

        System.debug('jsonString >>>>'+jsonString);

        list<InsurancePolicy> insurancePolicies =   PrepaidPolicyController.createPolicy(jsonString,null);

        integer created_policysize = insurancePolicies.size();
        Test.stopTest();
        // after the testing stops, assert records were updated properly
     
        System.assertEquals(numberofPolicy,String.valueOf(created_policysize));
}
}