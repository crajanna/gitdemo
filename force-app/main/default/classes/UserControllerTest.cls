@isTest
public with sharing class UserControllerTest {

    private static testMethod void testGetUserAccountId(){
        Id accountId;
        Id portalUserId = CreatePortalUserController.createPortalUser('firstName', 'lastName', 'email@email.com', 'businessName', 'true');
        User u = [SELECT Id FROM User WHERE Id = :portalUserId LIMIT 1];

        Test.startTest();
        system.RunAs(u){
            accountId = UserController.getUserAccountId();
        }
        Test.stopTest();

        Id portalUserAccountId = [SELECT AccountId FROM User WHERE Id = :portalUserId].AccountId;
        
        System.debug('accountId =>'+accountId);
        System.debug('portalUserAccountId =>'+portalUserAccountId);
        System.assertEquals(accountId == portalUserAccountId, true);
    }
}