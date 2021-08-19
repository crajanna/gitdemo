public class AccountPerformanceIndicatorTest {
    
    public void execute(){
      	Double pow3Yr = 0.333333;
        Double pow5Yr = 0.2; 
        Date currentDate  = Date.newInstance(2021, 5, 10);
        Date thirtyDaysDate = currentDate.addDays(-30);
        Date ninetyDaysDate = currentDate.addDays(-90);
        Date yearDaysDate = currentDate.addDays(-365);
        Date year3DaysDate = currentDate.addDays(-1095);
        Date year5DaysDate = currentDate.addDays(-1825);
        
        List<FinServ__FinancialAccount__c> accounts = [ SELECT ID, FinServ__Balance__c, FinServ__PerformanceMTD__c, FinServ__PerformanceQTD__c, FinServ__Performance1Yr__c, FinServ__Performance3Yr__c  From FinServ__FinancialAccount__c WHERE RecordTypeId = '0124W000001bAJsQAM' and Id ='a0FP0000007mmF6MAI'];
        FinServ__FinancialAccount__c account = accounts.get(0);
        
        Map<ID, FinServ__Securities__c> secMap = new Map<ID, FinServ__Securities__c>([Select Id,FinServ__SecuritiesName__c, FinServ__Price__c,Monthly_Change__c, Quarterly_Change__c, Yearly_Change__c, Three_Year_Change__c, Five_Year_Change__c, 
                                                (select Name, Price__c, Price_Date__c from Security_Price_Histories__r where Price_Date__c IN ( :currentDate, :thirtyDaysDate, :ninetyDaysDate, :yearDaysDate, :year3DaysDate, :year5DaysDate) order by Price_Date__c DESC limit 10) 
                                                from FinServ__Securities__c where Id = 'a0WP0000004St4sMAC']);
        
        Decimal percentage30Days = getPerformance(currentDate,thirtyDaysDate, account.Id, secMap, account.FinServ__Balance__c, 1);
        Decimal percentage90Days = getPerformance(currentDate,ninetyDaysDate, account.Id, secMap, account.FinServ__Balance__c, 1);
        Decimal percentageYear = getPerformance(currentDate, yearDaysDate, account.Id, secMap, account.FinServ__Balance__c, 1);
        Decimal percentage3Year = getPerformance(currentDate,year3DaysDate, account.Id, secMap, account.FinServ__Balance__c, pow3Yr);
        Decimal percentage5Year = getPerformance(currentDate, year5DaysDate, account.Id, secMap, account.FinServ__Balance__c, pow5Yr);
        
        account.FinServ__PerformanceMTD__c=percentage30Days;
        account.FinServ__PerformanceQTD__c=percentage90Days;
        account.FinServ__Performance1Yr__c=percentageYear;
        account.FinServ__Performance3Yr__c=percentage3Year;
        account.Performance5Yr_c__c=percentage5Year;
        
        update account;
            
       /* System.debug('percentage30Days = ' + percentage30Days);
        System.debug('percentage90Days = ' + percentage90Days);
        System.debug('percentageYear = ' + percentageYear);
        System.debug('percentage3Year = ' + percentage3Year);
        System.debug('percentage5Year = ' + percentage5Year);*/
        
        
        /*for(FinServ__Securities__c secEntity : secMap.values()){
            
            List<Security_Price_History__c> histories = secEntity.Security_Price_Histories__r;
            Security_Price_History__c latestSP = histories.get(0);
            Security_Price_History__c day30SP = histories.get(1);
            Security_Price_History__c day90SP = histories.get(2);
            Security_Price_History__c year1SP = histories.get(3);
            Security_Price_History__c year3SP = histories.get(4);
            Security_Price_History__c year5SP = histories.get(5);
            
            System.debug( '30 Days - '+ day30SP.Price__c);
            System.debug( '90 Days - '+ day90SP.Price__c);
            System.debug( '1 Year - '+ year1SP.Price__c);
            System.debug( '3 Year - '+ year3SP.Price__c);
            System.debug( '5 Year - '+ year5SP.Price__c);
            
        }*/
        
   }
    
    private Decimal getPerformance(Date currentDate, Date rangeDate, String accountId, Map<ID, FinServ__Securities__c> secMap, Decimal currentBalance, Double powP){
        Decimal rangeTrxTotal = 0.0;
        Decimal rangeWATotal = 0.0;
        Decimal rangeTotal = 0.0;
        Decimal convertPercent = 0.0;
        Long totalDays = rangeDate.daysBetween(currentDate);
        System.debug('Total Days = ' + totalDays);
        
        for (AggregateResult  secList : [SELECT Securities__r.Id secId,  count(Name) total from Investment_Transaction__c where Financial_Account__c = :accountId and Status__c = 'Complete' and Transaction_Date__c <= :rangeDate group by Securities__r.Id ]) {
            String secId  = (String)secList.get('secId');
            FinServ__Securities__c secEntity =  secMap.get(secId);
            List<Security_Price_History__c> histories = secEntity.Security_Price_Histories__r;
            Decimal totalBuys = 0.0;
            Decimal totalSells = 0.0;
            Decimal totalUnits = 0.0;
            
            for (AggregateResult  trxList : [SELECT Action_Type__c,  sum(shares_quantity__c) total from Investment_Transaction__c where Financial_Account__c = :accountId and Securities__r.Id = :secId and Transaction_Date__c <= :rangeDate and Status__c = 'Complete' group by Action_Type__c ]) {
             	String actionType  = (String)trxList.get('Action_Type__c');
                Decimal units  = (Decimal)trxList.get('total');
            	if(actionType == 'Buy') totalBuys = units;
                if(actionType == 'Sell') totalSells = units;
                totalUnits = totalBuys - totalSells;
        	}
            System.debug('rangeDate = ' + rangeDate);
            System.debug('totalUnits = ' + totalUnits);
            for(Security_Price_History__c sh : histories){
                if(sh.Price_Date__c == rangeDate){
                    rangeTotal += (totalUnits * sh.Price__c);
                }
            }
            
            for (Investment_Transaction__c  trxItem : [SELECT Action_Type__c, Cost_Basis__c, Transaction_Date__c from Investment_Transaction__c where Financial_Account__c = :accountId and Securities__r.Id = :secId and Transaction_Date__c >= :rangeDate and Transaction_Date__c <=:currentDate  and Status__c = 'Complete'  ]) {
                Date trxDate = date.newinstance(trxItem.Transaction_Date__c.year(), trxItem.Transaction_Date__c.month(), trxItem.Transaction_Date__c.day());
                Long numberDays = trxDate.daysBetween(rangeDate);
                Decimal wavg = (numberDays<=totalDays) ? (Decimal.valueOf(totalDays) - Decimal.valueOf(numberDays)) / Decimal.valueOf(totalDays) : 0;
                wavg = wavg.setScale(8);
                Decimal flowValue = trxItem.Cost_Basis__c * wavg;
                rangeTrxTotal += trxItem.Cost_Basis__c;
				rangeWATotal  += flowValue;
                System.debug('numberDays = ' + numberDays);
                System.debug('totalDays = ' + totalDays);
                System.debug('Weighted Avg Amt= ' + wavg);
                System.debug('TrxTotal Total Amt= ' + rangeTrxTotal);
                System.debug('rangeWATotal Total Amt= ' + rangeWATotal);
        	}
        }
        
        System.debug('currentBalance = ' + currentBalance);
        System.debug('rangeTotal = ' + rangeTotal);
        
        if(rangeTotal>0) {
            if(rangeWATotal!=0) {
                convertPercent = (((currentBalance - rangeTotal) - rangeTrxTotal ) / (rangeTotal + rangeWATotal)) * 100;
                System.debug('convertPercent = ' + convertPercent);
            } else {
                Decimal percentTot = (currentBalance / rangeTotal);
                convertPercent = (Math.pow(percentTot.doubleValue(), powP)-1) * 100;
                System.debug('convertPercent = ' + convertPercent);
            }
        }
       
        return convertPercent;
    }
}