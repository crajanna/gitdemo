/**
 * Name: QuarterlyAccountStmtBatchJobTest
 * Description: test class for QuarterlyAccountStmtBatchJob
 * Test Class: NA
 *  * Created By: Satish Nikam - 8/10/2021
 * Modifications Log 
 * Ver   Date         Modified By    Modification Details
 * 1.0  8/10/2021   Satish Nikam    Original Implementation
**/
@isTest
public class QuarterlyAccountStmtBatchJobTest {

    @TestSetup
    public static void createData(){
        TestDataFactoryFSC.createAgeBasedPortfolioData();
    }

    public static testMethod void testSecurityPerformanceIndicatorsBatch(){
        QuarterlyAccountStmtBatchJob batchJob = new QuarterlyAccountStmtBatchJob();
        Test.Starttest();
        List<Investment_Transaction__c> invTranList = new List<Investment_Transaction__c>();
        for(Investment_Transaction__c invTranRecord :[Select Id, Status__c From Investment_Transaction__c Where Status__c IN ('Pending','Processing')]){
            invTranRecord.Status__c = 'Complete';
            invTranRecord.Transaction_Date__c = date.today().addDays(-60);
            invTranList.add(invTranRecord);
        }
        if(!invTranList.isEmpty()){
            update invTranList;
        }
        DataBase.executeBatch(batchJob); 

        Test.Stoptest();

        // Assert result: check if Sell and Buy Investment_Transaction__c got created
        //Integer expectedNumOfInvTransactions = [SELECT COUNT() FROM Investment_Transaction__c WHERE CreatedDate = today];
        //System.debug('expectedNumOfInvTransactions-->'+ expectedNumOfInvTransactions);
        // Assertion OK - Total 4 => 2 records on fin record insertion and 2 records upon batch run
        //System.assertEquals(4,expectedNumOfInvTransactions);   
    }

    
}