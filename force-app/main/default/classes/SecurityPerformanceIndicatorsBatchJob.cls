/* Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/15/2021   Satish Nikam    Task-10865 - T2 - Refactor Financial Holding Performace Indicator batch job
**/
global class SecurityPerformanceIndicatorsBatchJob implements Database.Batchable<sObject>, Database.Stateful {
    //global Integer recordsProcessed = 0;
   	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'Select Id,FinServ__SecuritiesName__c, FinServ__Price__c,Monthly_Change__c, Quarterly_Change__c, Yearly_Change__c, Three_Year_Change__c, Five_Year_Change__c, Inception_Date__c, Inception_Price__c from FinServ__Securities__c'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<FinServ__Securities__c> records){
        
        Decimal yearDays = 365;
        Date currentDate  = Date.today();//Date.newInstance(2021, 5, 2);
        Date thirtyDaysDate = currentDate.addDays(-30);
        Date ninetyDaysDate = currentDate.addDays(-90);
        Date yearDaysDate = currentDate.addDays(-365);
        Date year3DaysDate = currentDate.addDays(-1095);
        Date year5DaysDate = currentDate.addDays(-1825);
        Double pow3Yr = 0.333333;
        Double pow5Yr = 0.2;
        
        List<FinServ__Securities__c> newList = new List<FinServ__Securities__c>();
        Map<Id,List<Security_Price_History__c>> secToHistoryMap = new Map<Id,List<Security_Price_History__c>>();
        //pulling all relevant history for securities
        for(Security_Price_History__c historyRecord : [SELECT Id, Price__c, Price_Date__c, Symbol__c 
                                                       FROM Security_Price_History__c 
                                                       WHERE Symbol__c IN :records AND  
                                                             Price_Date__c IN ( :currentDate, :thirtyDaysDate, :ninetyDaysDate, :yearDaysDate, :year3DaysDate, :year5DaysDate) 
                                                       ORDER BY Price_Date__c desc]){
            List<Security_Price_History__c> secHistoryList = secToHistoryMap.get(historyRecord.Symbol__c);
            secHistoryList = secHistoryList == null ? new List<Security_Price_History__c>():secHistoryList; 
            secHistoryList.add(historyRecord);
            secToHistoryMap.put(historyRecord.Symbol__c,secHistoryList);                                    
        }
        for(FinServ__Securities__c sec : records){
            List<Security_Price_History__c> lists = secToHistoryMap.get(sec.Id);
            if(lists != null){
          
                for(Security_Price_History__c item : lists){
                    System.debug( 'Price_Date - '+ item.Price_Date__c + '-Price__c -' + item.Price__c);
                }
                
                Security_Price_History__c latestSP = new Security_Price_History__c();
                Security_Price_History__c day30SP = new Security_Price_History__c();
                Security_Price_History__c day90SP = new Security_Price_History__c();
                Security_Price_History__c year1SP = new Security_Price_History__c();
                Security_Price_History__c year3SP = new Security_Price_History__c();
                Security_Price_History__c year5SP = new Security_Price_History__c();
            
            
                if(lists.size() > 0){
                    latestSP = lists.get(0);
                }
                if(lists.size() > 1){
                    day30SP = lists.get(1);
                    Decimal percent30 = (latestSP.Price__c / day30SP.Price__c) -1;
                    sec.Monthly_Change__c = percent30 * 100;
                    System.debug( '30 Days - '+ sec.Monthly_Change__c);
                }
                if(lists.size() > 2){
                    day90SP = lists.get(2);
                    Decimal percent90 = (latestSP.Price__c / day90SP.Price__c) -1;
                    sec.Quarterly_Change__c = percent90 * 100;
                    System.debug( '90 Days - '+ sec.Quarterly_Change__c);
                }
                if(lists.size() > 3){
                    year1SP = lists.get(3);
                    Decimal percent365 = (latestSP.Price__c / year1SP.Price__c) -1;
                    sec.Yearly_Change__c = percent365 * 100;
                    System.debug( '1 Year - '+ sec.Yearly_Change__c);
                }
                if(lists.size() > 4){
                    year3SP = lists.get(4);
                    Decimal percent3yr = (latestSP.Price__c / year3SP.Price__c);
                    Decimal percent3yrFinal = (Math.pow(percent3yr.doubleValue(), pow3Yr)-1) * 100;
                    sec.Three_Year_Change__c = percent3yrFinal;
                    System.debug( '3 Year - '+ sec.Three_Year_Change__c);
                }
                if(lists.size() > 5){
                    year5SP = lists.get(5);
                    Decimal percent5yr = (latestSP.Price__c / year5SP.Price__c);
                    System.debug(percent5yr);
                    Decimal percent5yrFinal = (Math.pow(percent5yr.doubleValue(), pow5Yr)-1) * 100;
                    sec.Five_Year_Change__c = percent5yrFinal;
                    System.debug( '5 Year - '+ sec.Five_Year_Change__c);
                }
                
                Decimal numberDaysDue = sec.Inception_Date__c.daysBetween(currentDate);
                Decimal powInceptionRounded =  (numberDaysDue>365) ? yearDays.divide(numberDaysDue, 6) : 1;
                Decimal percentInception =  (latestSP.Price__c / sec.Inception_Price__c);
                
                System.debug( 'latestSP.Price__c - '+ latestSP.Price__c);
                System.debug( 'sec.Inception_Price__c - '+ sec.Inception_Price__c);
                System.debug( 'percentInception - '+ percentInception);
                System.debug( 'numberDaysDue - '+ numberDaysDue);
                System.debug( 'powInception - '+ powInceptionRounded);
                
                
                Decimal percentInceptionFinal = (Math.pow(percentInception.doubleValue(), powInceptionRounded.doubleValue())-1) * 100;
                
                sec.Inception_Change__c = percentInceptionFinal;
                
                System.debug( 'Inception - '+ percentInceptionFinal);
                
                newList.add(sec);
            }
        }
        try{
            if(!newList.isEmpty() && Schema.sObjectType.FinServ__Securities__c.fields.Monthly_Change__c.isUpdateable()) {
                update newList;
            }

        }Catch(Exception ex){
            System.debug('SecurityPerformanceIndicatorsBatchJob >> Error while updating security records :'+ ex.getMessage());
        }
        
        
    }
    
    private Decimal getPercentageChange(Decimal newNum, Decimal originalNum){
       return  (newNum - originalNum)/((newNum + originalNum)/2) ;
    }

    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        //EmailUtils.sendMessage(job, recordsProcessed);
    }
}