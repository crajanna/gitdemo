public without sharing class CreateFinancialAccount {

    //public String accountId{get;set;}

    //private static final String  BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();

    @AuraEnabled(cacheable=true)
    public static List<FinServ__FinancialAccount__c > getFinancialAccountsById(String accountId) {
        System.debug('getFinancialAccountsById ' + accountId); 
        List<FinServ__FinancialAccount__c> items = [SELECT Id, Name, Bank_Account_Number__c, FinServ__FinancialAccountNumber__c, 
                                                    FinServ__RoutingNumber__c, 	FinServ__RecordTypeName__c, FinServ__PrimaryOwner__c from FinServ__FinancialAccount__c WHERE 
                                                    FinServ__PrimaryOwner__c in (:accountId) and RecordType.DeveloperName in ('BankingAccount') ];

          
      List<FinServ__FinancialAccount__c> finalList = null;
      if(items!=null){
        finalList = new List<FinServ__FinancialAccount__c>();
        for(FinServ__FinancialAccount__c acc : items)
        {
            if(acc.Bank_Account_Number__c!=null){
                Integer len = acc.Bank_Account_Number__c.length();
                acc.Bank_Account_Number__c = acc.Bank_Account_Number__c.Substring(len-4, len);
                finalList.add(acc) ;
            }          
        }        
      }                                                 
       return finalList;                                           
    }


    @AuraEnabled
    public static Decimal getCashBalanceByAccountId(String accountId) {
        return [SELECT FinServ__CashBalance__c
                                            FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Cash Account' AND 
                                            FinServ__PrimaryOwner__c in (:accountId)
                                            LIMIT 1].FinServ__CashBalance__c;                                                    
                                    
    }

    @AuraEnabled(cacheable=true)
    public static String getCashAccountNumberByAccountId(String accountId) {
        return [SELECT FinServ__FinancialAccountNumber__c
                                            FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Cash Account' AND 
                                            FinServ__PrimaryOwner__c in (:accountId)
                                            LIMIT 1].FinServ__FinancialAccountNumber__c;                                                    
                                    
    }


    @AuraEnabled(cacheable=true)
    public static Id getCashAccountIdByAccount(String accountId) {
        return [SELECT Id FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Cash Account' AND 
                                            FinServ__PrimaryOwner__c in (:accountId) Limit 1].Id;
    }

    @AuraEnabled(cacheable=true)
    public static Id getScholarshipFinAccount() {
        return [SELECT Id FROM FinServ__FinancialAccount__c 
                                            WHERE FinServ__FinancialAccountType__c = 'Scholarship'].Id;
    }
  
    @AuraEnabled(cacheable=true)
    public static Id getAccountId(String userID) {
        return [SELECT AccountId FROM User WHERE Id = :userID].AccountId;
    }


    @AuraEnabled(cacheable=true)
    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName)
    {
        return [SELECT Id FROM RecordType WHERE DeveloperName =:strRecordTypeName and SObjectType =: objectName].Id;
    }



    @AuraEnabled
    public static Id saveCashAccount1(FinServ__FinancialAccount__c cashAccount, String accountId ){
        Integer count = [SELECT COUNT()
                    FROM FinServ__FinancialAccount__c
                    WHERE FinServ__FinancialAccountType__c = 'Cash Account' AND FinServ__PrimaryOwner__c = :accountId];
         if(count==0){
            //try{
                insert cashAccount;
                return cashAccount.Id;     
              
            /*}catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }*/
           }
           return null;
    }

    @AuraEnabled
    public static Id saveSROAccount1(FinServ__FinancialAccount__c sroaccount, String accountId ){
        Integer count = [SELECT COUNT()
                    FROM FinServ__FinancialAccount__c
                    WHERE FinServ__FinancialAccountType__c = 'SRO' AND FinServ__PrimaryOwner__c = :accountId];
         if(count==0){
            //try{
                insert sroaccount;
                return sroaccount.Id;     
              
            /*}catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }*/
           }
           return null;
      
    }

    // @AuraEnabled
    // public static void saveFinancialAccount(FinServ__FinancialAccount__c finAcctRecord){ 

    //     try{  
    //         System.debug('In createBillingInfoApex ===> ');
    //         System.debug('Name ==> ' + finAcctRecord.Name);
    //         System.debug('FinServ__FinancialAccountNumber__c ==> ' + finAcctRecord.FinServ__FinancialAccountNumber__c);
    //         System.debug('FinServ__RoutingNumber__c ==> ' + finAcctRecord.FinServ__RoutingNumber__c);
    //         System.debug('this.finAcctRecord.RecordTypeId ==> ' + finAcctRecord.RecordTypeId);
    //         System.debug('this.accountIduser ==> ' + finAcctRecord.FinServ__PrimaryOwner__c);
    //         System.debug('this.userId ==> ' + finAcctRecord.OwnerId);

    //         FinServ__FinancialAccount__c newFinancialAccount = new FinServ__FinancialAccount__c();
    //         newFinancialAccount.Name = finAcctRecord.Name;
    //         newFinancialAccount.FinServ__FinancialAccountNumber__c = finAcctRecord.FinServ__FinancialAccountNumber__c;
    //         newFinancialAccount.FinServ__RoutingNumber__c  = finAcctRecord.FinServ__RoutingNumber__c;
    //         newFinancialAccount.RecordTypeId = finAcctRecord.RecordTypeId;
    //         newFinancialAccount.FinServ__PrimaryOwner__c  = finAcctRecord.FinServ__PrimaryOwner__c;
    //         newFinancialAccount.OwnerId = finAcctRecord.OwnerId;
    //         newFinancialAccount.FinServ__Status__c = 'Active';

    //         insert newFinancialAccount;

    //     }catch(Exception e){
    //         System.debug('--->'+e);
    //     }
      
    // }  

}