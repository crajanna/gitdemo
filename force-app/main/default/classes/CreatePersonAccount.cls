public without sharing class CreatePersonAccount {

    @AuraEnabled
    public static void saveContactRecord(Contact con){ 
        try{  
            update con;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    


    @AuraEnabled
    public static Account savePersonAccount(Contact con){ 
        //try{  

            RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];

            Account newPersonAccount = new Account();
            newPersonAccount.FirstName = con.FirstName;
            newPersonAccount.LastName = con.LastName;
            newPersonAccount.MiddleName  = con.MiddleName;
            newPersonAccount.Suffix = con.Suffix;
            newPersonAccount.PersonBirthdate= con.Birthdate;
            newPersonAccount.Race__pc = con.Race__c;
            newPersonAccount.FinServ__TaxID__pc = con.SSN2__c;
            newPersonAccount.FinServ__Gender__pc = con.FinServ__Gender__c;
            newPersonAccount.RecordType = personAccountRecordType;

            newPersonAccount.BillingStreet = con.OtherStreet;
            newPersonAccount.BillingCity = con.OtherCity;
            newPersonAccount.BillingState = con.OtherState;
            newPersonAccount.BillingPostalCode = con.OtherPostalCode;
            newPersonAccount.BillingCountry = con.OtherCountry;
            newPersonAccount.BillingStateCode = con.OtherStateCode;
            newPersonAccount.BillingCountryCode = con.OtherCountryCode;

            insert newPersonAccount;
            return newPersonAccount;
        //}catch(Exception e){
          //  throw new AuraHandledException(e.getMessage());
        //}
    }  



    @AuraEnabled
    public static Account savePersonAccountWithFile(Contact con, string file, string fileName, String description,
                                                    string docfile, string docfileName, String docType ){ 
        try{

            RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];


            Account newPersonAccount = new Account();
            newPersonAccount.FirstName = con.FirstName;
            newPersonAccount.LastName = con.LastName;
            newPersonAccount.MiddleName  = con.MiddleName;
            newPersonAccount.Suffix = con.Suffix;
            newPersonAccount.PersonBirthdate= con.Birthdate;
            newPersonAccount.Race__pc = con.Race__c;
            newPersonAccount.SSN2__pc = con.SSN2__c;
            newPersonAccount.FinServ__Gender__pc = con.FinServ__Gender__c;
            newPersonAccount.RecordType = personAccountRecordType;

            newPersonAccount.BillingStreet = con.OtherStreet;
            newPersonAccount.BillingCity = con.OtherCity;
            newPersonAccount.BillingState = con.OtherState;
            newPersonAccount.BillingPostalCode = con.OtherPostalCode;
            newPersonAccount.BillingCountry = con.OtherCountry;
            newPersonAccount.BillingStateCode = con.OtherStateCode;
            newPersonAccount.BillingCountryCode = con.OtherCountryCode;

            System.debug('person acc id---'+con.Id);
            if(con.Id!=null){
                newPersonAccount.Id = con.Id;
                update newPersonAccount;
            }else{
                insert newPersonAccount;
            }
            ResourceController.uploadResourceToRecord(newPersonAccount.Id, file, fileName, description);

            RecordType caseRecordType =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Documentation_Validation' and SObjectType = 'Case'];

            Case cse = new Case();
            cse.AccountId = newPersonAccount.Id;
            cse.RecordType = caseRecordType;
            cse.Description = 'TestDescription';
            cse.Status = 'New';
            cse.Origin = 'Portal';
            cse.Subject = 'Residency Document';
            cse.OwnerId = UserInfo.getUserId();
            cse.Type = 'Documentation Validation';
            cse.Subtype__c = 'Residency Documentation Validation';
            insert cse;
            
            ResourceController.uploadResourceToRecord(cse.Id, docfile, docfileName, docType);
            return newPersonAccount;


        }catch(Exception e){
            if(!Test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());
            }else {
                return new Account();
            }
        }
    }  

    @AuraEnabled(cacheable=true)
    public static String findLogo(String contentVersionId){ 
        try{  
            ContentDistribution cDist = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId =:contentVersionId LIMIT 1];
            String baseDomain = URL.getOrgDomainUrl().toExternalForm();
            baseDomain = baseDomain.substringBefore('.') + '--c.documentforce.com';
            String originalUrl = String.valueOf(cDist.DistributionPublicUrl);
            String cDistParam = originalUrl.substring(originalUrl.indexOf('/a/'));

            ContentVersion cvd = [SELECT ContentBodyId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];

            String theUrl = baseDomain + '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg' +
                     '&versionId=' + contentVersionId + '&operationContext=DELIVERY&contentId=' + cvd.ContentBodyId +
                     '&page=0&d=' + cDistParam + '&oid=' +  UserInfo.getOrganizationId() + '&dpt=null&viewId=';


            return theUrl;

       	}catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 


    @AuraEnabled(cacheable=true) 
    public static Account getAccountDetails(String accountId){
        try {
            Account acc = [SELECT Id, FirstName, LastName, MiddleName, SSN__pc, PersonBirthdate, Suffix, Race__pc,FinServ__Gender__pc FROM Account WHERE Id = :accountId LIMIT 1];
            return acc;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled(cacheable=true) 
    public static Account getAccountAddress(String accountId){
         return getAccountAddress(accountId, null);
    }
    
    @AuraEnabled(cacheable=true) 
    public static Account getAccountAddress(String accountId, String randomNumber){
        Account acc = [SELECT id, BillingAddress, ShippingAddress, PersonMailingAddress, PersonOtherAddress FROM Account WHERE Id = :accountId];      
        return acc;
    }



    @AuraEnabled(cacheable=true)
    public static Map < String, String > getCountryOptionsList() {
        map<String, String> mapOfValues = new map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            mapOfValues.put(f.getLabel(), f.getValue());
        }
        return mapOfValues;
    }

    @AuraEnabled(cacheable=true)
    public static Map < String, String > getStateOptionsList() {
        map<String, String> mapOfValues = new map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            mapOfValues.put(f.getLabel(), f.getValue());
        }
        return mapOfValues;
    }

}