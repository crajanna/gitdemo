public without sharing class FinancialAccountController {

    @AuraEnabled
    public static FinServ__FinancialAccount__c saveFinAccount(FinServ__FinancialAccount__c obj){
        
        try {
            if(obj.Id ==null){
                insert obj;
            }else{
                update obj;
            }
            if(obj.Bank_Account_Number__c!=null){
                Integer len = obj.Bank_Account_Number__c.length();
                obj.Bank_Account_Number__c = obj.Bank_Account_Number__c.Substring(len-4, len);
            }   
        } catch (DmlException e) {
            // Process exception here
        }
        return obj;
    }

    @AuraEnabled
    public static Boolean deleteFinAccount(String recordId){
        try {
            System.debug(recordId);
            Database.DeleteResult dr = Database.delete(recordId);
            return dr.isSuccess();
        } catch (DmlException e) {
            System.debug(e.getMessage());
            return false;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getPlanBalanceByAccountId(String recordId, String planType) {
        Decimal val= 0.00;
        if(recordId!=null){
            if(planType.equalsIgnoreCase('Savings')){
                List<FinServ__FinancialAccount__c> accList = [SELECT Id, Total_Market_Value__c
                                                    FROM FinServ__FinancialAccount__c
                                                    WHERE FinServ__FinancialAccountType__c = 'Regular' AND  
                                                    FinServ__PrimaryOwner__c =:recordId AND RecordType.DeveloperName in ('InvestmentAccount') 
                                                   ];  

                  if(accList!=null && accList.size()>0){

                    for(FinServ__FinancialAccount__c item : accList ){
                        val = val+item.Total_Market_Value__c;
                    }
                      
                  }

            }
            if(planType.equalsIgnoreCase('Prepaid')){
                FinServ__FinancialAccount__c acc = [SELECT Id, Total_Prepaid_Premium__c
                                FROM FinServ__FinancialAccount__c
                                WHERE FinServ__FinancialAccountType__c = 'Cash Account' AND 
                                FinServ__PrimaryOwner__c =:recordId
                                LIMIT 1];   
                    if(acc!=null){
                       val =acc.Total_Prepaid_Premium__c;
                    }
            }
        }

        return val;                                              
    }


    @AuraEnabled(cacheable=true)
        public static Decimal getCashBalanceByAccountId(String accountId) {
        return [SELECT FinServ__CashBalance__c
                                            FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Cash Account' AND 
                                            FinServ__PrimaryOwner__c in (:accountId)
                                            LIMIT 1].FinServ__CashBalance__c;                                                    
                                    
    }


    @AuraEnabled(cacheable=true)
    public static SavingsPlanDetails getSavingsPlanDetails(String finAccId) {
       return getSavingsPlanDetails(null, null, finAccId);
    }

    @AuraEnabled(cacheable=true)
    public static SavingsPlanDetails getSavingsPlanDetails(String accountId, String beneficiaryId) {
        return getSavingsPlanDetails(accountId, beneficiaryId, null);
    }

    @AuraEnabled(cacheable=true)
    public static SavingsPlanDetails getSavingsPlanDetails(String accountId, String beneficiaryId, String finAccId) {

        SavingsPlanDetails dto = new SavingsPlanDetails();
        FinServ__FinancialAccountRole__c far =null;
        if(accountId !=null && beneficiaryId !=null){
            far =  [SELECT Id, FinServ__FinancialAccount__r.Id,  
                               FinServ__RelatedAccount__r.Id,
                               FinServ__RelatedAccount__r.PersonContact.Name,
                            FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
                            FinServ__FinancialAccount__r.FinServ__PrimaryOwner__c,
                            FinServ__FinancialAccount__r.FinServ__PrimaryOwner__r.PersonContact.Name,
                            FinServ__FinancialAccount__r.Total_Market_Value__c,
                            FinServ__FinancialAccount__r.Open_Date__c,
                            FinServ__FinancialAccount__r.FinServ__FinancialAccountType__c  
                            FROM 
                            FinServ__FinancialAccountRole__c WHERE FinServ__Active__c = true and 
                            FinServ__Role__c = 'Beneficiary' and 
                            FinServ__FinancialAccount__r.RecordType.DeveloperName ='InvestmentAccount' and
                            FinServ__FinancialAccount__r.FinServ__PrimaryOwner__c =:accountId and
                            FinServ__RelatedAccount__r.Id =:beneficiaryId ];
        }
        else if(finAccId!=null){
            far =  [SELECT Id, FinServ__FinancialAccount__r.Id, 
                               FinServ__RelatedAccount__r.Id,
                               FinServ__RelatedAccount__r.PersonContact.Name,
                                FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
                                FinServ__FinancialAccount__r.FinServ__PrimaryOwner__c,
                                FinServ__FinancialAccount__r.FinServ__PrimaryOwner__r.PersonContact.Name,
                                FinServ__FinancialAccount__r.Total_Market_Value__c,
                                FinServ__FinancialAccount__r.Open_Date__c,
                                FinServ__FinancialAccount__r.FinServ__FinancialAccountType__c   
                                FROM 
                                FinServ__FinancialAccountRole__c WHERE FinServ__Active__c = true and 
                                FinServ__Role__c = 'Beneficiary' and 
                                FinServ__FinancialAccount__r.RecordType.DeveloperName ='InvestmentAccount' and
                                FinServ__FinancialAccount__r.Id =: finAccId ];
        }
            if(far != null){
                dto.faRoleId = far.Id;
                dto.faId = far.FinServ__FinancialAccount__r.Id;
                dto.faNumber = far.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c;
                dto.accountOwner = far.FinServ__FinancialAccount__r.FinServ__PrimaryOwner__c;
                dto.accountOwnerName = far.FinServ__FinancialAccount__r.FinServ__PrimaryOwner__r.PersonContact.Name;
                dto.currentBalance = far.FinServ__FinancialAccount__r.Total_Market_Value__c;
                dto.nextPayment = Date.newInstance(2022, 1, 1);
                dto.openDate = far.FinServ__FinancialAccount__r.Open_Date__c;
                dto.accountType = far.FinServ__FinancialAccount__r.FinServ__FinancialAccountType__c;
                BeneficiaryDetail  bd = new BeneficiaryDetail();
                bd.Id = far.FinServ__RelatedAccount__r.Id;
                bd.Name = far.FinServ__RelatedAccount__r.PersonContact.Name;
                dto.beneficiary = bd;

                FinServ__FinancialAccountRole__c far1 =   [SELECT FinServ__RelatedAccount__r.Id,
                                FinServ__RelatedAccount__r.PersonContact.Name
                                FROM 
                                FinServ__FinancialAccountRole__c WHERE FinServ__Active__c = true and 
                                FinServ__Role__c = 'Survivor'  and 
                                FinServ__FinancialAccount__r.RecordType.DeveloperName ='InvestmentAccount' AND
                                FinServ__FinancialAccount__r.Id =: dto.faId];
                    if(far1 !=null){
                        Survivor  sr = new Survivor();
                        sr.Id = far1.FinServ__RelatedAccount__r.Id;
                        sr.Name = far1.FinServ__RelatedAccount__r.PersonContact.Name;
                        dto.survivor = sr;
                    }

            }
            return dto;                 
        }


     public class SavingsPlanDetails {
        
        @AuraEnabled
        public String faRoleId;
        @AuraEnabled
        public String faId;
        @AuraEnabled
        public String faNumber;
        @AuraEnabled
        public String accountOwner;
        @AuraEnabled
        public String accountOwnerName;
        @AuraEnabled
        public Decimal currentBalance;
        @AuraEnabled
        public Date nextPayment;
        @AuraEnabled
        public Survivor survivor;
        @AuraEnabled
        public BeneficiaryDetail beneficiary;
        @AuraEnabled
        public Date openDate;
        @AuraEnabled
        public String accountType;

    }

    public class Survivor {
        
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;


    }


    @AuraEnabled(cacheable=true)
    public static List<BeneficiaryDetail> getBeneficiaryList(String accountId) {
        List<FinServ__FinancialAccountRole__c> farList =  [SELECT FinServ__RelatedAccount__r.Id, 
                                                            FinServ__FinancialAccount__r.Id,
                                                            FinServ__FinancialAccount__r.Name,
                                                            FinServ__RelatedAccount__r.PersonContact.Name,
                                                            FinServ__RelatedAccount__r.PersonBirthdate,
                                                            FinServ__FinancialAccount__r.Total_Market_Value__c
                                                            FROM 
                                                            FinServ__FinancialAccountRole__c 
                                                             WHERE FinServ__Active__c = true and 
                                                        FinServ__Role__c = 'Beneficiary' and 
                                                        FinServ__FinancialAccount__r.RecordType.DeveloperName ='InvestmentAccount' and
                                                        FinServ__FinancialAccount__r.FinServ__PrimaryOwner__c =:accountId ];

        List<BeneficiaryDetail> beneficiaryList = new List<BeneficiaryDetail>(); 

        for(FinServ__FinancialAccountRole__c item: farList){
            BeneficiaryDetail bd = new BeneficiaryDetail();
            bd.id = item.FinServ__RelatedAccount__r.Id;
            bd.finAccountId = item.FinServ__FinancialAccount__r.Id;
            bd.finAccountName = item.FinServ__FinancialAccount__r.Name;
            bd.name = item.FinServ__RelatedAccount__r.PersonContact.Name;
            bd.dob = item.FinServ__RelatedAccount__r.PersonBirthdate;
            bd.savingsamount = item.FinServ__FinancialAccount__r.Total_Market_Value__c;
            beneficiaryList.add(bd);
        }
        return beneficiaryList;
    }


    public class BeneficiaryDetail {        
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String finAccountId;
        @AuraEnabled
        public String finAccountName;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Date dob;
        @AuraEnabled
        public Decimal savingsamount;
    }


    @AuraEnabled(cacheable=true)
    public static List<FinAccTransactionDetail> getFinAccTransations(String financialAccountId) {
        List<FinServ__FinancialAccountTransaction__c> fatList =  [SELECT Id, Name, FinServ__TransactionType__c, FinServ__TransactionDate__c, FinServ__Amount__c,  FinServ__TransactionStatus__c, Source_Type__c from
                                        FinServ__FinancialAccountTransaction__c
                                    WHERE 
                                        FinServ__FinancialAccount__c= :financialAccountId and
                                        FinServ__TransactionType__c in ( 'Credit','Debit') and
                                        FinServ__TransactionSubtype__c in ('Transfer In','Transfer Out')];

        List<FinAccTransactionDetail> fatdList = new List<FinAccTransactionDetail>(); 

        for(FinServ__FinancialAccountTransaction__c item: fatList){
            FinAccTransactionDetail bd = new FinAccTransactionDetail();
            bd.id = item.Id;
            bd.name = item.Name;
            bd.type = item.FinServ__TransactionType__c;
            bd.tdate = item.FinServ__TransactionDate__c;
            bd.amount = item.FinServ__Amount__c;
            bd.status = item.FinServ__TransactionStatus__c;
            bd.sourceType = item.Source_Type__c;
            fatdList.add(bd);
        }
          return fatdList;
    }


    public class FinAccTransactionDetail {        
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Datetime tdate;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String sourceType;
    }


    @AuraEnabled(cacheable=true)
    public static BeneficiaryDetail getBeneficiary(String finAcctId){
        try {
            FinServ__FinancialAccountRole__c far =   [SELECT FinServ__RelatedAccount__r.Id,
                                            FinServ__RelatedAccount__r.PersonContact.Name
                                            FROM 
                                            FinServ__FinancialAccountRole__c WHERE FinServ__Active__c = true and 
                                            FinServ__Role__c = 'Beneficiary'  and 
                                            FinServ__FinancialAccount__r.RecordType.DeveloperName ='InvestmentAccount' AND
                                            FinServ__FinancialAccount__r.Id =:finAcctId];

              BeneficiaryDetail bd = new BeneficiaryDetail();
              if(far != null){
                bd.id = far.FinServ__RelatedAccount__r.Id;
                bd.name = far.FinServ__RelatedAccount__r.PersonContact.Name;
              }
              return bd;
             
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    // @AuraEnabled
    // public static string getBeneficiaryTotalContributions(String accountId){
    //     try {
    //         FinServ__FinancialAccountRole__c role = [SELECT FinServ__FinancialAccount__r.Total_Market_Value__c
    //                                                     FROM  FinServ__FinancialAccountRole__c 
    //                                                     WHERE FinServ__Active__c = true and 
    //                                                     FinServ__Role__c = 'Beneficiary' and 
    //                                                     FinServ__FinancialAccount__r.RecordType.DeveloperName ='InvestmentAccount' and
    //                                                     FinServ__FinancialAccount__r.FinServ__PrimaryOwner__c =:accountId and
    //                                                     FinServ__RelatedAccount__r.Id =:beneficiaryId ]
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }


    @AuraEnabled
    public static Id saveAddFunds(Transfer_Fund__c tranfund, FinServ__FinancialAccount__c bankAccount  ){
        System.debug('tranfund..');

        if(tranfund.Source_Type__c.equalsIgnoreCase('ACH')){
              System.debug('tranfund..'+tranfund.RecordTypeId);
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

    @AuraEnabled(cacheable=true)
    public static List<FinServ__FinancialAccount__c > getFinancialAccountsByAccountId(String accountId) {
        List<FinServ__FinancialAccount__c> items = [SELECT Id, Name, Bank_Account_Number__c, FinServ__FinancialAccountNumber__c, FinServ__FinancialAccountType__c,
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


    @AuraEnabled(cacheable=true)
    public static List<FinServ__FinancialAccountRole__c> getFinancialAccountRolesById(String finAcctId){
        try {

            List<FinServ__FinancialAccountRole__c> farList =  [SELECT Id, FinServ__RelatedAccount__r.Id, FinServ__RelatedAccount__r.name,        
                                                                 FinServ__Role__c, FinServ__FinancialAccount__r.name  FROM 
                                                                FinServ__FinancialAccountRole__c WHERE FinServ__Active__c = true and 
                                                                FinServ__FinancialAccount__r.RecordType.DeveloperName ='InvestmentAccount' AND
                                                                FinServ__FinancialAccount__r.Id =:finAcctId];
            return farList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Id getCashAccountIdByFinAccountId(String finAcctId) {
        if(finAcctId!=null){
            System.debug('finAcctId......'+finAcctId);
            BeneficiaryDetail bd = getBeneficiary(finAcctId);
            System.debug('bd.id......'+bd.id);

            if(bd!=null){
                return getCashAccountIdByAccount(Id.valueOf(bd.id));
            }
        }
        return null;       
    }

    @AuraEnabled(cacheable=true)
    public static Id getCashAccountIdByAccount(String accountId) {
        return [SELECT Id FROM FinServ__FinancialAccount__c
                                            WHERE FinServ__FinancialAccountType__c = 'Cash Account' AND 
                                            FinServ__PrimaryOwner__c in (:accountId) Limit 1].Id;
    }

}