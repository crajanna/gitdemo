/**
 * Name: WithdrawalAnnualSummaryBatchJobTest
 * Description: test class for WithdrawalAnnualSummaryBatchJob
 * Test Class: NA
 *  * Created By: Satish Nikam - 8/9/2021
 * Modifications Log 
 * Ver   Date         Modified By    Modification Details
 * 1.0  8/10/2021   Satish Nikam    Original Implementation
**/
@isTest
public class WithdrawalAnnualSummaryBatchJobTest {

    @TestSetup
    public static void createData(){
        TestDataFactoryFSC.createAgeBasedPortfolioData();
    }

    public static testMethod void testWithdrawalAnnualSummaryBatch(){
        WithdrawalAnnualSummaryBatchJob batchJob = new WithdrawalAnnualSummaryBatchJob();
        List<Transfer_Fund__c> tranFundList = new List<Transfer_Fund__c>();
        for(Transfer_Fund__c tranFund : [Select Id, Status__c From Transfer_Fund__c]){
            tranFund.Status__c = 'Complete';
            tranFundList.add(tranFund);
        }

        if(!tranFundList.isEmpty()){
            update tranFundList;
        }
        Test.Starttest();
        
        DataBase.executeBatch(batchJob); 

        Test.Stoptest();

        // Assert result: check if Sell and Buy Investment_Transaction__c got created
        //Integer expectedNumOfInvTransactions = [SELECT COUNT() FROM Investment_Transaction__c WHERE CreatedDate = today];
        //System.debug('expectedNumOfInvTransactions-->'+ expectedNumOfInvTransactions);
        // Assertion OK - Total 4 => 2 records on fin record insertion and 2 records upon batch run
        //System.assertEquals(4,expectedNumOfInvTransactions);   
    }

    
}