/**
 * Name: PostSecurityPriceHistoryCreationDailyBatch
 * Description: 
 * Moved/refactor logic from SecurityPriceHistoryHandler to PostSecurityPriceHistoryCreationDailyBatch
 * Test Class: PostSecurityPriceHistoryCreationDailyBatchTest
 * Created By: Satish Nikam - 7/15/2021
 * Modifications Log: 
 * Date         Modified By    Modification Details
 * 7/09/2021   Satish Nikam    Original Implementation for Post SecurityPriceHistory record Creation
**/
global class PostSecPriceHistoryCreationDailyBatch implements Schedulable, Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator(
            'SELECT Id, Price__c, Price_Date__c, Symbol__c FROM Security_Price_History__c Where Createddate = today'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Security_Price_History__c> secPriceHistoryList){
        Date currentDate = System.today();
        //Step - 1 - pull security to history map
        Map<Id, Security_Price_History__c> processMaps = new Map<Id, Security_Price_History__c>();
        for(Security_Price_History__c sph : secPriceHistoryList) {
            if(sph.Price_Date__c == currentDate) {
                processMaps.put(sph.Symbol__c, sph);
            }
        }
        Set<Id> secIds = processMaps.keySet();
        
        //Step - 2 -Fetch related securities        
        Map<ID, FinServ__Securities__c> secMap = new Map<ID, FinServ__Securities__c>([SELECT Id, FinServ__Price__c FROM FinServ__Securities__c where Id IN :secIds ]);
           
        //Step - 3 -Fetch all existing financial holdings
        Map<Id, List<FinServ__FinancialHolding__c>> fhMaps = new Map<Id, List<FinServ__FinancialHolding__c>>();
        for(FinServ__FinancialHolding__c ffh : [SELECT Id, FinServ__MarketValue__c, Cost_Basis__c, FinServ__PercentChange__c, FinServ__Price__c, FinServ__Shares__c, FinServ__Securities__r.Id from FinServ__FinancialHolding__c where FinServ__Securities__c  IN :secIds]) {
           List<FinServ__FinancialHolding__c> fhList = fhMaps.get(ffh.FinServ__Securities__r.Id);
           fhList =  (fhList==null) ? new List<FinServ__FinancialHolding__c>() :fhList;
           fhList.add(ffh);
           fhMaps.put(ffh.FinServ__Securities__r.Id, fhList);
        }
        
        //Step - 4 -Fetch Pending transactions
        Map<Id, List<Investment_Transaction__c>> itRecMaps = new Map<Id, List<Investment_Transaction__c>>();
        for(Investment_Transaction__c itRec : [SELECT id, Financial_Account__r.Id, Securities__r.Id, Status__c, Action_Type__c, Buy_Amount__c, shares_quantity__c, Cost_Basis__c, Purchase_Price__c  FROM Investment_Transaction__c where Status__c  = 'Pending' and Securities__r.Id IN :secIds]) {
            List<Investment_Transaction__c> itRecList = itRecMaps.get(itRec.Securities__r.Id);
            itRecList = (itRecList==null) ? new List<Investment_Transaction__c>() :itRecList;
            itRecList.add(itRec);
            itRecMaps.put(itRec.Securities__r.Id, itRecList);
        }
        
        ////Step - 5 - populate necessary data for Securities,FinancialHolding and Investment_Transaction
        List<FinServ__Securities__c> secList = new List<FinServ__Securities__c>();
        List<FinServ__FinancialHolding__c> fhList = new List<FinServ__FinancialHolding__c>();
        List<Investment_Transaction__c > itList = new List<Investment_Transaction__c >();
        
        for(Security_Price_History__c sphMaxDate : processMaps.values()) {
            FinServ__Securities__c sec = secMap.get(sphMaxDate.Symbol__c);
            if(sec!=null){
                sec.FinServ__Price__c = sphMaxDate.Price__c;
                secList.add(sec); //Securities
                if(fhMaps.containsKey(sec.Id)) {
                    for(FinServ__FinancialHolding__c ffh : fhMaps.get(sec.Id)) {
                        ffh.FinServ__Price__c = sec.FinServ__Price__c;
                        ffh.FinServ__MarketValue__c = sec.FinServ__Price__c * ffh.FinServ__Shares__c;
                        ffh.FinServ__GainLoss__c = ffh.FinServ__MarketValue__c - ffh.Cost_Basis__c;
                        decimal percentage = 0;
                        if(ffh.Cost_Basis__c != 0){
                            percentage = 100 * (ffh.FinServ__MarketValue__c - ffh.Cost_Basis__c)/ ffh.Cost_Basis__c;
                        }
                        ffh.FinServ__PercentChange__c = percentage;
                        fhList.add(ffh); //FinancialHolding
                    }
                }
                
                if(itRecMaps.get(sec.Id)!=null) {
                    for(Investment_Transaction__c itRec : itRecMaps.get(sec.Id)) {
                    itRec.Status__c = 'Processing';
                    itRec.Purchase_Price__c = sec.FinServ__Price__c;
                    
                    if (itRec.Action_Type__c == 'Buy' && itRec.Buy_Amount__c != null){
                        Decimal shares = itRec.Buy_Amount__c / sec.FinServ__Price__c;
                        itRec.shares_quantity__c = shares.setScale(6);
                        itRec.Cost_Basis__c = itRec.Buy_Amount__c;
                    }
                    if (itRec.Action_Type__c == 'Sell'){
                        
                        if(itRec.Buy_Amount__c != null) {
                            Decimal shares = itRec.Buy_Amount__c / sec.FinServ__Price__c;
                            itRec.shares_quantity__c = shares.setScale(6);
                            itRec.Cost_Basis__c = itRec.Buy_Amount__c * -1;
                        }else{
                            itRec.Cost_Basis__c = (sec.FinServ__Price__c * itRec.shares_quantity__c) * -1;
                            itRec.Buy_Amount__c = itRec.Cost_Basis__c;
                        }
                    }  
                    itList.add(itRec); //Investment_Transaction
                }
                }
                
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        //Step - 6 - update Security Holding
        if(!secList.isEmpty()){
            try{
                if( Schema.sObjectType.FinServ__Securities__c.fields.FinServ__Price__c.isUpdateable()) {
                    update secList;
                }
            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while updating Security List :'+ ex.getMessage());
                Database.rollback(sp);
                return ;
            }
        }
        
        //Step - 7 - Update financial Holding
        if(!fhList.isEmpty()){
            try{
                if( Schema.sObjectType.FinServ__FinancialHolding__c.fields.FinServ__Price__c.isUpdateable()) {
                    update fhList;
                }
            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while updating financial Holding :'+ ex.getMessage());
                Database.rollback(sp);//reverting both the DML operationreturn 'success';
                return;
            }
        }

        //Step - 8 - Update Investment Transaction
        if(!itList.isEmpty()){
            try{
                if( Schema.sObjectType.Investment_Transaction__c.fields.Status__c.isUpdateable()) {
                    update itList;
                }
            }Catch(Exception ex){
                //we can log error if needed
                System.debug('Error while updating Investment Transaction :'+ ex.getMessage());
                Database.rollback(sp);//reverting both the DML operationreturn 'success';
                return;
            }
        }
        
    }
    public void execute(SchedulableContext sc){
        //Chaining of Batch Jobs - #1 - PostSecPriceHistoryCreationDailyBatch
        Batch_Configuration__mdt pspHistoryRecord = Batch_Configuration__mdt.getInstance('PostSecPriceHistoryCreationDailyBatch');
        Integer transactionSize = pspHistoryRecord != null ? Integer.ValueOf(pspHistoryRecord.Transaction_Size__c) : 10;
        Database.executeBatch(new PostSecPriceHistoryCreationDailyBatch(),transactionSize);//need to move batch size to common custom setting / lable 
    }
    public void finish(Database.BatchableContext bc){
        //Chaining of Batch Jobs - #2 - AgeBasedPortfolioUpdateBatch
        Batch_Configuration__mdt pspHistoryRecord = Batch_Configuration__mdt.getInstance('AgeBasedPortfolioUpdateBatch');
        Integer transactionSize = pspHistoryRecord != null ? Integer.ValueOf(pspHistoryRecord.Transaction_Size__c) : 10;
        Database.executeBatch(new AgeBasedPortfolioUpdateBatch(),transactionSize);
    }
}