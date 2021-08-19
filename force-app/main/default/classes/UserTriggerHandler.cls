/**
 * Name: UserTriggerHandler
 * Description: apex based sharing implementation for security work
 * Test Class: UserTriggerHandlerTest
 * Created By: Satish Nikam - 8/16/2021
 * Modifications Log: 
 * Date         Modified By    Modification Details
 * 8/16/2021   Satish Nikam    Original Implementation for apex based sharing
**/
public class UserTriggerHandler {
    public void OnAfterInsert(List <User> newUserList) {
        //Step 1 # fetch account and contact Ids
        for(User usrRecord:[Select Id, ContactId,AccountId From User Where Id IN :newUserList]){

        }

        //Step 2 # fetch financial Account Role for created user if not primary

        //Step 3 # fetch financial Account

        //Step 4 # fetch financial Account Role for Primary owner

        //Step 5 # fetch person account for Primary owner

        //Step 6 # share person account for users pulled in step 1
    }
}