public without sharing class FoundationContractController {


     
//  @AuraEnabled
//  public static Id saveContractAccount(Contract contract, 
//                                     Transfer_Fund__c tranfund, 
//                                     Transfer_Fund__c achTranFund, 
//                                     FinServ__FinancialAccount__c finaccount,
//                                     String mode ){

//     try{
//         System.debug('step1..');  
//         upsert contract;    
//         System.debug('step2..'+contract.Id);      
//         tranfund.Contract__c = contract.Id;
//         insert tranfund;
//         System.debug('step3..'+tranfund.Id);      
//         if(mode.equals('ACH')){
//             if(achTranFund.Financial_Account_Cash__c ==null){
//                 insert finaccount;
//                 achTranFund.Financial_Account_Cash__c = finaccount.Id;
//                }        
//             achTranFund.Contract__c = contract.Id;
//             insert achTranFund;
//         }
//         System.debug('step4..'+tranfund.Id);      

//         return tranfund.Id;
//     }catch(Exception e){
//         throw new AuraHandledException(e.getMessage());
//     }
//  }

//  @AuraEnabled
//  public static Id savePledgeDetailsPP(Contract contract, 
//                                       Transfer_Fund__c tranfund, 
//                                       String mode ){
    
//         upsert contract;    
//         if(mode.equals('Now')){
//             tranfund.Contract__c = contract.Id;
//             insert tranfund;

//             if(tranfund.Source_Type__c.equalsIgnoreCase('Paypal')){
//                 Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
//                 String skey = 'PAYPAL'+tranfund.Account__c;
//                 sessionPart.remove(skey);
//                 sessionPart.put(skey, tranfund.Id);
//             }

//             return tranfund.Id;
//         }else{
//             return contract.Id;
//         }     
 
//  }

@AuraEnabled
public static Id savePledgeDetails(Contract contract, 
                                     Transfer_Fund__c tranfund, 
                                     String mode,
                                     FinServ__FinancialAccount__c bankAccount ){
       System.debug('savePledgeDetails..');
       upsert contract;    
       if(mode.equals('Now')){                      

           if(tranfund.Source_Type__c.equalsIgnoreCase('Paypal')){
               Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
               String skey = 'PAYPAL'+tranfund.Account__c;

           if (sessionPart.contains(skey)) {
               sessionPart.remove(skey);                
           }
           Cache.Session.put(skey, new FpPayPalCachedData(Id.valueOf(contract.Id), 
                                                 String.valueOf(tranfund.Transfer_Amount__c), 
                                                 String.valueOf(tranfund.Fee__c),
                                                 'Pledge'
                                                 ));
           return contract.Id;

           }else if(tranfund.Source_Type__c.equalsIgnoreCase('ACH')){
               tranfund.Contract__c = contract.Id;
               tranfund.Source_Type__c = 'Cash Account';
               insert tranfund;               
               System.debug('tranfund..'+tranfund.Id);
               if(bankAccount.Id==null){
                   FinServ__FinancialAccount__c newBankAccount = new FinServ__FinancialAccount__c();
                   newBankAccount.Name = bankAccount.Name;
                   newBankAccount.Bank_Account_Number__c = bankAccount.FinServ__FinancialAccountNumber__c;
                   newBankAccount.FinServ__RoutingNumber__c  = bankAccount.FinServ__RoutingNumber__c;
                   newBankAccount.FinServ__FinancialAccountType__c = bankAccount.FinServ__FinancialAccountType__c;
                   newBankAccount.RecordTypeId = CreateFinancialAccount.getRecordTypeIdbyName('FinServ__FinancialAccount__c', 'BankingAccount');
                   newBankAccount.FinServ__PrimaryOwner__c  = tranfund.Account__c;
                   newBankAccount.OwnerId = UserInfo.getUserId();
                   newBankAccount.FinServ__Status__c = 'Active';
                   insert newBankAccount;
                   bankAccount.Id = newBankAccount.Id;
               }
               System.debug('bankAccount.Id..'+bankAccount.Id);
               Transfer_Fund__c achTranfund = new Transfer_Fund__c();
               achTranfund.RecordTypeId = CreateFinancialAccount.getRecordTypeIdbyName('Transfer_Fund__c', 'Contribution');
               achTranfund.Financial_Account_Cash__c = bankAccount.Id;
               achTranfund.Financial_Account_Investment__c = CreateFinancialAccount.getCashAccountIdByAccount(tranfund.Account__c);
               achTranfund.Source_Type__c = 'ACH';
               achTranfund.Transfer_Amount__c =  tranfund.Transfer_Amount__c;
               achTranfund.Fee__c = tranfund.Fee__c;
               achTranfund.Status__c = 'Queued';
               achTranfund.Frequency__c  =  'One-Time';
               achTranfund.Contact__c  =  tranfund.Contact__c;
               achTranfund.Account__c  =  tranfund.Account__c;
               achTranfund.Contract__c = contract.Id;
               insert achTranfund;
               System.debug('achTranfund.Id..'+achTranfund.Id);
               return tranfund.Id;
            }else if(tranfund.Source_Type__c.equalsIgnoreCase('Check')){
                tranfund.Contract__c = contract.Id;
                tranfund.Source_Type__c = 'Check';
                insert tranfund;  
                
                Transfer_Fund__c cTranfund = new Transfer_Fund__c();
                cTranfund.RecordTypeId = CreateFinancialAccount.getRecordTypeIdbyName('Transfer_Fund__c', 'Contribution');
                cTranfund.Financial_Account_Investment__c = CreateFinancialAccount.getCashAccountIdByAccount(tranfund.Account__c);
                cTranfund.Source_Type__c = 'Check';
                cTranfund.Transfer_Amount__c =  tranfund.Transfer_Amount__c;
                cTranfund.Fee__c = tranfund.Fee__c;
                cTranfund.Status__c = 'Queued';
                cTranfund.Frequency__c  =  'One-Time';
                cTranfund.Contact__c  =  tranfund.Contact__c;
                cTranfund.Account__c  =  tranfund.Account__c;
                cTranfund.Contract__c = contract.Id;
                insert cTranfund;
                return tranfund.Id;
            }
           else{
               tranfund.Contract__c = contract.Id;
               insert tranfund;
               return tranfund.Id;
           }
          
       }else{
           return contract.Id;
       }     
}


 @AuraEnabled
 public static Id saveAddFundsDetails(Transfer_Fund__c tranfund, FinServ__FinancialAccount__c bankAccount  ){
        
        if(tranfund.Source_Type__c.equalsIgnoreCase('Paypal')){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
            String skey = 'PAYPAL'+tranfund.Account__c;

        if (sessionPart.contains(skey)) {
            sessionPart.remove(skey);                
        }
        Cache.Session.put(skey, new FpPayPalCachedData('', 
                                              String.valueOf(tranfund.Transfer_Amount__c), 
                                              String.valueOf(tranfund.Fee__c),
                                              'Contribution'
                                              ));
        return null;

        }else if(tranfund.Source_Type__c.equalsIgnoreCase('ACH')){
           System.debug('tranfund..'+tranfund.Id);
           if(bankAccount.Id==null){
               FinServ__FinancialAccount__c newBankAccount = new FinServ__FinancialAccount__c();
               newBankAccount.Name = bankAccount.Name;
               newBankAccount.Bank_Account_Number__c = bankAccount.FinServ__FinancialAccountNumber__c;
               newBankAccount.FinServ__RoutingNumber__c  = bankAccount.FinServ__RoutingNumber__c;
               newBankAccount.FinServ__FinancialAccountType__c = bankAccount.FinServ__FinancialAccountType__c;
               newBankAccount.RecordTypeId = CreateFinancialAccount.getRecordTypeIdbyName('FinServ__FinancialAccount__c', 'BankingAccount');
               newBankAccount.FinServ__PrimaryOwner__c  = tranfund.Account__c;
               newBankAccount.OwnerId = UserInfo.getUserId();
               newBankAccount.FinServ__Status__c = 'Active';
               insert newBankAccount;
               bankAccount.Id = newBankAccount.Id;
           }
           tranfund.Financial_Account_Cash__c = bankAccount.Id;
           insert tranfund;              
       }
        else{
            insert tranfund;
        }
        
        return tranfund.Id;       
    
 }

 @AuraEnabled()
 public static Id createTransferFundsData(String extId, String type){

    Id userId = UserInfo.getUserId();
    User user = [SELECT AccountId, ContactId FROM User WHERE Id = :userId];
    Integer count = [SELECT COUNT() from Transfer_Fund__c t 
                             where t.Source_Type__c ='Paypal' 
                             and t.External_Transaction_Id__c=:extId
                            // and t.Account__c = :user.AccountId
                             and t.Status__c='Complete' ];
    if(count==0){      
        String pkey = 'PAYPAL'+user.AccountId; 

        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
        if (sessionPart.contains(pkey)) {               
      
        FpPayPalCachedData data = (FpPayPalCachedData)sessionPart.get(pkey);
        sessionPart.remove(pkey);
        Transfer_Fund__c tranfund = new Transfer_Fund__c();
        
        tranfund.External_Transaction_Id__c = extId; 
        tranfund.Status__c = 'Complete';
        if(type.equalsIgnoreCase('Pledge')){

            Transfer_Fund__c pTranfund = new Transfer_Fund__c();
            pTranfund.RecordTypeId = CreateFinancialAccount.getRecordTypeIdbyName('Transfer_Fund__c', 'Contribution');
            pTranfund.Financial_Account_Investment__c = CreateFinancialAccount.getCashAccountIdByAccount(user.AccountId);
            pTranfund.Source_Type__c = 'Paypal';
            pTranfund.Transfer_Amount__c =  Decimal.ValueOf(data.transferAmount);
            pTranfund.Fee__c = Decimal.ValueOf(data.fee).setScale(2);
            pTranfund.Status__c = 'Complete';
            pTranfund.Frequency__c  =  'One-Time';
            pTranfund.Contact__c  =  user.ContactId;
            pTranfund.Account__c  =  user.AccountId;
            pTranfund.Contract__c = data.contractId;
            insert pTranfund;


            tranfund.Contract__c = data.contractId;
            tranfund.RecordTypeId = CreateFinancialAccount.getRecordTypeIdbyName('Transfer_Fund__c', 'Pledge');
            tranfund.Financial_Account_Cash__c = CreateFinancialAccount.getCashAccountIdByAccount(user.AccountId);
            tranfund.Financial_Account_Investment__c = CreateFinancialAccount.getScholarshipFinAccount();

        }else{
            tranfund.RecordTypeId = CreateFinancialAccount.getRecordTypeIdbyName('Transfer_Fund__c', 'Contribution');
            tranfund.Financial_Account_Investment__c = CreateFinancialAccount.getCashAccountIdByAccount(user.AccountId);

        }
        tranfund.Source_Type__c = 'Paypal';
        tranfund.Transfer_Amount__c = Decimal.ValueOf(data.transferAmount);
        tranfund.Fee__c = Decimal.ValueOf(data.fee).setScale(2);
        tranfund.Frequency__c = 'One-Time';
        tranfund.Contact__c = user.ContactId;
        tranfund.Account__c = user.AccountId;

        insert tranfund;
        return tranfund.Id;
     }
    } 
    return null;                       
 }

 @AuraEnabled(cacheable=true)
 public static Transfer_Fund__c getTransferFundsData(String transferFundId){
    Transfer_Fund__c data = [select Transfer_Amount__c, Account__c, Fee__c, RecordType.DeveloperName,    
                                Contract__r.Pledge__c, 
                                Contract__r.Product__r.Name,
                                Contract__r.Product__r.Description,
                                Contract__r.Product__r.DisplayUrl,
                                Contract__r.Product__r.Pledge_Image__c,
                                Contract__r.Product__r.spotlight__c,
                                Contract__r.Product__r.Learn_More_URL__c,
                                Contract__r.Product__r.Did_You_Know__c
    FROM Transfer_Fund__c t where t.Id = :transferFundId];
    return data;
 }
 
 @AuraEnabled(cacheable=true)
 public static Contract getPledgeData(String contractId){
        Contract data = [SELECT  Pledge__c,
                         Product__r.Name,
                         Product__r.ProductCode,
                         Product__r.Description,
                         Product__r.DisplayUrl,
                         Product__r.Pledge_Image__c,
                         Product__r.spotlight__c,
                         Product__r.Learn_More_URL__c,
                         Product__r.Did_You_Know__c
                         FROM Contract t where t.Id in (:contractId)];
        return data;   
 }

  
 @AuraEnabled(cacheable=true)
 public static Transfer_Fund__c getContractData(String transferFundId){    
        Transfer_Fund__c data = [select id , Transfer_Amount__c, Account__c, Fee__c, RecordType.DeveloperName, Contract__r.Pledge__c ,Contract__r.Product__r.Name from Transfer_Fund__c t where t.Id = :transferFundId];
        return data;  
 }


 @AuraEnabled
 public static void removeSessionCache(String accId){    
    Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
    String skey = 'PAYPAL'+accId;
    sessionPart.remove(skey);   
 }


}