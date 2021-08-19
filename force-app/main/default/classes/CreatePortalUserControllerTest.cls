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
@isTest
public class CreatePortalUserControllerTest {
   	
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    **/
    @isTest
    private static  void testcreatePortalUser(){
      String value = '13';
       String userId = '';
       Test.startTest();
       userId = CreatePortalUserController.createPortalUser('firstName '+value, 'lastName '+value, 'email'+value+'@email.com', 'businessName'+value, 'true');
       Test.stopTest();
       User u = [select Id from User where id =:userId];
       System.assertEquals(u != null, true);
     }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return testMethod 
    **/
    private static testMethod void testcreateContactUser(){
      String value = '13';
       String userId = '';
        User user;
       Account account = TestDataFactory.createAccount(true, value);
       Test.startTest();
       user = CreatePortalUserController.createContactPortalUser('firstName '+value, 'lastName '+value, 'email'+value+'@email.com', 'businessName'+value, 'true', account.Id);
       Test.stopTest();
       User u = [select Id from User where id =:user.Id];
       System.assertEquals(u != null, true);
     }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return testMethod 
    **/
    private static testMethod void isExistingUser(){
   		String value = '13';
        String email = 'email'+value+'@email.com';
        boolean userExists;
      
      
       Account account = TestDataFactory.createAccount(true, value);
        User user = CreatePortalUserController.createContactPortalUser('firstName '+value, 'lastName '+value, 'email'+value+'@email.com', 'businessName'+value, 'true', account.Id);
        Test.startTest();
        userExists = CreatePortalUserController.isExistingUser(email);
        Test.stopTest();
        
        System.debug('user =>'+userExists);
        System.assertEquals(userExists == true, true);
    }
}