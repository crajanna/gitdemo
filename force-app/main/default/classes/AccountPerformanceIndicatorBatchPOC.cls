/* Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/15/2021   Satish Nikam    Task-10865 - T2 - Refactor Financial Holding Performace Indicator batch job
**/

   
    global class AccountPerformanceIndicatorBatchPOC implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
   
        global Integer recordsProcessed = 0;
        global Double pow3Yr = 0.333333;
        global Double pow5Yr = 0.2; 
        public static Id invAcctRecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId();
        public Integer rangeDays = 30;

        AccountPerformanceIndicatorBatchPOC(Integer range){
            this.rangeDays = range;
        }
    
        public Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator(
                'SELECT ID, FinServ__Balance__c, FinServ__PerformanceMTD__c, FinServ__PerformanceQTD__c, FinServ__Performance1Yr__c, FinServ__Performance3Yr__c  From FinServ__FinancialAccount__c WHERE RecordTypeId = :invAcctRecordTypeId' // need to add active status
            );
        }
        public void execute(SchedulableContext sc){
            //Chaining of AccountPerformanceIndicatorBatches - #1 - 30
            Batch_Configuration__mdt pspHistoryRecord = Batch_Configuration__mdt.getInstance('AccountPerformanceIndicator' + String.ValueOf(30));
            Integer transactionSize = pspHistoryRecord != null ? Integer.ValueOf(pspHistoryRecord.Transaction_Size__c) : 10;
            Database.executeBatch(new AccountPerformanceIndicatorBatchPOC(30),transactionSize);
        }
        public void execute(Database.BatchableContext bc, List<FinServ__FinancialAccount__c> records){
           
            Date currentDate  = System.today();
            Date rangeDate = currentDate.addDays(-1 * rangeDays);
                 
            List<FinServ__FinancialAccount__c> updatedList = new List<FinServ__FinancialAccount__c> ();
            Map<ID, FinServ__Securities__c> secMap = new Map<ID, FinServ__Securities__c>([Select Id,FinServ__SecuritiesName__c, FinServ__Price__c,Monthly_Change__c, Quarterly_Change__c, Yearly_Change__c, Three_Year_Change__c, Five_Year_Change__c, 
                                                    (select Name, Price__c, Price_Date__c from Security_Price_Histories__r where Price_Date__c IN ( :currentDate, :rangeDate) order by Price_Date__c DESC limit 10) 
                                                    from FinServ__Securities__c]);
                
            getPerformance(currentDate,rangeDate, records, secMap, 1);
               
        }
    
        private void getPerformance(Date currentDate, Date rangeDate, List<FinServ__FinancialAccount__c> accountRecords, Map<ID, FinServ__Securities__c> secMap, Double powP){

            Decimal convertPercent = 0.0;
            Long totalDays = rangeDate.daysBetween(currentDate);
            System.debug('Total Days = ' + totalDays);
            //Map<Id,Map<Id,List<Investment_Transaction__c>>> acctToSecInvTransactionMap = new Map<Id,Map<Id,List<Investment_Transaction__c>>>();
            //Map<Id,Decimal> acctTototalUnit = new Map<Id,Decimal>();
            //Map<Id,Map<Id,Decimal>> acctToSecRangeTrxTotal = new Map<Id,Map<Id,Decimal>>();
            //Map<Id,Map<Id,Decimal>> acctToSecRangeWATotal = new Map<Id,Map<Id,Decimal>>();

            //- calculate per account - RangeTrxTotal, RangeWATotal and RangeTotal
            Map<Id,Decimal> accRangeTrxTotal = new Map<Id,Decimal>();
            Map<Id,Decimal> accRangeWATotal = new Map<Id,Decimal>();
            
            for (Investment_Transaction__c  trxItem : [SELECT Financial_Account__c,Securities__c,Action_Type__c, Cost_Basis__c,Name,shares_quantity__c, Transaction_Date__c from Investment_Transaction__c where Financial_Account__c IN :accountRecords and Securities__r.Id = :secMap.keyset() and Transaction_Date__c >= :rangeDate and Transaction_Date__c <=:currentDate  and Status__c = 'Complete'  ]) {
                
       
                //1
               /* Map<Id,List<Investment_Transaction__c>> secToInvTranMap = acctToSecInvTransactionMap.get(trxItem.Financial_Account__c) == null ? new Map<Id,List<Investment_Transaction__c>>():acctToSecInvTransactionMap.get(trxItem.Financial_Account__c);
                List<Investment_Transaction__c> invTranList = secToInvTranMap.get(trxItem.Securities__c) == null ? new List<Investment_Transaction__c>():secToInvTranMap.get(trxItem.Securities__c);
                secToInvTranMap.put(trxItem.Securities__c,invTranList);
                acctToSecInvTransactionMap.put(trxItem.Financial_Account__c,secToInvTranMap);*/
                
                //2
                //Map<Id,Decimal> secRangeTrxTotal = acctToSecRangeTrxTotal.get(trxItem.Financial_Account__c) == null ? new Map<Id,Decimal>() : acctToSecRangeTrxTotal.get(trxItem.Financial_Account__c) ;//+ trxItem.Cost_Basis__c;
                //Decimal rangeTrxTotal = secRangeTrxTotal.get(trxItem.Securities__c) != null ? secRangeTrxTotal.get(trxItem.Securities__c) + trxItem.Cost_Basis__c : trxItem.Cost_Basis__c;
                //secRangeTrxTotal.put(trxItem.Securities__c,rangeTrxTotal);
                //acctToSecRangeTrxTotal.put(trxItem.Financial_Account__c,secRangeTrxTotal);
                
                Decimal existingRangeTrxTotal = accRangeTrxTotal.get(trxItem.Financial_Account__c) != null ? accRangeTrxTotal.get(trxItem.Financial_Account__c) : 0;
                accRangeTrxTotal.put(trxItem.Financial_Account__c,existingRangeTrxTotal+trxItem.Cost_Basis__c);

                //3
                Date trxDate = date.newinstance(trxItem.Transaction_Date__c.year(), trxItem.Transaction_Date__c.month(), trxItem.Transaction_Date__c.day());
                Long numberDays = trxDate.daysBetween(rangeDate);
                Decimal wavg = (numberDays<=totalDays) ? (Decimal.valueOf(totalDays) - Decimal.valueOf(numberDays)) / Decimal.valueOf(totalDays) : 0;
                wavg = wavg.setScale(8);
                Decimal flowValue = trxItem.Cost_Basis__c * wavg;
                
                /*Map<Id,Decimal> secRangeWATotal = acctToSecRangeWATotal.get(trxItem.Financial_Account__c) == null ? new Map<Id,Decimal>() : acctToSecRangeWATotal.get(trxItem.Financial_Account__c) ;//+ trxItem.Cost_Basis__c;
                Decimal rangeWATotal = secRangeWATotal.get(trxItem.Securities__c) != null ? secRangeWATotal.get(trxItem.Securities__c) + flowValue : flowValue;
                secRangeWATotal.put(trxItem.Securities__c,rangeWATotal);
                acctToSecRangeWATotal.put(trxItem.Financial_Account__c,secRangeWATotal);*/

                Decimal existingRangeWATotal = accRangeWATotal.get(trxItem.Financial_Account__c) != null ? accRangeWATotal.get(trxItem.Financial_Account__c) : 0;
                accRangeWATotal.put(trxItem.Financial_Account__c,existingRangeWATotal+flowValue);

            }
            
            Map<Id,Decimal> accRangeTotal = new Map<Id,Decimal>();
            //Map<Id,Map<Id,Decimal>> acctToSecRangeTotal = new Map<Id,Map<Id,Decimal>>();
            for (AggregateResult  trxList : [SELECT Financial_Account__c accId,Securities__c secId,sum(Transaction_Units__c) total from Investment_Transaction__c where Financial_Account__c IN :accountRecords and Transaction_Date__c <= :rangeDate and Status__c = 'Complete' GROUP BY ROLLUP(Financial_Account__c, Securities__c) ]) {
                
                //4
                Decimal totalUnits = (Decimal)trxList.get('total');
                String secId  = (String)trxList.get('secId');
                String accId  = (String)trxList.get('accId');
                System.debug('rangeDate = ' + rangeDate);
                System.debug('totalUnits = ' + totalUnits);

                //Map<Id,Decimal> secRangeTotal = acctToSecRangeTotal.get(accId) == null ? new Map<Id,Decimal>() : acctToSecRangeTotal.get(accId) ;
                FinServ__Securities__c secEntity =  secMap.get(secId);
                List<Security_Price_History__c> histories = secEntity.Security_Price_Histories__r;
                for(Security_Price_History__c sh : histories){
                    if(sh.Price_Date__c == rangeDate){
                        Decimal rangeTotal = (totalUnits * sh.Price__c);
                        //secRangeTotal.put(secId,rangeTotal);
                        //acctToSecRangeTotal.put(accId,secRangeTotal);
                        Decimal existingRangeTotal = accRangeTotal.get(accId) != null ? accRangeTotal.get(accId) : 0;
                        accRangeTotal.put(accId,existingRangeTotal+rangeTotal);
                    }
                }
            }
            
            //5 - calculate per account - RangeTrxTotal, RangeWATotal and RangeTotal
            //Map<Id,Decimal> accRangeTrxTotal = new Map<Id,Decimal>();
            //Map<Id,Decimal> accRangeWATotal = new Map<Id,Decimal>();
            //Map<Id,Decimal> accRangeTotal = new Map<Id,Decimal>();
            /*for(FinServ__FinancialAccount__c acctRecord: accountRecords){
                Id acctId = acctRecord.Id;
                Map<Id,Decimal> secRangeTrxTotal = acctToSecRangeTrxTotal.get(acctId);
                if(secRangeTrxTotal != null && !secRangeTrxTotal.isEmpty()){
                    for(Decimal RangeTrxTotal :secRangeTrxTotal.Values()){
                        accRangeTrxTotal.put(acctId,accRangeTrxTotal.get(acctId)+RangeTrxTotal);
                    }
                }

                Map<Id,Decimal> secRangeWATotal = acctToSecRangeWATotal.get(acctId);
                if(secRangeWATotal != null && !secRangeWATotal.isEmpty()){
                    for(Decimal RangeWATotal :secRangeWATotal.Values()){
                        accRangeWATotal.put(acctId,accRangeWATotal.get(acctId)+RangeWATotal);
                    }
                }

                Map<Id,Decimal> secRangeTotal = acctToSecRangeTotal.get(acctId);
                if(secRangeTotal != null && !secRangeTotal.isEmpty()){
                    for(Decimal RangeTotal :secRangeTotal.Values()){
                        accRangeTotal.put(acctId,accRangeTotal.get(acctId)+RangeTotal);
                    }
                }

            }*/

            //7
            List<FinServ__FinancialAccount__c> updatedList = new List<FinServ__FinancialAccount__c> ();
            for(FinServ__FinancialAccount__c acctRecord: accountRecords){
                Id acctId = acctRecord.Id;
                                 
                //System.debug('currentBalance = ' + currentBalance);
                //System.debug('rangeTotal = ' + rangeTotal);
                Decimal rangeTotal = accRangeTotal.get(acctId);
                Decimal rangeWATotal = accRangeWATotal.get(acctId);
                Decimal rangeTrxTotal = accRangeTrxTotal.get(acctId);
                if(rangeTotal != null && rangeTotal > 0) {
                    if(rangeWATotal!=0) {
                        convertPercent = (((acctRecord.FinServ__Balance__c - rangeTotal) - rangeTrxTotal ) / (rangeTotal + rangeWATotal)) * 100;
                        System.debug('convertPercent = ' + convertPercent);
                    } else {
                        Decimal percentTot = (acctRecord.FinServ__Balance__c / rangeTotal);
                        convertPercent = (Math.pow(percentTot.doubleValue(), powP)-1) * 100;
                        System.debug('convertPercent = ' + convertPercent);
                    }
                    if(rangeDays == 30){
                        acctRecord.FinServ__PerformanceMTD__c = convertPercent;
                    }else if(rangeDays == 90){
                        acctRecord.FinServ__PerformanceQTD__c = convertPercent;
                    }else if(rangeDays == 365){
                        acctRecord.FinServ__Performance1Yr__c = convertPercent;
                    }else if(rangeDays == 1095){
                        acctRecord.FinServ__Performance3Yr__c = convertPercent;
                    }else if(rangeDays == 1825){
                        acctRecord.Performance5Yr_c__c = convertPercent;
                    }
                    updatedList.add(acctRecord);
                }
            }  
            try{
                if(!updatedList.isEmpty() && Schema.sObjectType.FinServ__FinancialAccount__c.fields.FinServ__PerformanceMTD__c.isUpdateable()) {
                    update updatedList;
                }
            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while updating financial Account :'+ ex.getMessage());
            }  
        }

        public void finish(Database.BatchableContext bc){
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()];
            // call some utility to send email
            EmailUtils.sendMessage(job, recordsProcessed);

            
            Integer nextRunDays = -1;
            if(rangeDays == 30){
                nextRunDays = 90;
            }else if(rangeDays == 90){
                nextRunDays = 365;
            }else if(rangeDays == 365){
                nextRunDays = 1095;
            }else if(rangeDays == 1095){
                nextRunDays = 1825;
            }

            if(nextRunDays != -1){
                Batch_Configuration__mdt pspHistoryRecord = Batch_Configuration__mdt.getInstance('AccountPerformanceIndicator' + String.ValueOf(nextRunDays));
                Integer transactionSize = pspHistoryRecord != null ? Integer.ValueOf(pspHistoryRecord.Transaction_Size__c) : 10;
                Database.executeBatch(new AccountPerformanceIndicatorBatchPOC(nextRunDays),transactionSize);
            }
            
        }
        
    }