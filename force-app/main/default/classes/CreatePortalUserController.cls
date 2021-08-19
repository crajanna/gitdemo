/**
 * @description       : 
 * @author            : Satishbabu Anupoju@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-07-2021   Satishbabu Anupoju@UserSettingsUnder.SFDoc   Initial Version
**/

public without sharing class CreatePortalUserController {
    
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @param email 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean isExistingUser(String email){
        List<User> userList = [SELECT Id, LastName, Username FROM User where Username =: email LIMIT 1];
        User user;
        if(userList.size()>0){user = userList[0];}
        try{
        	
            if(user != null){
        		System.debug('Existing User: '+ user.UserName);
            	return true;
            }else{
                System.debug('New User: '+ user.UserName);
                return false;
            }
            
        } catch(Exception e){
            System.debug(e);
            return false;
        }    
        
    }
    
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @param firstName 
    * @param lastName 
    * @param email 
    * @param businessName 
    * @param masterContactAgreement 
    * @return String 
    **/
    @AuraEnabled
    public static String createPortalUser(String firstName, String lastName, String email, String businessName, String masterContactAgreement){
       try{
          Account account = new Account(
                    Name = businessName, IsPortalAccount__c = true, Email__c = email,
                    RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId()
          );
          Database.insert(account);
          System.debug('### Account Id:'+account.Id);
          System.debug('### RecordType Id:'+account.RecordTypeId);
           
		//Create contact
         Contact contact = new Contact(
                   FirstName = firstName,
                   Lastname = lastName,
              	   Master_Contract_Agreement__c  = Boolean.valueOf(masterContactAgreement),
                   AccountId = account.Id,
                   RecordTypeId = Contact.sObjectType.getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId(),
           		   Email=email
           );
           Database.insert(contact);
           System.debug('### ContactId: '+contact.Id);
           System.debug('### RecordTypeId: '+contact.RecordTypeId);
           
           //Create user
           Profile portalProfile = [SELECT Id FROM Profile WHERE Name='FoundationCustomer' Limit 1];
           User portalUser = new User(
               UserName = email,
               FirstName = firstName,
               LastName = lastName,
               Alias = 'FP'+System.now().millisecond(),
               Email = email,
               ContactId = contact.Id,
               ProfileId = portalProfile.Id,
               EmailEncodingKey = 'UTF-8',
               CommunityNickname = firstName+' '+lastName,
               TimeZoneSidKey = 'America/New_York',
               LocaleSidKey = 'en_US',
               LanguageLocaleKey = 'en_US'
            );
            
           Database.insert(portalUser);
           System.debug('### Portal User ID :'+portalUser.Id);     
  
           
          // String userId = Site.createPortalUser(portalUser, account.Id, null, true);
          //System.debug('### userId.. :'+userId); 
       
        return portalUser.Id;

    }catch(Exception e){
        //System.debug(e.getMessage());
        System.debug(e);
        return e.getMessage() ;
    }
}
    
    /**
    * @description 
    * @author Ifeanyi@UserSettingsUnder.SFDoc | 05-07-2021 
    * @param firstName 
    * @param lastName 
    * @param email 
    * @param businessName 
    * @param masterContactAgreement 
    * @param accountId 
    * @return User 
    **/
    @AuraEnabled
    public static User createContactPortalUser(String firstName, String lastName, String email, String businessName, String masterContactAgreement, String accountId){
       
        User portalUser;
       
        try{
         
          //Create contact
          Contact contact = new Contact(
                   FirstName = firstName,
                   Lastname = lastName,
              	   Master_Contract_Agreement__c  = Boolean.valueOf(masterContactAgreement),
                   AccountId = accountId,
          	 	   RecordTypeId = Contact.sObjectType.getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId(),
           		   Email=email
           );
           Database.insert(contact);
           System.debug('### ContactId: '+contact.Id);
           
           //Create user
           Profile portalProfile = [SELECT Id FROM Profile WHERE Name='FoundationCustomer' Limit 1];
           portalUser = new User(
               UserName = email,
               FirstName = firstName,
               LastName = lastName,
               Alias = 'FP'+System.now().millisecond(),
               Email = email,
               ContactId = contact.Id,
               ProfileId = portalProfile.Id,
               EmailEncodingKey = 'UTF-8',
               CommunityNickname = firstName+' '+lastName,
               TimeZoneSidKey = 'America/New_York',
               LocaleSidKey = 'en_US',
               LanguageLocaleKey = 'en_US'
            );
            
           Database.insert(portalUser);
           System.debug('### Portal User ID :'+portalUser);     
        
       }catch(Exception e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }

        return portalUser;
    }
}