/**
 * Name: AgeBasedPortfolioUpdateBatch
 * Description: Age based portfolia handling on day of birthday and on change of Beneficiary
 * Test Class: AgeBasedPortfolioUpdateBatchTest
 * Created By: Satish Nikam - 7/09/2021
 * Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/09/2021   Satish Nikam    Original Implementation for Age Based Portfolio Util
 * 7/19/2021   Satish Nikam    10923 - T2 : Age based Portfolio handling based on matriculation date
**/
global class AgeBasedPortfolioUpdateBatch implements Database.Batchable<sObject> {
    Integer DATE_TWENTY_EIGHT = 28;
    Integer DATE_TWENTY_NINE = 29;
    Integer MONTH_FEB = 2;
    Integer NUMBER_OF_YEARS = 20;
   	public Database.QueryLocator start(Database.BatchableContext bc) {
        
        //Handle non-leap year scenario when birthday falls on 29th of Feb
        Date todaysDate = system.today();
        Integer year = todaysDate.Year();
        system.debug('Is current Year leap year:'+Date.isLeapYear(year));
        List<Date> leapDateList = new List<Date>();
        List<Date> allDateList  = new List<Date>();
        DateTime createdSince = System.now().addHours(-24);//pulling all the records created in last 24 hours

        //Get all active Beneficiary if birthday is today
        String queryStr = 'SELECT Id,FinServ__RelatedAccount__r.PersonContact.Birthdate ,FinServ__RelatedAccount__r.Matriculation_Date__c,FinServ__FinancialAccount__c,FinServ__FinancialAccount__r.FinServ__Balance__c, FinServ__Active__c FROM FinServ__FinancialAccountRole__c '+
                        + 'WHERE FinServ__Role__c = \'Beneficiary\' AND '
                        + 'FinServ__Active__c = true AND ';
        //Handle birthday only Accounts                
        for(Integer i = 0;i<= NUMBER_OF_YEARS ;i++){
            if(Date.isLeapYear(year-i)){
                leapDateList.add(Date.newInstance(year-i, MONTH_FEB, DATE_TWENTY_NINE));
            }
            allDateList.add(Date.newInstance(year-i, Datetime.now().Month(), Datetime.now().Day()));
        }
        if(!Date.isLeapYear(year) && todaysDate.Month() == MONTH_FEB && todaysDate.Day() == DATE_TWENTY_EIGHT){
            //dayOfYearList.add(dayOfYear+1); //29th feb birthday for non-leap year
            //if its not leap year and if its 28th of Feb - then need to handle 29th feb birthday scenario on 28th of feb batch run
            allDateList.addAll(leapDateList);
        }
        //else 
        //in case 1.leap year 29th feb scenario 
        //2.Non-leap and non-28th Feb Scenario 
        //will get handled with regular past birthday list
    
        queryStr += '( FinServ__RelatedAccount__r.PersonContact.Birthdate IN :allDateList OR CreatedDate >= :createdSince)'; 
        System.debug('queryStr-->'+queryStr);
        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext bc, List<FinServ__FinancialAccountRole__c> finAccountRoleList){
        //Step 2- invoke util class to invoke common imlementation related to age based portfolio processing
        String retValue = AgeBasedPortfolioUtil.ProcessAgeBasedPortfolio(finAccountRoleList);
        System.debug('Check batch process result: ' + retValue);
    }

    public void finish(Database.BatchableContext bc){
        //Chaining ob Batch Jobs - #3 - ProcessTransferFundDailyBatch
        //Temp commented 
        /*Batch_Configuration__mdt pspHistoryRecord = Batch_Configuration__mdt.getInstance('ProcessTransferFundDailyBatch');
        Integer transactionSize = pspHistoryRecord != null ? Integer.ValueOf(pspHistoryRecord.Transaction_Size__c) : 10;
        Database.executeBatch(new ProcessTransferFundDailyBatch(),transactionSize);*/
    }


}