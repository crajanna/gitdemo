public class QuarterlyAccountStmtBatchTest {
    
    public static void execute4(){
        Date month = System.today().addDays(-30);
		system.debug(month);
        Date quarter = System.today().addDays(-90);
		system.debug(quarter);
        Date yearly = System.today().addDays(-364);
		system.debug(yearly);
        Date year3 = System.today().addDays(-1094);
		system.debug(year3);
        Date year5 = System.today().addDays(-1824);
		system.debug(year5);
    }
    
    public static void execute3(){
        Decimal yearDays = 365;
        Date currentDate  = Date.newInstance(2021, 5, 2);
        Date thirtyDaysDate = currentDate.addDays(-30);
        Date ninetyDaysDate = currentDate.addDays(-90);
        Date yearDaysDate = currentDate.addDays(-365);
        Date year3DaysDate = currentDate.addDays(-1095);
        Date year5DaysDate = currentDate.addDays(-1825);
        Double pow3Yr = 0.333333;
        Double pow5Yr = 0.2;
		
        List<FinServ__Securities__c> records = [Select Id,FinServ__SecuritiesName__c, FinServ__Price__c,Monthly_Change__c, Quarterly_Change__c, Yearly_Change__c, Three_Year_Change__c, Five_Year_Change__c, Inception_Date__c, Inception_Price__c from FinServ__Securities__c where Id = 'a0WP0000004St4sMAC'];
        List<FinServ__Securities__c> newList = new List<FinServ__Securities__c>();
        for(FinServ__Securities__c sec : records){
            
            List<Security_Price_History__c> lists = [SELECT Id, Price__c, Price_Date__c, Symbol__c from Security_Price_History__c where Symbol__c = :sec.Id and  
                                                 Price_Date__c IN ( :currentDate, :thirtyDaysDate, :ninetyDaysDate, :yearDaysDate, :year3DaysDate, :year5DaysDate) order by Price_Date__c desc];
            for(Security_Price_History__c item : lists){
                System.debug( 'Price_Date - '+ item.Price_Date__c + '-Price__c -' + item.Price__c);
            }
            Security_Price_History__c latestSP = lists.get(0);
            Security_Price_History__c day30SP = lists.get(1);
            Security_Price_History__c day90SP = lists.get(2);
            Security_Price_History__c year1SP = lists.get(3);
            Security_Price_History__c year3SP = lists.get(4);
            Security_Price_History__c year5SP = lists.get(5);
                        
            Decimal percent30 = (latestSP.Price__c / day30SP.Price__c) -1;
            sec.Monthly_Change__c = percent30 * 100;
            Decimal percent90 = (latestSP.Price__c / day90SP.Price__c) -1;
            sec.Quarterly_Change__c = percent90 * 100;
            Decimal percent365 = (latestSP.Price__c / year1SP.Price__c) -1;
            sec.Yearly_Change__c = percent365 * 100;
            
            Decimal percent3yr = (latestSP.Price__c / year3SP.Price__c);
            Decimal percent3yrFinal = (Math.pow(percent3yr.doubleValue(), pow3Yr)-1) * 100;
            
            sec.Three_Year_Change__c = percent3yrFinal;
            
            Decimal percent5yr = (latestSP.Price__c / year5SP.Price__c);
            System.debug(percent5yr);
            Decimal percent5yrFinal = (Math.pow(percent5yr.doubleValue(), pow5Yr)-1) * 100;
            
            sec.Five_Year_Change__c = percent5yrFinal;
            
            System.debug( '30 Days - '+ sec.Monthly_Change__c);
            System.debug( '90 Days - '+ sec.Quarterly_Change__c);
            System.debug( '1 Year - '+ sec.Yearly_Change__c);
            System.debug( '3 Year - '+ sec.Three_Year_Change__c);
            System.debug( '5 Year - '+ sec.Five_Year_Change__c);
            
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
        update newList;
    }
    
    public void execute2(){
        Date month = System.today().addDays(-30);
		system.debug(month);
        Date quarter = System.today().addDays(-90);
		system.debug(quarter);
        
        List<FinServ__FinancialAccount__c> accounts = [ SELECT ID, FinServ__Balance__c, FinServ__PerformanceMTD__c, FinServ__PerformanceQTD__c, FinServ__Performance1Yr__c, FinServ__Performance3Yr__c  From FinServ__FinancialAccount__c WHERE RecordTypeId = '0124W000001bAJsQAM' and Id ='a0FP0000007mmF6MAI'];
        FinServ__FinancialAccount__c account = accounts.get(0);
            
        Map<ID, FinServ__Securities__c> secMap = new Map<ID, FinServ__Securities__c>([Select Id,FinServ__SecuritiesName__c, FinServ__Price__c,Monthly_Change__c, Quarterly_Change__c, Yearly_Change__c, Three_Year_Change__c, Five_Year_Change__c, 
                                                (select Name, Price__c, Price_Date__c from Security_Price_Histories__r order by Price_Date__c DESC limit 1825) 
                                                from FinServ__Securities__c]);
        Decimal thirtyDayTotal = 0.0;
        for (AggregateResult  secList : [SELECT Securities__r.Id secId,  count(Name) total from Investment_Transaction__c where Financial_Account__c = 'a0FP0000007mmF6MAI' and Status__c = 'Complete' and Transaction_Date__c < :month group by Securities__r.Id ]) {
            String secId  = (String)secList.get('secId');
            FinServ__Securities__c secEntity =  secMap.get(secId);
            List<Security_Price_History__c> histories = secEntity.Security_Price_Histories__r;
            Decimal totalBuys = 0.0;
            Decimal totalSells = 0.0;
            Decimal totalUnits = 0.0;
            
            for (AggregateResult  trxList : [SELECT Action_Type__c,  sum(shares_quantity__c) total from Investment_Transaction__c where Financial_Account__c = 'a0FP0000007mmF6MAI' and Securities__r.Id = :secId and Status__c = 'Complete' group by Action_Type__c ]) {
             	String actionType  = (String)trxList.get('Action_Type__c');
                Decimal units  = (Decimal)trxList.get('total');
            	if(actionType == 'Buy') totalBuys = units;
                if(actionType == 'Sell') totalSells = units;
                totalUnits = totalBuys - totalSells;
        	}
            
            if(histories.size()>=29){
               Security_Price_History__c h = histories.get(29);
               thirtyDayTotal += (totalUnits * h.Price__c);
               system.debug(secId + ' =' + totalUnits + ' =' + h.Price__c);
           }
        }
        system.debug( 'thirtyDayTotal =' + thirtyDayTotal);
        system.debug( 'Balance =' + (account.FinServ__Balance__c - thirtyDayTotal) );
        Decimal monthlyChange = getPercentageChange(account.FinServ__Balance__c, thirtyDayTotal ) * 100;
        system.debug( 'monthlyChange =' + monthlyChange);
        
        
        Decimal quarterDayTotal = 0.0;
        for (AggregateResult  secList : [SELECT Securities__r.Id secId,  count(Name) total from Investment_Transaction__c where Financial_Account__c = 'a0FP0000007mmF6MAI' and Status__c = 'Complete' and Transaction_Date__c < :quarter group by Securities__r.Id ]) {
            String secId  = (String)secList.get('secId');
            FinServ__Securities__c secEntity =  secMap.get(secId);
            List<Security_Price_History__c> histories = secEntity.Security_Price_Histories__r;
            Decimal totalBuys = 0.0;
            Decimal totalSells = 0.0;
            Decimal totalUnits = 0.0;
            
            for (AggregateResult  trxList : [SELECT Action_Type__c,  sum(shares_quantity__c) total from Investment_Transaction__c where Financial_Account__c = 'a0FP0000007mmF6MAI' and Securities__r.Id = :secId and Status__c = 'Complete' group by Action_Type__c ]) {
             	String actionType  = (String)trxList.get('Action_Type__c');
                Decimal units  = (Decimal)trxList.get('total');
            	if(actionType == 'Buy') totalBuys = units;
                if(actionType == 'Sell') totalSells = units;
                totalUnits = totalBuys - totalSells;
        	}
            
            if(histories.size()>=89){
               Security_Price_History__c h = histories.get(89);
               quarterDayTotal += (totalUnits * h.Price__c);
               system.debug(secId + ' =' + totalUnits + ' =' + h.Price__c);
           }
        }
        system.debug( 'quarterDayTotal =' + quarterDayTotal);
        system.debug( 'Balance =' + (account.FinServ__Balance__c - quarterDayTotal) );
        Decimal quarterlyChange = getPercentageChange(account.FinServ__Balance__c, quarterDayTotal ) * 100;
        system.debug( 'quarterlyChange =' + quarterlyChange);
        
        account.FinServ__PerformanceQTD__c = quarterlyChange; 
        
        update account;
    }
    
    
    public void execute1(){
        List<FinServ__Securities__c> records = [Select Id,FinServ__SecuritiesName__c, FinServ__Price__c,Monthly_Change__c, Quarterly_Change__c, Yearly_Change__c, Three_Year_Change__c, Five_Year_Change__c, 
                                                (select Name, Price__c, Price_Date__c from Security_Price_Histories__r order by Price_Date__c DESC limit 1825) 
                                                from FinServ__Securities__c where Id = 'a0WP0000004St4sMAC'];
        List<FinServ__Securities__c> newList = new List<FinServ__Securities__c>();
        for(FinServ__Securities__c item : records){
           List<Security_Price_History__c> histories = item.Security_Price_Histories__r;
           Decimal monthlyChange = 0;
           Decimal quarterlyChange = 0;
           Decimal yearlyChange = 0;
           Decimal currentPrice = item.FinServ__Price__c;
            
           if(histories.size()>=29){
               Security_Price_History__c h = histories.get(29);
               system.debug('Price_Date__c ' + h.Price_Date__c + ' - Price__c - ' + h.Price__c );
               system.debug(' currentPrice - ' + currentPrice +' monthlyChange - ' +  (currentPrice - h.Price__c ));
               item.Monthly_Change__c = getPercentageChange(currentPrice, h.Price__c ) * 100;
           }
           if(histories.size()>=89){
               Security_Price_History__c h = histories.get(89);
               system.debug('Price_Date__c ' + h.Price_Date__c + ' - Price__c - ' + h.Price__c );
               system.debug(' currentPrice - ' + currentPrice +' monthlyChange - ' +  (currentPrice - h.Price__c ));
               item.Quarterly_Change__c = getPercentageChange(currentPrice, h.Price__c ) * 100;
           }
           if(histories.size()>=364){
               Security_Price_History__c h = histories.get(364);
               system.debug('Price_Date__c ' + h.Price_Date__c + ' - Price__c - ' + h.Price__c );
               system.debug(' currentPrice - ' + currentPrice +' monthlyChange - ' +  (currentPrice - h.Price__c ));
               item.Yearly_Change__c = getPercentageChange(currentPrice, h.Price__c ) * 100;
           }
           if(histories.size()>=1094){
               
               Security_Price_History__c fY1_1 = histories.get(364);
               Security_Price_History__c fY1_2 = histories.get(728);
               
               Decimal yearTwoChange = getPercentageChange(fY1_1.Price__c, fY1_2.Price__c ) * 100;
               
               Security_Price_History__c fY2_1 = histories.get(728);
               Security_Price_History__c fY2_2 = histories.get(1094);
               
               Decimal yearThreeChange = getPercentageChange(fY1_1.Price__c, fY1_2.Price__c ) * 100;
               
               Decimal yearThreeAnnualizedChange = (item.Yearly_Change__c +yearTwoChange + yearThreeChange) / 3;
               
               item.Three_Year_Change__c = yearThreeAnnualizedChange ;
           }
           if(histories.size()>=1824){
               
               Security_Price_History__c fY1_1 = histories.get(364);
               Security_Price_History__c fY1_2 = histories.get(728);
               
               Decimal yearTwoChange = getPercentageChange(fY1_1.Price__c, fY1_2.Price__c ) * 100;
               
               Security_Price_History__c fY2_1 = histories.get(728);
               Security_Price_History__c fY2_2 = histories.get(1094);
               
               Decimal yearThreeChange = getPercentageChange(fY1_1.Price__c, fY1_2.Price__c ) * 100;
               
               Security_Price_History__c fY3_1 = histories.get(1094);
               Security_Price_History__c fY3_2 = histories.get(1458);
               
               Decimal yearFourChange = getPercentageChange(fY3_1.Price__c, fY3_2.Price__c ) * 100;
               
               Security_Price_History__c fY4_1 = histories.get(1458);
               Security_Price_History__c fY4_2 = histories.get(1824);
               
               Decimal yearFiveChange = getPercentageChange(fY4_1.Price__c, fY4_2.Price__c ) * 100;
               
               
               Decimal yearFiveAnnualizedChange = (item.Yearly_Change__c +yearTwoChange + yearThreeChange + yearFourChange + yearFiveChange ) / 5;
               
               item.Five_Year_Change__c = yearFiveAnnualizedChange ;
               
           }
           newList.add(item);
        }
       update newList;
    }
    
    private Decimal getPercentageChange(Decimal newNum, Decimal originalNum){
       return  (newNum - originalNum)/((newNum + originalNum)/2) ;
    }
    
    public void execute(){
        List<FinServ__FinancialAccount__c> records = [SELECT ID From FinServ__FinancialAccount__c WHERE RecordTypeId ='0124W000001bAJsQAM' and Id ='a0FP0000007mmF6MAI'];
        Set<Id> resultIds = (new Map<Id,FinServ__FinancialAccount__c>(records)).keySet();
        List<FinServ__Securities__c> securitiesList = [SELECT ID,FinServ__Price__c From FinServ__Securities__c];
        List<FinServ__FinancialHolding__c> holdingsList =  [select id, FinServ__FinancialAccount__r.Id, FinServ__Securities__r.Id, Cost_Basis__c, FinServ__PurchasePrice__c, FinServ__GainLoss__c, FinServ__Shares__c, FinServ__MarketValue__c from FinServ__FinancialHolding__c where FinServ__FinancialAccount__c = :resultIds ];
        List<Quarterly_Account_Summary__c> acccSumList =  [select id, Investment_Account__r.Id, Securities__r.id, Opening_Balance__c, Closing_Balance__c from Quarterly_Account_Summary__c where Quarter_Begin_Date__c=LAST_FISCAL_QUARTER and  Investment_Account__r.Id = :resultIds ];
        
        Map<String, FinServ__FinancialHolding__c> fhsMap = getFHsMap (holdingsList);
        Map<String, Quarterly_Account_Summary__c> qasMap  = getQASMap (acccSumList);
        
        Date startDate = [Select startdate From Period Where type = 'Quarter' and StartDate = LAST_FISCAL_QUARTER].startdate;
		Date endDate = [Select enddate From Period Where type = 'Quarter' and StartDate = LAST_FISCAL_QUARTER].enddate;
        Date startDateNextQ = [Select startdate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].startdate;
		Date endDateNextQ = [Select enddate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].enddate;
        
		//System.debug('records = ' + resultIds);
        
        List<Quarterly_Account_Summary__c> newAccSumList = new List<Quarterly_Account_Summary__c>();
        Map<String, QuarterTemp> aggData = new Map<String, QuarterTemp>();
        for (AggregateResult  agg : [
            SELECT 
            Financial_Account__r.Id accId,
			Securities__r.id secId,
            Initiator_Type__c,
            SUM( Buy_Amount__c) totalAmount
            FROM Investment_Transaction__c  
            WHERE Status__c = 'Complete' and Financial_Account__r.Id in :resultIds
            and Transaction_Date__c = LAST_QUARTER
            GROUP BY Financial_Account__r.Id, Securities__r.id, Initiator_Type__c
        ]) {
            
            String secId  = (String)agg.get('secId');
            String accId  = (String)agg.get('accId');
            String initiatorType  = (String)agg.get('Initiator_Type__c');
            Decimal totalAmount  = (Decimal)agg.get('totalAmount');
            
            String mapKey = accId +'-'+ secId;
            QuarterTemp qt = aggData.get(mapKey);
            if(qt==null) qt = new QuarterTemp();
            qt.secId = secId;
            qt.accId = accId;
            qt.key = mapKey;
            if(initiatorType == 'Contribution') qt.totalContribution = totalAmount;
            if(initiatorType == 'Withdrawal') qt.totalWithDrawal = totalAmount;
            
			aggData.put(mapKey, qt);
        }
        
        //System.debug('records = ' + aggData);
        //Preparing quarterly objects.
        Map<String, TotalTemp> totRecMaps = new Map<String, TotalTemp>();
        for(QuarterTemp qObjT : aggData.values()) {
            Quarterly_Account_Summary__c quarter = qasMap.get(qObjT.key);
            FinServ__FinancialHolding__c fhObj = fhsMap.get(qObjT.key);
            if(quarter == null) {
                quarter = new Quarterly_Account_Summary__c();
                quarter.Investment_Account__r.Id = qObjT.accId;
                quarter.Securities__r.id = qObjT.secId;
                quarter.Opening_Balance__c = 0;
                quarter.Quarter_Begin_Date__c = startDate;
                quarter.Quarter_End_Date__c = endDate;
            }  
            quarter.Contribution_Amount__c = qObjT.totalContribution;
            quarter.Withdrawals_Amount__c = qObjT.totalWithDrawal;
            quarter.Closing_Balance__c = fhObj.FinServ__MarketValue__c;
            quarter.Total_Gains__c = fhObj.FinServ__GainLoss__c;
            //System.debug('quarter = ' + quarter);
            newAccSumList.add(quarter);
            
            TotalTemp totalTmp = totRecMaps.get(qObjT.accId);
            if(totalTmp == null) {
                totalTmp = new TotalTemp(qObjT.accId, 
                                         startDate, 
                                         endDate, 
                                         quarter.Opening_Balance__c, 
                                         qObjT.totalContribution,  
                                         qObjT.totalWithDrawal, 
                                         fhObj.FinServ__MarketValue__c,
                                         fhObj.FinServ__GainLoss__c );
            } else {
                totalTmp.totalOpen += quarter.Opening_Balance__c;
                totalTmp.totalContribution += qObjT.totalContribution;
                totalTmp.totalWithDrawal += qObjT.totalWithDrawal;
                totalTmp.totalClose += fhObj.FinServ__MarketValue__c;
                totalTmp.totGainLoss += fhObj.FinServ__GainLoss__c ;
            }
            totRecMaps.put(qObjT.accId, totalTmp);
            
            //Preparing current quarterly object with opening balance for each security.
            Quarterly_Account_Summary__c nextQObj = new Quarterly_Account_Summary__c();
            nextQObj.Investment_Account__c = qObjT.accId;
            nextQObj.Securities__c = qObjT.secId;
            nextQObj.Opening_Balance__c = fhObj.FinServ__MarketValue__c;
            nextQObj.Quarter_Begin_Date__c = startDateNextQ;
            nextQObj.Quarter_End_Date__c = endDateNextQ;
            
            newAccSumList.add(nextQObj);
        }
        
        //Inserting totoal records
        for(TotalTemp totTemp : totRecMaps.values()){
            Quarterly_Account_Summary__c totalRec = new Quarterly_Account_Summary__c();
            totalRec.Investment_Account__c = totTemp.accId;
            totalRec.Opening_Balance__c = totTemp.totalOpen;
            totalRec.Quarter_Begin_Date__c = totTemp.startDate;
            totalRec.Quarter_End_Date__c = totTemp.endDate;
            totalRec.Contribution_Amount__c = totTemp.totalContribution;
            totalRec.Withdrawals_Amount__c = totTemp.totalWithDrawal;
            totalRec.Closing_Balance__c = totTemp.totalClose;
            totalRec.Total_Gains__c = totTemp.totGainLoss;
            totalRec.Total_Row__c = 'Yes';
            newAccSumList.add(totalRec);
        }
        
		upsert newAccSumList;
    }
    
    private Map<String, FinServ__FinancialHolding__c> getFHsMap(List<FinServ__FinancialHolding__c> holdingsList){
        Map<String, FinServ__FinancialHolding__c> dataMap = new Map<String, FinServ__FinancialHolding__c>();
        for (FinServ__FinancialHolding__c  item : holdingsList) {
            String mapKey = item.FinServ__FinancialAccount__r.Id +'-'+ item.FinServ__Securities__r.Id;
            dataMap.put(mapKey, item);
        }
        return dataMap;
    }
    
    private Map<String, Quarterly_Account_Summary__c> getQASMap(List<Quarterly_Account_Summary__c> acccSumList){
        Map<String, Quarterly_Account_Summary__c> dataMap = new Map<String, Quarterly_Account_Summary__c>();
        for (Quarterly_Account_Summary__c  item : acccSumList) {
            String mapKey = item.Investment_Account__r.Id +'-'+ item.Securities__r.Id;
            dataMap.put(mapKey, item);
        }
        return dataMap;
    }

    public class QuarterTemp {
        public String key;
        public String secId;
        public String accId; 
        public Decimal totalContribution;
        public Decimal totalWithDrawal;
    }
    
    public class TotalTemp {
        public String accId; 
        Date startDate;
        Date endDate;
        public Decimal totalOpen = 0;
        public Decimal totalContribution = 0;
        public Decimal totalWithDrawal = 0;
        public Decimal totalClose = 0;
        public Decimal totGainLoss = 0;
        
        public TotalTemp(String accId, 
                         Date startDate, 
                         Date endDate, 
                         Decimal totalOpen, 
                         Decimal totalContribution, 
                         Decimal totalWithDrawal, 
                         Decimal totalClose, 
                         Decimal totGainLoss){
            this.accId = accId;
            this.startDate = startDate;
            this.endDate = endDate;
            this.totalOpen = totalOpen;
            this.totalContribution = totalContribution;
            this.totalWithDrawal = totalWithDrawal;
            this.totalClose = totalClose;
            this.totGainLoss = totGainLoss;
        }
    }

}