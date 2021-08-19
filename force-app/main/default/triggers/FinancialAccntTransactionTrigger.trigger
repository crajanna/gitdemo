trigger FinancialAccntTransactionTrigger on FinServ__FinancialAccountTransaction__c (after insert, after update, after delete) {

if(TriggerUtil.isTriggerActive('FinancialAccntTransactionTrigger')){
	FinTxnHandler handler = new FinTxnHandler();    

//handler to invoke account cash balance rollup from transaction 
    
     if(Trigger.isAfter){
        //if(Trigger.isInsert && FinTxnHandler.firstRun){
       
        if(Trigger.isInsert){

          FinTxnHandler.firstRun=false;
          handler.onafterInsertRollupBalance(Trigger.New);
          handler.FeewaiverValid(Trigger.New);
          // FinTxnHandler.onafterInsertRollupBalance(Trigger.New);
        }
        // if(Trigger.isUpdate && FinTxnHandler.firstRun){
          
          if(Trigger.isUpdate){
          FinTxnHandler.firstRun=false;
          handler.onafterInsertRollupBalance(Trigger.New);
          handler.FeewaiverValid(Trigger.New);
         }
         
          if(Trigger.isDelete){
          FinTxnHandler.firstRun=false;
          handler.onafterInsertRollupBalance(Trigger.Old);
          handler.FeewaiverValid(Trigger.Old);
         }
     }      
 }
}