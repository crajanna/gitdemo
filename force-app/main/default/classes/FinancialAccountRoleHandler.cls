/**
     * Name: FinancialAccountRoleHandler
     * Description: apex based sharing implementation for security worj
     * Test Class: FinancialAccountRoleHandlerTest
     * Created By: Satish Nikam - 8/13/2021
     * Modifications Log: 
     * Date         Modified By    Modification Details
     * 8/13/2021   Satish Nikam    Original Implementation for apex based sharing
    **/
    public class FinancialAccountRoleHandler {
        private static FinancialAccountRoleHandler instance = null;
        public static final String PRIMARY_ROLE = 'Primary Owner';	
        public static final String READ_ACCESS = 'Read';	
        public static final String EDIT_ACCESS = 'Edit';
        public static final String ROWCAUSE_MANUAL = 'Manual';
        Map<Id,FinServ__FinancialAccountRole__c> acctToFinRoleMap = new Map<Id,FinServ__FinancialAccountRole__c>();
        Map<Id,FinServ__FinancialAccountRole__c> primaryAcctToFinRoleMap = new Map<Id,FinServ__FinancialAccountRole__c>();
        Map<Id,FinServ__FinancialAccountRole__c> cntToFinRoleMap = new Map<Id,FinServ__FinancialAccountRole__c>();
        Map<Id,Id> fARFinAccountMap = new Map<Id,Id>();
        Map<Id,Id> finAcctToPrimaryRolePersonAcctMap = new Map<Id,Id>();
        Set<Id> finAccIdSet = new Set<Id>();
        public FinancialAccountRoleHandler() {}
        public static FinancialAccountRoleHandler getInstance(){
            if(instance == null) instance = new FinancialAccountRoleHandler();
            return instance;
        }
        /*
        public void OnBeforeInsert(List <FinServ__FinancialAccountRole__c> newFARList) {
            system.debug('FAR Trigger On Before Insert');
        }*/

        public void OnAfterInsert(List <FinServ__FinancialAccountRole__c> newFARList) {
            system.debug('FAR Trigger On After Insert');

            populateSharingData(newFARList);
            //Share respective access to beneficiaries
            System.debug('finAcctToPrimaryRolePersonAcctMap-->'+finAcctToPrimaryRolePersonAcctMap);
            System.debug('acctToFinRoleMap-->'+acctToFinRoleMap);
            List<FinServ__FinancialAccount__Share> finAccountShareList = new List<FinServ__FinancialAccount__Share>();
            List<AccountShare> accountShareList = new List<AccountShare>();
            for(User usrRecord:[Select Id, AccountId From User Where AccountId IN :acctToFinRoleMap.KeySet()]){
                FinServ__FinancialAccountRole__c fARRecord = acctToFinRoleMap.get(usrRecord.AccountId);
                if(fARRecord == null)continue;
                FinServ__FinancialAccount__Share finAccountShare = new FinServ__FinancialAccount__Share();
                finAccountShare.AccessLevel = fARRecord.FinServ__Role__c == PRIMARY_ROLE ? EDIT_ACCESS :READ_ACCESS;        
                finAccountShare.ParentId = fARRecord.FinServ__FinancialAccount__c;
                finAccountShare.UserOrGroupId = usrRecord.Id;
                finAccountShareList.add(finAccountShare);

                Id personAcctId = finAcctToPrimaryRolePersonAcctMap.get(fARRecord.FinServ__FinancialAccount__c);
                System.debug('personAcctId-->'+personAcctId);
                System.debug('fARRecord.FinServ__FinancialAccount__c-->'+fARRecord.FinServ__FinancialAccount__c);
                if(personAcctId != null && fARRecord.FinServ__Role__c != PRIMARY_ROLE){//adding access to Primary owners person Account
                    AccountShare accountShare = new AccountShare();
                    accountShare.AccountAccessLevel = fARRecord.FinServ__Role__c == PRIMARY_ROLE ? EDIT_ACCESS :READ_ACCESS;
                    //accountShare.ContactAccessLevel = accountShare.AccountAccessLevel;
                    accountShare.OpportunityAccessLevel = 'None';        
                    accountShare.AccountId = personAcctId;
                    accountShare.UserOrGroupId = usrRecord.Id;
                    accountShareList.add(accountShare);
                }
            }

            if(!finAccountShareList.isEmpty()){
                try{
                    System.debug('finAccountShareList-->'+finAccountShareList);
                    insert finAccountShareList;
                    System.debug('finAccountShareList 0-->'+finAccountShareList[0].Id);
                }Catch(Exception ex){
                    System.debug('need log error if needed: '+ex.getMessage());
                }
                
            }

            if(!accountShareList.isEmpty()){
                try{
                    System.debug('accountShareList-->'+accountShareList);
                    insert accountShareList;
                    System.debug('accountShareList 0-->'+accountShareList[0].Id);
                }Catch(Exception ex){
                    System.debug('need log error if needed: '+ex.getMessage());
                }
                
            }

           
        }
        /*
        public void OnAfterUpdate(List <FinServ__FinancialAccountRole__c> newFARList, List <FinServ__FinancialAccountRole__c> oldFARList, Map < ID, FinServ__FinancialAccountRole__c > newFARMap, Map < ID, FinServ__FinancialAccountRole__c > oldFARMap) {
            system.debug('FAR Trigger On After Update ');
        }*/

        public void OnAfterDelete(List <FinServ__FinancialAccountRole__c> oldFARList) {
            system.debug('FAR Trigger On After Delete');
            populateSharingData(oldFARList);

            //Remove respective access for beneficiaries
            System.debug('onDelete :finAcctToPrimaryRolePersonAcctMap-->'+finAcctToPrimaryRolePersonAcctMap);
            System.debug('onDelete :acctToFinRoleMap-->'+acctToFinRoleMap);
            Map<Id,Id> userToAccountMap = new Map<Id,Id>();
            Map<Id,Id> finAccountToAccountMap = new Map<Id,Id>();

            //we can club query and logic during final changes
           /* for(User usrRecord:[Select Id, AccountId From User Where AccountId IN :finAcctToPrimaryRolePersonAcctMap.Values()]){
                System.debug('onDelete :usrRecord-->'+usrRecord);
                accountToUserMap.put(usrRecord.AccountId,usrRecord.Id);
            }*/

            for(User usrRecord:[Select Id, AccountId From User Where AccountId IN :acctToFinRoleMap.KeySet()]){
                System.debug('onDelete :usrRecord-->'+usrRecord);
                FinServ__FinancialAccountRole__c fARRecord = acctToFinRoleMap.get(usrRecord.AccountId);
                if(fARRecord == null)continue;
                userToAccountMap.put(usrRecord.Id,fARRecord.FinServ__RelatedAccount__c);
                if(acctToFinRoleMap.get(usrRecord.AccountId) != null){
                    finAccountToAccountMap.put(acctToFinRoleMap.get(usrRecord.AccountId).FinServ__FinancialAccount__c,usrRecord.AccountId);
                }
                
            }
            
            List<FinServ__FinancialAccount__Share> finAcctShareToDelete = new List<FinServ__FinancialAccount__Share>();
            for(FinServ__FinancialAccount__Share finAcctShare :[Select Id, UserOrGroupId, ParentId 
                                                                From FinServ__FinancialAccount__Share
                                                                Where ParentId IN :finAccIdSet AND
                                                                      rowCause = :ROWCAUSE_MANUAL]){
                System.debug('finAcctShare-->'+finAcctShare);
                System.debug('finAccountToAccountMap-->'+finAccountToAccountMap);
                if(finAccountToAccountMap.get(finAcctShare.ParentId) != null){
                    finAcctShareToDelete.add(finAcctShare);
                }  
            }
            List<AccountShare> acctShareToDelete = new List<AccountShare>();
            for(AccountShare acctShare :[Select Id, UserOrGroupId, AccountId 
                                                                From AccountShare
                                                                Where UserOrGroupId IN :userToAccountMap.KeySet() AND
                                                                      rowCause = :ROWCAUSE_MANUAL]){
                System.debug('acctShare-->'+acctShare);
                System.debug(' userToAccountMap--> '+userToAccountMap);
                FinServ__FinancialAccountRole__c fARRecord = primaryAcctToFinRoleMap.get(acctShare.AccountId);
                if(fARRecord == null)continue;
                System.debug(' fARRecord--> '+fARRecord);
                Id personAcctId = finAcctToPrimaryRolePersonAcctMap.get(fARRecord.FinServ__FinancialAccount__c); 
                System.debug(' personAcctId--> '+personAcctId); 
                System.debug(' acctShare.AccountId--> '+acctShare.AccountId);                                                           
                if(personAcctId != null && personAcctId == acctShare.AccountId){
                    acctShareToDelete.add(acctShare);
                }  
            }

            if(!finAcctShareToDelete.isEmpty()){
                try{
                    System.debug('finAcctShareToDelete-->'+finAcctShareToDelete);
                    delete finAcctShareToDelete;
                }Catch(Exception ex){
                    System.debug('need log error if needed: '+ex.getMessage());
                }
            }

            if(!acctShareToDelete.isEmpty()){
                try{
                    System.debug('acctShareToDelete-->'+acctShareToDelete);
                    delete acctShareToDelete;
                }Catch(Exception ex){
                    System.debug('need log error if needed: '+ex.getMessage());
                }
            }
        }

        public void populateSharingData(List <FinServ__FinancialAccountRole__c> farList){
            if(farList == null || farList.isEmpty())return;
            for(FinServ__FinancialAccountRole__c FARRecord :farList){
                if(FARRecord.FinServ__RelatedAccount__c != null){
                    acctToFinRoleMap.put(FARRecord.FinServ__RelatedAccount__c,FARRecord);
                }else if(FARRecord.FinServ__RelatedContact__c != null){
                    cntToFinRoleMap.put(FARRecord.FinServ__RelatedContact__c,FARRecord);
                }
                finAccIdSet.add(FARRecord.FinServ__FinancialAccount__c);
                if(FARRecord.FinServ__Role__c != PRIMARY_ROLE && FARRecord.FinServ__FinancialAccount__c != null){
                    //nonPrimaryRoleSet.add(FARRecord.FinServ__FinancialAccount__c);
                    fARFinAccountMap.put(FARRecord.Id,FARRecord.FinServ__FinancialAccount__c);
                }
            }

            //Handle Account based roles
            System.debug('cntToFinRoleMap-->'+cntToFinRoleMap);
            if(!cntToFinRoleMap.isEmpty()){
                for(Contact cnt :[Select Id, AccountId From Contact Where Id IN :cntToFinRoleMap.keySet()]){
                    if(cnt.AccountId != null){
                        FinServ__FinancialAccountRole__c farRecord = cntToFinRoleMap.get(cnt.Id);
                        if(farRecord != null){
                            acctToFinRoleMap.put(cnt.AccountId,farRecord);
                            if(farRecord.FinServ__Role__c != PRIMARY_ROLE){
                                fARFinAccountMap.put(farRecord.Id,farRecord.FinServ__FinancialAccount__c);
                            }
                        }
                        
                    }
                    System.debug('cnt.AccountId-->'+cnt.AccountId);
                }
            }

            for(FinServ__FinancialAccountRole__c farPrimaryOwner:[Select Id,FinServ__RelatedAccount__c,FinServ__FinancialAccount__c,FinServ__Role__c From FinServ__FinancialAccountRole__c 
                                                                Where FinServ__FinancialAccount__c = :fARFinAccountMap.Values() AND 
                                                                        FinServ__Role__c = :PRIMARY_ROLE]){
                finAcctToPrimaryRolePersonAcctMap.put(farPrimaryOwner.FinServ__FinancialAccount__c,farPrimaryOwner.FinServ__RelatedAccount__c);
                primaryAcctToFinRoleMap.put(farPrimaryOwner.FinServ__RelatedAccount__c,farPrimaryOwner);

            }
        }
    }