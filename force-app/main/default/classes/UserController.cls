public without sharing class UserController {
    @AuraEnabled(cacheable=true)
    public static Id getUserAccountId() {
        return [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;
    }
}