/**
 * Name: NAVFileProcessingTest
 * Description: test class for NAVFileProcessing
 * Test Class: NA
 *  * Created By: Satish Nikam - 7/14/2021
 * Modifications Log 
 * Ver   Date         Modified By    Modification Details
 * 1.0   7/14/2021   Satish Nikam    Original Implementation
**/
@isTest
public class NAVFileProcessingTest {

    @TestSetup
    public static void createData(){
        TestDataFactoryFSC.createAgeBasedPortfolioData();
    }

    public static testMethod void testAgeBasedBatch(){
        
        Test.Starttest();
        Fund_Allocation__c  fundAllocationItem = [SELECT Securities__c, Securities__r.FinServ__Price__c, allocation_percentage__c, Active_Indicator__c,Financial_Account__c ,Financial_Account__r.FinServ__Balance__c 
                                        FROM Fund_Allocation__c limit 1];
                                        fundAllocationItem.allocation_percentage__c = 10;
                                        update fundAllocationItem;
        FinServ__Securities__c securityRecord =  [SELECT Id, Name, FinServ__SecuritiesName__c, Fund_Category__c,FinServ__Price__c 
                                        From FinServ__Securities__c limit 1];
        Decimal balance = fundAllocationItem.Financial_Account__r.FinServ__Balance__c;                                
        Investment_Transaction__c  InvTransactionObj = new Investment_Transaction__c();
        InvTransactionObj.Action_Type__c = 'Buy';
        InvTransactionObj.Financial_Account__c = fundAllocationItem.Financial_Account__c;
        Decimal cost = 1000; //need to check with Raj/Maanas
        Decimal price = securityRecord.FinServ__Price__c;
        InvTransactionObj.Cost_Basis__c = cost;
        InvTransactionObj.Buy_Amount__c = cost;                                                   
        InvTransactionObj.shares_quantity__c = cost/price;
        InvTransactionObj.Purchase_Price__c = price;
        InvTransactionObj.Securities__c = securityRecord.Id;
        InvTransactionObj.Status__c = 'Processing';
        insert InvTransactionObj;


        List<Investment_Transaction__c> invTransactions = [Select Id From Investment_Transaction__c limit 1];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(Database.getQueryLocator( 'Select Id From Investment_Transaction__c limit 1' ));
        stdSetController.setSelected(invTransactions);
        NavFileProcessing instance = new NavFileProcessing(stdSetController);
        instance.save();
        Test.Stoptest();
        
        // Assert result: check if Investment_Transaction__c status got updated to complete
        Integer expectedNumOfInvTransactions = [SELECT COUNT() FROM Investment_Transaction__c WHERE CreatedDate = today and Status__c = 'Complete'];
        System.debug('expectedNumOfInvTransactions-->'+ expectedNumOfInvTransactions);
        // Assertion OK - 4 record
        System.assertEquals(5,expectedNumOfInvTransactions);   
    }

    
}