public without sharing class PerformanceTestingController {
        
    @AuraEnabled
    public static Map<String, Object> getSecurityPerformance(String secName, String fromDate, String toDate) {
        Map<String, Object> resultMap = new Map<String, Object>();
        //resultMap.put('Security Name', secName);
        Decimal yearDays = 365;
        Date fromDateObj = (!String.isEmpty(fromDate)) ?  Date.valueOf(fromDate) : null;
        Date toDateObj = (!String.isEmpty(toDate)) ? Date.valueOf(toDate) : null;
        
        if(fromDateObj!=null && toDateObj!=null) {
            List<FinServ__Securities__c> records = [Select Id,FinServ__SecuritiesName__c, FinServ__Price__c,Monthly_Change__c, Quarterly_Change__c, 
                                                Yearly_Change__c, Three_Year_Change__c, Five_Year_Change__c, Inception_Date__c, 
                                                Inception_Price__c from FinServ__Securities__c where Name = :secName];
             
            FinServ__Securities__c secEntity = records.get(0);
            //resultMap.put('Sec ID', secEntity.Id);
            resultMap.put('Security Name', secEntity.FinServ__SecuritiesName__c);
            resultMap.put('Date Range From = ', fromDateObj);
            resultMap.put('Date To From = ', toDateObj);
           
            
            List<Security_Price_History__c> lists = [SELECT Id, Price__c, Price_Date__c, Symbol__c from Security_Price_History__c where Symbol__c = :secEntity.Id and  
                                                 Price_Date__c IN ( :toDateObj, :fromDateObj) order by Price_Date__c desc];
            
            //resultMap.put('lists size', lists.size());
            
            if(lists.size()>1){
                Security_Price_History__c fromDateSecObj = lists.get(0);
                Security_Price_History__c toDateSecObj = lists.get(1);
                
                resultMap.put('Security Price_Date = '+ fromDateSecObj.Price_Date__c,   ' Price__c =' + fromDateSecObj.Price__c);
                resultMap.put('Security Price_Date = '+ toDateSecObj.Price_Date__c,   ' Price__c =' + toDateSecObj.Price__c);
                
                Double numberDaysDue = toDateObj.daysBetween(fromDateObj);
                Double powInceptionRounded =  (numberDaysDue>365) ? yearDays.divide(numberDaysDue, 6) : 1;
                resultMap.put('# Days = ', numberDaysDue);
                //resultMap.put('powInceptionRounded', powInceptionRounded);
                
                Decimal percentObj = ( fromDateSecObj.Price__c / toDateSecObj.Price__c);
                Decimal percentFinal = (Math.pow(percentObj.doubleValue(), powInceptionRounded)-1) * 100;
                //resultMap.put('percentObj', percentObj);
                resultMap.put('Formula',  ('( (' + fromDateSecObj.Price__c + '/' + toDateSecObj.Price__c + ') ^' + powInceptionRounded + ' ) -1' ));
                resultMap.put('Final Percentage = ', percentFinal);
                
                
           }
            
        }
        
        //Decimal percentInception =  (latestSP.Price__c / sec.Inception_Price__c);
        
            
        return resultMap;
    }
    
    
    public static void execute4(){
        Date month = System.today().addDays(-30);
        Date quarter = System.today().addDays(-90);
        Date yearly = System.today().addDays(-364);
        Date year3 = System.today().addDays(-1094);
        Date year5 = System.today().addDays(-1824);
        //Map<String, Object> monthlyMap = getAccountPerformance('a0FP0000007mmF6MAI', Datetime.now().format('yyyy-MM-dd') ,formatDate(month));
        //System.debug('Month - ' + monthlyMap.get('Percentage-'));
        
         //Map<String, Object> quarterMap = getAccountPerformance('a0FP0000007mmF6MAI', Datetime.now().format('yyyy-MM-dd') ,formatDate(quarter));
        //System.debug('Quarter - ' + quarterMap.get('Percentage-'));
        
       //  Map<String, Object> yearMap = getAccountPerformance('a0FP0000007mmF6MAI', Datetime.now().format('yyyy-MM-dd') ,formatDate(yearly));
        //System.debug('Year - ' +yearMap.get('Percentage-'));
        
         //Map<String, Object> year3Map = getAccountPerformance('a0FP0000007mmF6MAI', Datetime.now().format('yyyy-MM-dd') ,formatDate(year3));
        //System.debug('Year 3 - ' +year3Map.get('Percentage-'));
        
         //Map<String, Object> year5Map = getAccountPerformance('a0FP0000007mmF6MAI', Datetime.now().format('yyyy-MM-dd') ,formatDate(year5));
        //System.debug('Year 5 - ' +year5Map.get('Percentage-')); */
        
        
        List<FinServ__FinancialAccount__c> accounts = [ SELECT ID, FinServ__Balance__c, FinServ__PerformanceMTD__c, FinServ__PerformanceQTD__c, FinServ__Performance1Yr__c, FinServ__Performance3Yr__c, Performance5Yr_c__c  From FinServ__FinancialAccount__c WHERE RecordTypeId = '0124W000001bAJsQAM' and Id = 'a0FP0000007mmF6MAI'];
        FinServ__FinancialAccount__c account = accounts.get(0);
            
        account.FinServ__PerformanceMTD__c =  0.706281001567266;
        account.FinServ__PerformanceQTD__c = 4.7121097526165288932911599890929200;
        account.FinServ__Performance1Yr__c = 27.739669842419201337035820310295600;
        account.FinServ__Performance3Yr__c = 33.653857868503283559332527823571800;
        account.Performance5Yr_c__c = 46.001878069235394442044671577243700;
        
        update  account;  
    }
    
    public static String formatDate(Date d) {
        return d.year() + '-' + d.month() + '-' + d.day();
    }
    
    
     @AuraEnabled
    public static Map<String, Object> getAccountPerformance(String accountId, String fromDate, String toDate) {
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('Account ID ', accountId);
        System.debug('Account ID = ' + accountId);
        Decimal yearDays = 365;
        resultMap.put('From Date ', fromDate);
        resultMap.put('To Date ', toDate);
       
        
        Date beginDate =  (!String.isEmpty(fromDate)) ?  Date.valueOf(fromDate) : null;
        Date endDate  = (!String.isEmpty(toDate)) ?  Date.valueOf(toDate) : null;
        
        
        Double numberDaysDue = endDate.daysBetween(beginDate);
        Double powInceptionRounded =  (numberDaysDue>yearDays) ? yearDays.divide(numberDaysDue, 6) : 1;
        
        
        //resultMap.put('Balance Date ', beginDate.format());
        
        List<FinServ__FinancialAccount__c> accounts = [ SELECT ID, FinServ__Balance__c, FinServ__PerformanceMTD__c, FinServ__PerformanceQTD__c, FinServ__Performance1Yr__c, FinServ__Performance3Yr__c, Performance5Yr_c__c  From FinServ__FinancialAccount__c WHERE RecordTypeId = '0124W000001bAJsQAM' and Id = :accountId];
        FinServ__FinancialAccount__c account = accounts.get(0);
        
        Map<ID, FinServ__Securities__c> secMap = new Map<ID, FinServ__Securities__c>([Select Id, Name, FinServ__SecuritiesName__c, FinServ__Price__c,Monthly_Change__c, Quarterly_Change__c, Yearly_Change__c, Three_Year_Change__c, Five_Year_Change__c, 
                                                                                      (select Name, Price__c, Price_Date__c from Security_Price_Histories__r where Price_Date__c IN ( :beginDate, :endDate ) order by Price_Date__c DESC limit 10) 
                                                                                      from FinServ__Securities__c where Id = 'a0WP0000004St4sMAC']);
        
        //resultMap.put('secMap ', secMap);
        
        Decimal currentBalance = getCurrentBalance(beginDate, account.Id, secMap, resultMap );
        resultMap.put('Begin Balance ', currentBalance);
        //resultMap.put('****************************', '****************************');
        Decimal percentageFinal = getPerformance(beginDate, endDate, account.Id, secMap, currentBalance, powInceptionRounded, resultMap);
        
        resultMap.put('Percentage-', percentageFinal);
        
        
        System.debug(resultMap);
        return resultMap;
    }
    
    
    private static Decimal getCurrentBalance(Date fromDate, String accountId, Map<ID, FinServ__Securities__c> secMap, Map<String, Object> resultMap){
        Decimal yearDays = 365;
        Decimal rangeTotal = 0.0;
        Decimal convertPercent = 0.0;
        Decimal rangeTrxTotal = 0.0;
        Decimal rangeWATotal = 0.0;
        String rangeDateStr = fromDate.format() ;
        
        for (AggregateResult  secList : [SELECT Securities__r.Id secId,  count(Name) total from Investment_Transaction__c where Financial_Account__c = :accountId and Status__c = 'Complete' and Transaction_Date__c <= :fromDate group by Securities__r.Id ]) {
            String secId  = (String)secList.get('secId');
            FinServ__Securities__c secEntity =  secMap.get(secId);
            List<Security_Price_History__c> histories = secEntity.Security_Price_Histories__r;
            Decimal totalBuys = 0.0;
            Decimal totalSells = 0.0;
            Decimal totalUnits = 0.0;
            
            for (AggregateResult  trxList : [SELECT Action_Type__c,  sum(shares_quantity__c) total from Investment_Transaction__c where Financial_Account__c = :accountId and Securities__r.Id = :secId and Transaction_Date__c <= :fromDate and Status__c = 'Complete' group by Action_Type__c ]) {
                String actionType  = (String)trxList.get('Action_Type__c');
                Decimal units  = (Decimal)trxList.get('total');
                if(actionType == 'Buy') totalBuys = units;
                if(actionType == 'Sell') totalSells = units;
                totalUnits = totalBuys - totalSells;
            }
            System.debug('rangeDate = ' + rangeDateStr);
            System.debug('totalUnits = ' + totalUnits);
            resultMap.put(secEntity.FinServ__SecuritiesName__c + ' Begin Total Units ', totalUnits);
            
            for(Security_Price_History__c sh : histories){
                if(sh.Price_Date__c == fromDate){
                    resultMap.put(secEntity.Name + ' **Begin Price ', sh.Price__c + ' ** Total : ' + (totalUnits * sh.Price__c));
                    rangeTotal += (totalUnits * sh.Price__c);
                }
            }
        }
        return rangeTotal;
    }
    
    
    private static Decimal getPerformance(Date fromDate, Date toDate, String accountId, Map<ID, FinServ__Securities__c> secMap, Decimal currentBalance, Double powP, Map<String, Object> resultMap){
        Decimal yearDays = 365;
        Decimal rangeTotal = 0.0;
        Decimal convertPercent = 0.0;
        Decimal rangeTrxTotal = 0.0;
        Decimal rangeWATotal = 0.0;
        String rangeDateStr = toDate.format() ;
        Long totalDays = fromDate.daysBetween(toDate);
        System.debug('Total Days = ' + totalDays);
        resultMap.put('Total Days = ' ,  totalDays);
        
        for (AggregateResult  secList : [SELECT Securities__r.Id secId,  count(Name) total from Investment_Transaction__c where Financial_Account__c = :accountId and Status__c = 'Complete' and Transaction_Date__c < :toDate group by Securities__r.Id ]) {
            String secId  = (String)secList.get('secId');
            FinServ__Securities__c secEntity =  secMap.get(secId);
            List<Security_Price_History__c> histories = secEntity.Security_Price_Histories__r;
            Decimal totalBuys = 0.0;
            Decimal totalSells = 0.0;
            Decimal totalUnits = 0.0;
            
            for (AggregateResult  trxList : [SELECT Action_Type__c,  sum(shares_quantity__c) total from Investment_Transaction__c where Financial_Account__c = :accountId and Securities__r.Id = :secId and Transaction_Date__c <= :toDate and Status__c = 'Complete' group by Action_Type__c ]) {
                String actionType  = (String)trxList.get('Action_Type__c');
                Decimal units  = (Decimal)trxList.get('total');
                if(actionType == 'Buy') totalBuys = units;
                if(actionType == 'Sell') totalSells = units;
                totalUnits = totalBuys - totalSells;
            }
            System.debug('rangeDate = ' + rangeDateStr);
            System.debug('totalUnits = ' + totalUnits);
            resultMap.put(secEntity.FinServ__SecuritiesName__c + ' Total Units ', totalUnits);
            
            for(Security_Price_History__c sh : histories){
                if(sh.Price_Date__c == toDate){
                    resultMap.put(secEntity.Name + ' ** Price ', sh.Price__c + ' ** Total : ' + (totalUnits * sh.Price__c));
                    rangeTotal += (totalUnits * sh.Price__c);
                }
            }
            
            resultMap.put('***********************TRX', '***********************');
            for (Investment_Transaction__c  trxItem : [SELECT Action_Type__c, Cost_Basis__c, Transaction_Date__c from Investment_Transaction__c where Financial_Account__c = :accountId and Securities__r.Id = :secId and Transaction_Date__c >= :fromDate and Transaction_Date__c <=:toDate  and Status__c = 'Complete'  ]) {
            	
                Date trxDate = date.newinstance(trxItem.Transaction_Date__c.year(), trxItem.Transaction_Date__c.month(), trxItem.Transaction_Date__c.day());
                
                Long numberDays = Math.abs(fromDate.daysBetween(trxDate));
                Decimal wavg = (numberDays<=totalDays) ? (Decimal.valueOf(totalDays) - Decimal.valueOf(numberDays)) / Decimal.valueOf(totalDays) : 0;
                wavg = wavg.setScale(8);
                Decimal flowValue = trxItem.Cost_Basis__c * wavg;
                rangeTrxTotal += trxItem.Cost_Basis__c;
                rangeWATotal  += flowValue;
                
                resultMap.put('Transaction - ' + trxDate.format() ,  trxItem.Cost_Basis__c + '-------------------');
                resultMap.put('Date Diff #' +trxDate.format(), numberDays);
                resultMap.put('Weighted Avg '+trxDate.format(), wavg + '~~~' + flowValue);
                resultMap.put('Amount =  '  +trxDate.format() , trxItem.Cost_Basis__c);
               
            }
            
            resultMap.put('***********************TRX END', '***********************');
        }
        
        
        resultMap.put('Transactions Totals (for the selected date range) - ' + rangeDateStr, rangeTrxTotal);
        resultMap.put('Transactions Weighted Avg Total ', rangeWATotal);         
        
        System.debug('currentBalance = ' + currentBalance);
        System.debug('rangeTotal = ' + rangeTotal);
                
        resultMap.put('***********************Percentage Calculations', '***********************');
       	resultMap.put('Balance On  = ' + rangeDateStr , rangeTotal);
        if(rangeTotal>0) {
            if(rangeWATotal!=0) {
                convertPercent = ((( rangeTotal-currentBalance) - rangeTrxTotal ) / (rangeTotal + rangeWATotal)) * 100;
                resultMap.put('Formula',  ('(( (' + rangeTotal  + '-' + currentBalance + ') -' + rangeTrxTotal + ' ) / (' + rangeTotal+'+' +rangeWATotal +'))' ));
                System.debug('convertPercent = ' + convertPercent);
            } else {
                Decimal percentTot = ( rangeTotal/currentBalance);
                convertPercent = (Math.pow(percentTot.doubleValue(), powP)-1) * 100;
                resultMap.put('Formula',  ('( (' + rangeTotal  + '/' + currentBalance  + ') ^' + powP + ' ) -1' ));
            }
        }
        
        return convertPercent;
    }
    
    
    @AuraEnabled
    public static Map<String, Object> getAccountPerformanceMonthly(String accountId, String accAsOfDt, String rangeType) {
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('Account ID ', accountId);
        Date accAsOfDtObj = (!String.isEmpty(accAsOfDt)) ?  Date.parse(accAsOfDt) : null;
        Integer minusMonths = -1;
        if(rangeType == 'Quarterly') minusMonths = -3;
        if(rangeType == 'Yearly') minusMonths = -12;
        
        Date beginDate = accAsOfDtObj.addMonths(minusMonths);
        
        Decimal yearDays = 365;
        Decimal selDtBalance;
        Decimal beginBalance;
        Decimal convertPercent = 0.0;
        List<Account_Balance__c> lists =  [SELECT Balance_Date__c, Balance__c FROM Account_Balance__c WHERE Financial_Account__c = :accountId and Type__c = 'Monthly' ORDER BY Balance_Date__c DESC];
        for (Account_Balance__c  ab : lists) {
            if(accAsOfDtObj == ab.Balance_Date__c){
                selDtBalance = ab.Balance__c;
            }
            if(beginDate == ab.Balance_Date__c){
                beginBalance = ab.Balance__c;
            }
        }
        
        resultMap.put('**************Monthly*****************'  , '*********');
        resultMap.put('Begin Date ', beginDate + ' ; Balance =' + beginBalance);
        resultMap.put('End Date ', accAsOfDtObj + ' ; Balance =' + selDtBalance);
        
             
        Decimal rangeTrxTotal = 0.0;
        Decimal rangeWATotal = 0.0;
        Double powP = 1;
        Long totalDays = beginDate.daysBetween(accAsOfDtObj);
        resultMap.put('totalDays ', totalDays);
        List<Investment_Transaction__c>  trxList =  [SELECT Action_Type__c, Cost_Basis__c, Transaction_Date__c from Investment_Transaction__c where Financial_Account__c = :accountId and Transaction_Date__c > :beginDate and Transaction_Date__c <=:accAsOfDtObj  and Status__c = 'Complete' order by  Transaction_Date__c];
        for (Investment_Transaction__c  trxItem : trxList ) {
            Date trxDate = date.newinstance(trxItem.Transaction_Date__c.year(), trxItem.Transaction_Date__c.month(), trxItem.Transaction_Date__c.day());
            if(trxDate>=beginDate){
                Long numberDays = Math.abs(beginDate.daysBetween(trxDate))-1;
                numberDays = numberDays == 0? 1: numberDays;
                //resultMap.put('Days between trax ' + trxDate, numberDays);
                Decimal wavg = (numberDays<=totalDays) ? (Decimal.valueOf(totalDays) - Decimal.valueOf(numberDays)) / Decimal.valueOf(totalDays) : 0;
                wavg = wavg.setScale(8);
                Decimal flowValue = trxItem.Cost_Basis__c * wavg;
                flowValue.setScale(4);
                resultMap.put('Transaction **** Date : ' + trxItem.Transaction_Date__c.format('MM-dd-YYYY'),   '  ***Amount = ' + trxItem.Cost_Basis__c + '  **Weighted Avg Total =' + flowValue + '  ~~~~WGA(' + wavg +')  *** Day=' + numberDays);
                rangeTrxTotal += trxItem.Cost_Basis__c;
                rangeWATotal  += flowValue;   
            } 
       }
       resultMap.put('Total = ' + rangeTrxTotal , 'Weighted Avg total = ' + rangeWATotal);
       powP =  (totalDays>yearDays) ? yearDays.divide(totalDays, 6) : 1;
       if(rangeWATotal!=0) {
           convertPercent = (((selDtBalance - beginBalance) - rangeTrxTotal ) / (beginBalance + rangeWATotal)) * 100;
           convertPercent.setScale(4);
           resultMap.put('Percentage',convertPercent);
           resultMap.put('Formula',  ('(( (' + selDtBalance + '-' + beginBalance + ') -' + rangeTrxTotal + ' ) / (' + beginBalance+'+' +rangeWATotal +'))' ));
           System.debug('Percentage = ' + convertPercent);
       } else {
           Decimal percentTot = (selDtBalance / beginBalance);
           convertPercent = (Math.pow(percentTot.doubleValue(), powP)-1) * 100;
           resultMap.put('Formula',  ('( (' + selDtBalance + '/' + beginBalance + ') ^' + powP + ' ) -1' ));
       }
        
        
       return resultMap;
        
    }
    
    
    @AuraEnabled
    public static List<String> getMonthlyDatesForAccount(String accountId) {
       List<String> combosList = new List<String>();
       List<Account_Balance__c> lists =  [SELECT Balance_Date__c FROM Account_Balance__c WHERE Financial_Account__c = :accountId and Type__c = 'Monthly' ORDER BY Balance_Date__c DESC];
       for (Account_Balance__c  ab : lists) {
           combosList.add((ab.Balance_Date__c).format());
       }
       return combosList;
    }   
}