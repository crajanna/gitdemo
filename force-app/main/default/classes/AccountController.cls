public without sharing class AccountController {


      @AuraEnabled
      public static Account saveAccountDetails(Contact con, String studentInterest, String profileData, String resVerificationData){
        //try{

            RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];

            Account newPersonAccount = new Account();
            newPersonAccount.RecordType = personAccountRecordType;
            newPersonAccount.FirstName = con.FirstName;
            newPersonAccount.LastName = con.LastName;
            newPersonAccount.MiddleName  = con.MiddleName;
            newPersonAccount.Suffix = con.Suffix;
            newPersonAccount.Race__pc = con.Race__c;
            newPersonAccount.SSN2__pc = con.SSN2__c;
            newPersonAccount.FinServ__Gender__pc = con.FinServ__Gender__c;
			
            if(con.phone!=null){
                newPersonAccount.Phone =con.Phone;
            }
            if(con.Birthdate!=null){
               newPersonAccount.PersonBirthdate= con.Birthdate;
            }
            if(con.Email!=null){
                newPersonAccount.PersonEmail = con.Email;
            }


            /*newPersonAccount.BillingStreet = con.OtherStreet;
            newPersonAccount.BillingCity = con.OtherCity;
            newPersonAccount.BillingState = con.OtherState;
            newPersonAccount.BillingPostalCode = con.OtherPostalCode;
            newPersonAccount.BillingCountry = con.OtherCountry;
            newPersonAccount.BillingStateCode = con.OtherStateCode;
            newPersonAccount.BillingCountryCode = con.OtherCountryCode;*/
            
            if(con.OtherStreet != null ){
                newPersonAccount.BillingStreet = con.OtherStreet;
            }
            if(con.OtherCity != null ){
                newPersonAccount.BillingCity = con.OtherCity;
            }
            if(con.OtherState != null ){
                newPersonAccount.BillingState = con.OtherState;
            }
            if(con.OtherPostalCode != null ){
                newPersonAccount.BillingPostalCode = con.OtherPostalCode;
            }
            if(con.OtherCountry != null ){
                newPersonAccount.BillingCountry = con.OtherCountry;
            }
            if(con.OtherStateCode != null ){
                newPersonAccount.BillingStateCode = con.OtherStateCode;
            }
            if(con.OtherCountryCode != null ){
                newPersonAccount.BillingCountryCode = con.OtherCountryCode;
            }


            Map<String, Object> studentInterestData = (Map<String, Object>)JSON.deserializeUntyped(studentInterest);
              
            if(String.valueOf(studentInterestData.get('Favorite_Subject__c')) !=null){
                newPersonAccount.Favorite_Subject__pc =  String.valueOf(studentInterestData.get('Favorite_Subject__c'));
            }
            if(String.valueOf(studentInterestData.get('Interests__c')) !=null){
                newPersonAccount.Interests__pc =  String.valueOf(studentInterestData.get('Interests__c'));
            }
            if(String.valueOf(studentInterestData.get('Organization__c')) !=null){
                newPersonAccount.Organization__pc =  String.valueOf(studentInterestData.get('Organization__c'));
            }
            if(String.valueOf(studentInterestData.get('Goals__c')) !=null){
                newPersonAccount.Goals__pc =  String.valueOf(studentInterestData.get('Goals__c'));
            }

          
            System.debug('person acc id---'+con.Id);
            if(con.Id!=null){
                newPersonAccount.Id = con.Id;
                update newPersonAccount;
            }else{
                insert newPersonAccount;
            }

            Map<String, Object> profileDataMap = (Map<String, Object>)JSON.deserializeUntyped(profileData);
            if(String.valueOf(profileDataMap.get('file')) !=null){
                ResourceController.uploadResourceToRecord(newPersonAccount.Id,
                String.valueOf(profileDataMap.get('file')), 
                String.valueOf(profileDataMap.get('fileName')), 
                String.valueOf(profileDataMap.get('description')) 
                );
            }
            
          
            

            Map<String, Object> resVerificationDataMap = (Map<String, Object>)JSON.deserializeUntyped(resVerificationData);
            if(String.valueOf(resVerificationDataMap.get('file')) !=null){

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

                ResourceController.uploadResourceToRecord(cse.Id,
                                                            String.valueOf(resVerificationDataMap.get('file')), 
                                                            String.valueOf(resVerificationDataMap.get('fileName')), 
                                                            String.valueOf(resVerificationDataMap.get('docType')) 
                                                            );
            }
            

            return newPersonAccount;


        //}catch(Exception e){
            //throw new AuraHandledException(e.getMessage());
        //}
      }

      @AuraEnabled(cacheable=true) 
      public static Account getAccountInfo(String accountId){
         return getAccountInfo(accountId, null);
      }
    
      @AuraEnabled(cacheable=true) 
      public static Account getAccountInfo(String accountId, String randomNumber){
          try {
              Account acc = [SELECT Id, FirstName, LastName, MiddleName, SSN2__pc, PersonBirthdate, PersonEmail, Suffix, Race__pc,FinServ__Gender__pc, Favorite_Subject__pc,  Interests__pc, Account.Organization__pc, Account.Goals__pc  FROM Account WHERE Id = :accountId LIMIT 1];
              return acc;
              
          } catch (Exception e) {
              throw new AuraHandledException(e.getMessage());
          }
      } 


      @AuraEnabled
      public static void createAccountAccountRelationShip(String accountId, String relatedAccountId, String reciprocalRole){ 

                Boolean result = isAccountRelationShipExist(accountId, UserInfo.getUserId(), relatedAccountId, reciprocalRole  );
          		
                if(!result){
                    FinServ__ReciprocalRole__c reciprocalRoleObj =  [select Id, Name from FinServ__ReciprocalRole__c where name = :reciprocalRole];   
                    FinServ__AccountAccountRelation__c relatedAccount = new FinServ__AccountAccountRelation__c();
                    relatedAccount.FinServ__Account__c = accountId;
                    relatedAccount.FinServ__RelatedAccount__c = relatedAccountId;
                    relatedAccount.FinServ__Active__c = true;
                    relatedAccount.FinServ__Role__c = reciprocalRoleObj.Id;
                    relatedAccount.OwnerId = UserInfo.getUserId();
                    insert relatedAccount;
                    System.debug('relatedAccount id = >'+relatedAccount.id);
                 }             
      
      }

      @AuraEnabled(cacheable=true)
      public static List<AccountRelationshipWrapper> getAccountRelationShipDetails(String relatedAccountId, String reciprocalRole){ 
        return getAccountRelationShipDetails(relatedAccountId, reciprocalRole, null);
    }
      @AuraEnabled(cacheable=true)
      public static List<AccountRelationshipWrapper> getAccountRelationShipDetails(String relatedAccountId, String reciprocalRole, String randomNumber){      
        List<AccountRelationshipWrapper> arList = new List<AccountRelationshipWrapper>();


                  FinServ__ReciprocalRole__c reciprocalRoleObj =  [select Id, Name from FinServ__ReciprocalRole__c where name = :reciprocalRole];      

                  List<FinServ__AccountAccountRelation__c> accRelationList = [SELECT Id, FinServ__Role__c, FinServ__Account__r.Id, FinServ__Account__r.Name, FinServ__Account__r.PersonBirthdate FROM 
                                                             FinServ__AccountAccountRelation__c  WHERE FinServ__Role__c = :reciprocalRoleObj.Id 
                                                             and FinServ__Active__c = true
                                                             and OwnerId =: UserInfo.getUserId()
                                                             and FinServ__RelatedAccount__c =: relatedAccountId];

                  for(FinServ__AccountAccountRelation__c item: accRelationList){
                    // Integer sInteger  = Integer.valueof((Math.random() * 100));
          			// String randomNumber = String.valueOf(sInteger);
          			String profilePicUrl = FpDashboardController.findImageByRecord(item.FinServ__Account__r.Id, randomNumber, 'Profile_Logo' );
                    
                    AccountRelationshipWrapper dto = new AccountRelationshipWrapper();
                    dto.Id = item.Id;
                    dto.role = item.FinServ__Role__c;
                    dto.relationshipAccountId = item.FinServ__Account__r.Id;
                    dto.relationshipAccountName = item.FinServ__Account__r.Name;
                    dto.Id = item.Id;
                    dto.dob = item.FinServ__Account__r.PersonBirthdate;
                    dto.profilePicURL = profilePicUrl;
                    arList.add(dto);
                  }
                 return arList;
            }

      public class AccountRelationshipWrapper {
        
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String role;
        @AuraEnabled
        public String relationshipAccountId;
        @AuraEnabled
        public String relationshipAccountName;
        @AuraEnabled
        public Date dob;
        @AuraEnabled
        public String profilePicURL;
       
    }

    @AuraEnabled(cacheable=true)
    public static Id getAccountId(String userID) {
        return [SELECT AccountId FROM User WHERE Id = :userID].AccountId;
    }


    @AuraEnabled
    public static Boolean isAccountRelationShipExist(String accountId, String userId, String relatedAccountId, String reciprocalRole){ 

            Boolean result = false;
			  FinServ__ReciprocalRole__c reciprocalRoleObj =  [select Id, Name from FinServ__ReciprocalRole__c where name = :reciprocalRole];      

              Integer count = [select COUNT() from FinServ__AccountAccountRelation__c where
                                                                    FinServ__Account__c=:accountId and 
                                                                    FinServ__RelatedAccount__c = :relatedAccountId and 
                                                                    FinServ__Active__c =true and
                                                                    FinServ__Role__c =: reciprocalRoleObj.Id and
                                                                    OwnerId =: userId];
        	
               if(count>0){
                  result = true;
               }   
               
               return result;      
          }


}