@isTest
public class Test_DataFactory {

    public static Account prepardPortalAccount(boolean isInsert, String value){
        Account acct = new Account();
        acct.Name = 'Test '+value;
        acct.RecordTypeId = '0124W000001bAJVQA2';
        if(isInsert){
            insert acct;
        }
        return acct;
    }
}