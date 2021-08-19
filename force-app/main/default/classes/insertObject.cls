public inherited sharing class insertObject {
    @AuraEnabled
    public static void insertCon(Contact con){ 
        try{  

            RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];

            //012P0000001D1bsIAC
            Account newPersonAccount = new Account();
            newPersonAccount.FirstName = con.FirstName;
            newPersonAccount.LastName = con.LastName;

            //  newPersonAccount.FirstName = 'Fred_new123_2_26_2';
            // newPersonAccount.LastName = 'Fred_new123_2_26_2';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;

        }catch(Exception e){
            System.debug('--->'+e);
        }
      
    }   
}