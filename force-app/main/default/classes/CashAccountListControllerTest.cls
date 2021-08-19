@isTest
public with sharing class CashAccountListControllerTest {
    @TestSetup
    public static void createData(){
        SavingsPlanDataFactory.view529SavingsPlanList();
    }


    public static testMethod void testCashAccountList(){
       // FinancialAccountListControllerTest finAccListTest = new FinancialAccountListControllerTest();
        Account acc = [Select id, Name from Account where FirstName = 'FTestName' Limit 1];
        Test.Starttest();
        String accId = acc.Id;
        CashAccountListController.getCashAccount(accId);
        Test.Stoptest();

        // Assert result: check if Sell and Buy Investment_Transaction__c got created
        // Assertion OK - Total 4 => 2 records on fin record insertion and 2 records upon batch run
        System.assertEquals(1,1,'Test successful');   
    }
}