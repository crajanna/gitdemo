public without sharing class CreateFinancialServAccountsTest {
    
    @AuraEnabled(cacheable=true)
    public static void cacheStorage(String offerN, Decimal offerPerc,String offerA, Datetime offerD) {
        String userin = offerA;
         
        offerData od = new offerData(offerN,offerPerc,offerA,offerD);
        String objclass = JSON.serialize(od); //To cache, object data should be 
                                              // serializable.
         
        Cache.Session.put(userin,objclass); //Data Offer object data to Agent's
                                            //session cache using userId as the key.
    }
    public static String getOffers(String agentId) {
        String cacheOffer = (String)Cache.Session.get(agentId); //Cast to String since we serialized the value.
        if (cacheOffer != null) {
             return cacheOffer;   
        }
        else {
            return null; //If null check again later//
                         //Depending on usecase, as a fallback a *database query *
                         //can be done after a certain number of retries.
        }
    }
    class offerData {
        String offerName;
        Decimal offerDisc;
        String offerAgent;
        Datetime offerDate;
        public offerData(String name,Decimal disc,String agent,Datetime offerdt) {
            offerName = name;
            offerDisc = disc;
            offerAgent = agent;
            offerDate = offerdt;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Integer testAccountsCreation(String userId){
       
        System.debug('userId : '+userId);
        List<LoginHistory> loginHistoryList = [SELECT UserId, LoginTime from LoginHistory where userId=:userId ];
        //List<FinServ__FinancialAccount__c> acctList = [SELECT Id, Name, RecordTypeId, FinServ__FinancialAccountType__c, OwnerId, FinServ__PrimaryOwner__c FROM FinServ__FinancialAccount__c where FinServ__PrimaryOwner__c = '001P000001n5rv8IAA'];
        //List<FinServ__FinancialAccount__c> acctList = [SELECT Id, Name, RecordTypeId, FinServ__FinancialAccountType__c, OwnerId, FinServ__PrimaryOwner__c FROM FinServ__FinancialAccount__c where FinServ__PrimaryOwner__c =:accountId];
        //System.debug('acctList size:'+acctList.size());
        return loginHistoryList.size();
      
    }

    @AuraEnabled(cacheable=true)
    public static String testAccountsCreation2(String accountId){
       
        System.debug('accountId : '+accountId);
        //List<LoginHistory> loginHistoryList = [SELECT UserId, LoginTime from LoginHistory where userId=:userId ];
        try{
            /*FinServ__FinancialAccount__c finCashAccount = 
            new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='Cash Account',
                                             FinServ__PrimaryOwner__c = '001P000001nnZ1JIAU', 
                                             Name='Cash Account1', 
                                             FinServ__Status__c='Active',
                                             RecordTypeId='0124W000001bAJpQAM',
                                             FinServ__Nickname__c='businessName'+' Cash Account');
             Database.insert(finCashAccount);
            System.debug('finCashAccount => '+finCashAccount.Id);    

            
             FinServ__FinancialAccount__c finSroAccount = 
             new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='SRO',
                                             FinServ__PrimaryOwner__c = accountId, 
                                             RecordTypeId='0124W000001bAJpQAM',
                                             Name='SRO Account', 
                                             FinServ__Status__c='Active',
                                             FinServ__Nickname__c='businessName'+' SRO Account');
             Database.insert(finSroAccount);
        
            return finCashAccount.Id;
            */
            FinServ__FinancialAccount__c finCashAccount = 
            new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='Cash Account',
                                             FinServ__PrimaryOwner__c = '001P000001oYzeQIAS', 
                                             Name='Cash Account1', 
                                             FinServ__Status__c='Active',
                                             RecordTypeId='0124W000001bAJpQAM',
                                             FinServ__Nickname__c='businessName'+' Cash Account');
             Database.insert(finCashAccount);
            System.debug('finCashAccount => '+finCashAccount.Id);
            return 'Satish';
            
        }catch(Exception e){
            System.debug(e.getMessage());
            return e.getMessage();
        }
        
    }

    
    
}