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
public class TestDataFactory {
	
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return List<String> 
    **/
    public static List<String> userInput(){
        String [] arrayOfProducts = new List<String>();
        //Adding elements in Array
        //1.	FirstName
        arrayOfProducts.add('Satish');
        //2.	LastName
        arrayOfProducts.add('Anupoju');
        //3.	Email
        arrayOfProducts.add('satishbabu82@email.com');
        //4.	BusinessName
        arrayOfProducts.add('H2O Inc');
        //5.	Master check box
        arrayOfProducts.add('true');
        
        return arrayOfProducts;
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @param isInsert 
    * @param value 
    * @return Account 
    **/
    public static Account createAccount(boolean isInsert, String value){
        Account acct = new Account();
        acct.Name = 'Test '+value;
        acct.RecordTypeId = '0124W000001bAJVQA2';
        if(isInsert){
            insert acct;
        }
        return acct;
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @param isInsert 
    * @param accountId 
    * @param value 
    * @return Contact 
    **/
    public static Contact createContact(boolean isInsert, String accountId, String value){
        Contact con = new Contact();
        con.FirstName = 'firstName '+value;
        con.Lastname = 'lastName '+value;
        con.Master_Contract_Agreement__c  = Boolean.valueOf('true');
        con.AccountId = accountId;
        con.RecordTypeId = '0124W000001bAJfQAM';
        con.Email='test'+value+'@email.com';
        if(isInsert){
            insert con;
        }
        return con;
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @param isInsert 
    * @param con 
    * @param value 
    * @return User 
    **/
    public static User createPortalUser(boolean isInsert, Contact con, String value){
    	Profile portalProfile = [SELECT Id FROM Profile WHERE Name='FoundationCustomer' Limit 1];
        User portalUser = new User();
        portalUser.UserName = con.Email;
        portalUser.FirstName = con.FirstName;
        portalUser.LastName = con.Lastname;
        portalUser.Alias = 'FP'+System.now().millisecond();
        portalUser.Email = con.Email;
        portalUser.ContactId = con.Id;
        portalUser.ProfileId = portalProfile.Id;
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.CommunityNickname = con.FirstName+' '+con.Lastname;
        portalUser.TimeZoneSidKey = 'America/New_York';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.LanguageLocaleKey = 'en_US';
         
        if(isInsert){
            insert portalUser;
        }
        return portalUser;
        
    }
}