public class CreateContractObj {
    @AuraEnabled
    public static void createContract(){
      Contract c = new Contract();
      c.AccountId = '001P000001n59bjIAA';
      //c.StartDate = a.Purchase_Date__c; 
      
      insert c;
        System.debug('contract has been created...');
    }

}