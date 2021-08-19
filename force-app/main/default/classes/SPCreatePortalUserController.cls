public without sharing class SPCreatePortalUserController {

    @AuraEnabled
    public static String createTestPortalUser(String firstName, String lastName, String email){
        UserRole portalRole = [Select Id, Name From UserRole Where PortalType = 'None' Limit 1];
		System.debug('portalRole : '+portalRole.Name);
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
		User portalAccountOwner1 = new User(
         UserRoleId = portalRole.Id,
         ProfileId = profile1.Id,
         Username = email + System.now().millisecond() ,
         Alias = 'sfdc',
         Email=email,
         EmailEncodingKey='UTF-8',
         Firstname=firstName,
         Lastname=lastName,
         LanguageLocaleKey='en_US',
         LocaleSidKey='en_US',
         TimeZoneSidKey='America/Chicago'
	);
	Database.insert(portalAccountOwner1);  
        String portalUserId;
    System.debug('Portal Account User Id  : '+portalAccountOwner1.Id);   
        
        if(portalAccountOwner1.Id != null){
    		Account act = new Account(
         		FirstName = 'firstName'+ System.now().millisecond(),
         		LastName = 'lastName'+ System.now().millisecond(),
         		OwnerId = portalAccountOwner1.Id
			);        
            Database.insert(act);
            System.debug('Account Id : '+act.Id);
        }
        createPortalUser(portalAccountOwner1.Id);
        return null;
    }
    
    
    @future
    public static void createPortalUser(Id userId){
        System.debug('userId : '+userId);
        
         if(userId != null){
    		Account act = new Account(
         		FirstName = 'firstName'+ System.now().millisecond(),
         		LastName = 'lastName'+ System.now().millisecond(),
         		OwnerId = userId
			);        
            Database.insert(act);
            System.debug('Account Id : '+act.Id);
            
            if(act.Id != null){
                Profile portalProfile = [SELECT Id FROM Profile WHERE Name='Community Portal' Limit 1];
                User user1 = new User(
                    UserName = act.PersonEmail,
                    FirstName = act.FirstName,
                    LastName = act.LastName,
                    Alias = 'test123'+ System.now().millisecond(),
                    email = act.PersonEmail,
                     ContactId = act.PersonContactId,
                     ProfileId = portalProfile.Id,
                     EmailEncodingKey = 'UTF-8',
                     CommunityNickname = 'test123'+ System.now().millisecond(),
                     TimeZoneSidKey = 'America/Los_Angeles',
                     LocaleSidKey = 'en_US',
                     LanguageLocaleKey = 'en_US'
        		);
				Database.insert(user1);
                System.debug('Portal User : '+user1.Id);
                
            }
        }  
    }
    
    
    
    
    
    
    
     @AuraEnabled
    public static String createPortalUser(String firstName, String lastName, String email){
       try{
          Account account = new Account(
                    FirstName = firstName, LastName = lastName, IsPortalAccount__c = true, Email__c = email,
                    RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
          );
          Database.insert(account);
          System.debug('### Account Id:'+account.Id);
          System.debug('### RecordType Id:'+account.RecordTypeId);
           
		//Create contact
         /*Contact contact = new Contact(
                   FirstName = firstName,
                   Lastname = lastName,
              	   
                   AccountId = account.Id,
                   RecordTypeId = Contact.sObjectType.getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId(),
           		   Email=email
           );
           Database.insert(contact);
           System.debug('### ContactId: '+contact.Id);
           System.debug('### RecordTypeId: '+contact.RecordTypeId);
           */
           //Create user
           Profile portalProfile = [SELECT Id FROM Profile WHERE Name='ScholarshipCustomer' Limit 1];
           User portalUser = new User(
               UserName = email,
               FirstName = firstName,
               LastName = lastName,
               Alias = 'FP'+System.now().millisecond(),
               Email = email,
               ContactId = account.PersonContactId, //contact.Id,
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
        //return account.Id;

    }catch(Exception e){
        //System.debug(e.getMessage());
        System.debug(e);
        return e.getMessage() ;
    }
}
}