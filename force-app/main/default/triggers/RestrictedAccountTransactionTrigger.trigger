trigger RestrictedAccountTransactionTrigger on Restricted_Account_Transaction__c (after insert, after update) {

    RestrictedAccTxnHandler handler = new RestrictedAccTxnHandler();    
    
     if(Trigger.isAfter){
       
        if(Trigger.isInsert){

          RestrictedAccTxnHandler.firstRun=false;
          handler.onafterInsertRollupBalance(Trigger.New);
        }
          if(Trigger.isUpdate){
            RestrictedAccTxnHandler.firstRun=false;
            handler.onafterInsertRollupBalance(Trigger.New);
         }
     }      
}