/**
 * Name: AgeBasedPortfolioUpdateBatchTest
 * Description: test class for AgeBasedPortfolioUpdateBatch , AgeBasedPortfolioUtil, FinancialAccountRoleCustomTrigger,FinancialAccountRoleHandler
 * Test Class: NA
 *  * Created By: Satish Nikam - 7/13/2021
 * Modifications Log 
 * Ver   Date         Modified By    Modification Details
 * 1.0   7/13/2021   Satish Nikam    Original Implementation
**/
@isTest
public class AgeBasedPortfolioUpdateBatchTest {

    @TestSetup
    public static void createData(){
        TestDataFactoryFSC.createAgeBasedPortfolioData();
    }

    public static testMethod void testAgeBasedBatch(){
        AgeBasedPortfolioUpdateBatch ageBasedSCH = new AgeBasedPortfolioUpdateBatch();
        Test.Starttest();
        Integer year = Datetime.now().Year();
        Date birthDate = Date.newInstance(year-8, Datetime.now().Month(), Datetime.now().Day());
        
        // Account acc = [Select Id , PersonBirthdate From Account limit 1];
        // acc.PersonBirthdate = birthDate;
        // update acc;
        //ageBasedSCH.execute(null);
        DataBase.executeBatch(ageBasedSCH); 

        Test.Stoptest();

        // Assert result: check if Sell and Buy Investment_Transaction__c got created
        Integer expectedNumOfInvTransactions = [SELECT COUNT() FROM Investment_Transaction__c WHERE CreatedDate = today];
        System.debug('expectedNumOfInvTransactions-->'+ expectedNumOfInvTransactions);
        // Assertion OK - Total 4 => 2 records on fin record insertion and 2 records upon batch run
        System.assertEquals(4,expectedNumOfInvTransactions);   
    }

    
}