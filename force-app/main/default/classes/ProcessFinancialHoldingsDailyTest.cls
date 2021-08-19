/**
 * Name: ProcessFinancialHoldingsDailyTest
 * Description: test class for ProcessFinancialHoldingsDaily
 * Test Class: NA
 *  * Created By: Satish Nikam - 8/9/2021
 * Modifications Log 
 * Ver   Date         Modified By    Modification Details
 * 1.0  8/10/2021   Satish Nikam    Original Implementation
**/
@isTest
public class ProcessFinancialHoldingsDailyTest {

    @TestSetup
    public static void createData(){
        TestDataFactoryFSC.createAgeBasedPortfolioData();
    }

    public static testMethod void testFinHoldingBatch(){
        ProcessFinancialHoldingsDaily finHoldingBatch = new ProcessFinancialHoldingsDaily();
        List<Investment_Transaction__c> invTranList = new List<Investment_Transaction__c>();
        for(Investment_Transaction__c invTranRecord :[Select Id, Status__c From Investment_Transaction__c Where Status__c IN ('Pending','Processing')]){
            invTranRecord.Status__c = 'Complete';
            invTranList.add(invTranRecord);
        }
        if(!invTranList.isEmpty()){
            update invTranList;
        }

        Test.Starttest();
        
        DataBase.executeBatch(finHoldingBatch); 

        Test.Stoptest();

        // Assert result: check if Sell and Buy Investment_Transaction__c got created
        //Integer expectedNumOfInvTransactions = [SELECT COUNT() FROM Investment_Transaction__c WHERE CreatedDate = today];
        //System.debug('expectedNumOfInvTransactions-->'+ expectedNumOfInvTransactions);
        // Assertion OK - Total 4 => 2 records on fin record insertion and 2 records upon batch run
        //System.assertEquals(4,expectedNumOfInvTransactions);   
    }

    public static testMethod void testFinHoldingBatch1(){
        ProcessFinancialHoldingsDaily finHoldingBatch = new ProcessFinancialHoldingsDaily();
        List<Investment_Transaction__c> invTranList = new List<Investment_Transaction__c>();
        for(Investment_Transaction__c invTranRecord :[Select Id, Status__c From Investment_Transaction__c Where Status__c IN ('Pending','Processing')]){
            invTranRecord.Status__c = 'Complete';
            invTranList.add(invTranRecord);
        }
        if(!invTranList.isEmpty()){
            update invTranList;
        }

        List<FinServ__FinancialHolding__c> finHoldingList = new List<FinServ__FinancialHolding__c>();
        for(FinServ__FinancialHolding__c finHolding :[Select Id,FinServ__Shares__c From FinServ__FinancialHolding__c]){
            finHolding.FinServ__Shares__c = 0;
            finHoldingList.add(finHolding);
        }
        if(!finHoldingList.isEmpty()){
            update finHoldingList;
        }
        Test.Starttest();
        
        DataBase.executeBatch(finHoldingBatch); 

        Test.Stoptest();

        // Assert result: check if Sell and Buy Investment_Transaction__c got created
        //Integer expectedNumOfInvTransactions = [SELECT COUNT() FROM Investment_Transaction__c WHERE CreatedDate = today];
        //System.debug('expectedNumOfInvTransactions-->'+ expectedNumOfInvTransactions);
        // Assertion OK - Total 4 => 2 records on fin record insertion and 2 records upon batch run
        //System.assertEquals(4,expectedNumOfInvTransactions);   
    }

    public static testMethod void testNoFinHoldingExists(){
        ProcessFinancialHoldingsDaily finHoldingBatch = new ProcessFinancialHoldingsDaily();
        List<Investment_Transaction__c> invTranList = new List<Investment_Transaction__c>();
        for(Investment_Transaction__c invTranRecord :[Select Id, Status__c From Investment_Transaction__c Where Status__c IN ('Pending','Processing')]){
            invTranRecord.Status__c = 'Complete';
            invTranList.add(invTranRecord);
        }
        if(!invTranList.isEmpty()){
            update invTranList;
        }

        List<FinServ__FinancialHolding__c> finHoldingList = new List<FinServ__FinancialHolding__c>();
        for(FinServ__FinancialHolding__c finHolding :[Select Id,FinServ__Shares__c From FinServ__FinancialHolding__c]){
            finHolding.FinServ__Shares__c = 0;
            finHoldingList.add(finHolding);
        }
        if(!finHoldingList.isEmpty()){
            delete finHoldingList;
        }
        Test.Starttest();
        
        DataBase.executeBatch(finHoldingBatch); 

        Test.Stoptest();

        // Assert result: check if Sell and Buy Investment_Transaction__c got created
        //Integer expectedNumOfInvTransactions = [SELECT COUNT() FROM Investment_Transaction__c WHERE CreatedDate = today];
        //System.debug('expectedNumOfInvTransactions-->'+ expectedNumOfInvTransactions);
        // Assertion OK - Total 4 => 2 records on fin record insertion and 2 records upon batch run
        //System.assertEquals(4,expectedNumOfInvTransactions);   
    }
}