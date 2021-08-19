public class SecurityPriceHistoryHandler {

    public static void onAfterInsert(List<Security_Price_History__c> newList){   
       //Moved this logic to batch - need to deactivate this trigger
        /*
        Date currentDate = System.today();
        
        Map<Id, Security_Price_History__c> processMaps = new Map<Id, Security_Price_History__c>();
        for(Security_Price_History__c sph : newList) {
            if(sph.Price_Date__c == currentDate) {
                processMaps.put(sph.Symbol__c, sph);
            }
        }
        Set<Id> secIds = processMaps.keySet();
        
        //Fetch securities        
        Map<ID, FinServ__Securities__c> secMap = new Map<ID, FinServ__Securities__c>([SELECT Id, FinServ__Price__c FROM FinServ__Securities__c where Id IN :secIds ]);
           
        //Fetch In-Progress financial holdings
        Map<Id, List<FinServ__FinancialHolding__c>> fhMaps = new Map<Id, List<FinServ__FinancialHolding__c>>();
        for(FinServ__FinancialHolding__c ffh : [SELECT Id, FinServ__MarketValue__c, Cost_Basis__c, FinServ__PercentChange__c, FinServ__Price__c, FinServ__Shares__c, FinServ__Securities__r.Id from FinServ__FinancialHolding__c where FinServ__Securities__c  IN :secIds]) {
           List<FinServ__FinancialHolding__c> fhList = fhMaps.get(ffh.FinServ__Securities__r.Id);
            if(fhList==null){
                fhList = new List<FinServ__FinancialHolding__c>(); 
                fhMaps.put(ffh.FinServ__Securities__r.Id, fhList);
            }
            fhList.add(ffh);
            fhMaps.put(ffh.FinServ__Securities__r.Id, fhList);
        }
        
        //Fetch In-Progress transactions
        Map<Id, List<Investment_Transaction__c>> itRecMaps = new Map<Id, List<Investment_Transaction__c>>();
        for(Investment_Transaction__c itRec : [SELECT id, Financial_Account__r.Id, Securities__r.Id, Status__c, Action_Type__c, Buy_Amount__c, shares_quantity__c, Cost_Basis__c, Purchase_Price__c  FROM Investment_Transaction__c where Status__c  = 'Pending' and Securities__r.Id IN :secIds]) {
           List<Investment_Transaction__c> itRecList = itRecMaps.get(itRec.Securities__r.Id);
            if(itRecList==null){
                itRecList = new List<Investment_Transaction__c>(); 
                itRecMaps.put(itRec.Securities__r.Id, itRecList);
            }
            itRecList.add(itRec);
            itRecMaps.put(itRec.Securities__r.Id, itRecList);
        }
        
        
        
        List<FinServ__Securities__c> secList = new List<FinServ__Securities__c>();
        List<FinServ__FinancialHolding__c> fhList = new List<FinServ__FinancialHolding__c>();
        List<Investment_Transaction__c > itList = new List<Investment_Transaction__c >();
        
        for(Security_Price_History__c sphMaxDate : processMaps.values()) {
            FinServ__Securities__c sec = secMap.get(sphMaxDate.Symbol__c);
            if(sec!=null){
                sec.FinServ__Price__c = sphMaxDate.Price__c;
                secList.add(sec);
                if(fhMaps.containsKey(sec.Id)) {
                    for(FinServ__FinancialHolding__c ffh : fhMaps.get(sec.Id)) {
                        ffh.FinServ__Price__c = sec.FinServ__Price__c;
                        ffh.FinServ__MarketValue__c = sec.FinServ__Price__c * ffh.FinServ__Shares__c;
                        ffh.FinServ__GainLoss__c = ffh.FinServ__MarketValue__c - ffh.Cost_Basis__c;
                        decimal percentage = 100 * (ffh.FinServ__MarketValue__c - ffh.Cost_Basis__c)/ ffh.Cost_Basis__c;
                        ffh.FinServ__PercentChange__c = percentage;
                        fhList.add(ffh);
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
                    itList.add(itRec);
                }
                }
                
            }
        }
        
        
       if(secList.size() > 0)
            update secList;
                
       if(fhList.size() > 0)
            update fhList;
        
       if(itList.size() > 0)
            update itList; */
      
    }
}