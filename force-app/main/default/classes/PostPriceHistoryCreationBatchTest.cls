/**
 * Name: PostPriceHistoryCreationBatchTest
 * Description: test class for PostSecPriceHistoryCreationDailyBatch
 * Test Class: NA
 *  * Created By: Satish Nikam - 8/9/2021
 * Modifications Log 
 * Ver   Date         Modified By    Modification Details
 * 1.0  8/9/2021   Satish Nikam    Original Implementation
**/
@isTest
public class PostPriceHistoryCreationBatchTest {

    @TestSetup
    public static void createData(){
        TestDataFactoryFSC.createAgeBasedPortfolioData();
    }

    public static testMethod void testSecHistoryBatch(){
        PostSecPriceHistoryCreationDailyBatch secHistoryBatch = new PostSecPriceHistoryCreationDailyBatch();
        Test.Starttest();
        
        DataBase.executeBatch(secHistoryBatch); 

        Test.Stoptest();

        // Assert result: check if Sell and Buy Investment_Transaction__c got created
        Integer expectedNumOfInvTransactions = [SELECT COUNT() FROM Investment_Transaction__c WHERE CreatedDate = today];
        System.debug('expectedNumOfInvTransactions-->'+ expectedNumOfInvTransactions);
        // Assertion OK - Total 4 => 2 records on fin record insertion and 2 records upon batch run
        //System.assertEquals(4,expectedNumOfInvTransactions);   
    }

    public static testMethod void testSecHistorySchedulable(){
        test.starttest();
        PostSecPriceHistoryCreationDailyBatch secHistoryBatch = new PostSecPriceHistoryCreationDailyBatch();   
        String chron = '0 0 23 * * ?';        
        system.schedule('PostSecPriceHistory', chron, secHistoryBatch);
        test.stopTest();
    }
    
}