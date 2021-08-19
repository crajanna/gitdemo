@isTest
public with sharing class PrepaidBulkPolicyController_Test {

     @isTest
    public static void Test() {


         //create new account
  		Account a  = new Account();  
        a.name = 'test business account12222';
        a.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        insert a;
       
        //create product2

        product2 p1 = new product2();
        p1.Contract_Year__c = '2021';
        p1.Description = '60 COLLEGE 60 UNIVERSITY HOURS';
        p1.Credit_Hours__c = 120;
        p1.Dormitory__c = 0;
        p1.IsActive = true;
        p1.Local__c = 60;
        p1.Local_Lower__c = 60;
        p1.Local_Upper__c = 0;
        p1.Name = '2 plus 2 florida college';
        p1.Number_of_Years__c = 4;
        p1.PEY__c = '2038';
        p1.Product_Type__c = 'Prepaid Plan';
        p1.TDF__c = 60;
        p1.Tuition__c = 60;
        p1.Tuition_Lower__c = 60;
        p1.Tuition_Upper__c = 60;

        insert p1;



         product2 p2 = new product2();
        p2.Contract_Year__c = '2021';
        p2.Description = 'We sponsor the Governor’s Hispanic Heritage History Month essay contest, open to students in grades 4-10 across the state';
        p2.Credit_Hours__c = 120;
        p2.Dormitory__c = 0;
        p2.IsActive = true;
        p2.Local__c = 60;
        p2.Local_Lower__c = 60;
        p2.Local_Upper__c = 0;
        p2.Name = '2 plus 2 florida college';
        p2.Number_of_Years__c = 4;
        p2.PEY__c = '2038';
        p2.Product_Type__c = 'Scholarship Program';
        p2.ProductCode = 'SP4';
        p2.RecordTypeId = Schema.SObjectType.product2.getRecordTypeInfosByDeveloperName().get('Scholarship').getRecordTypeId();
        p2.spotlight__c = false;
        p2.TDF__c = 60;
        p2.Tuition__c = 60;
        p2.Tuition_Lower__c = 60;
        p2.Tuition_Upper__c = 60;

        insert p2;

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
        c1.Name = 'Dorm';
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

          ProductCoverage PC4 = new ProductCoverage();
        PC4.CoverageTypeId = c4.id;
        PC4.ProductId = p1.id;
        insert PC4;

        Test.startTest();
        string numberofPolicy = '20';
        List<Product2> p_prepaid =  PrepaidBulkPolicyController.prepaidPlans('2021');
        List<Product2> p_scholar =  PrepaidBulkPolicyController.ScholarshipPlans();
        List<Prepaid_Pricebook_Entry__c> price_book =  PrepaidBulkPolicyController.PriceBookEntryDetails('2038','2021',String.valueOf(p1.id));
        list<InsurancePolicy> l_insurancePolicy = PrepaidBulkPolicyController.createPolicy(numberofPolicy, a.id, '2038', '2021', 'Calculate Based on Amount Paid', 12, String.valueOf(p1.id), 'Foundation Donor', p2.name);
        list<InsurancePolicy> l_insurancePolicy1 = PrepaidBulkPolicyController.insertPolicy(numberofPolicy, a.id, '2038', '2021', 'Calculate Based on Amount Paid', 12, String.valueOf(p1.id), String.valueOf(price_book[0].id), 'Foundation Donor', p2.name);
        integer created_policysize = l_insurancePolicy.size();
        Test.stopTest();
        // after the testing stops, assert records were updated properly
     
        System.assertEquals(numberofPolicy,String.valueOf(created_policysize));



    }
}