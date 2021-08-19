trigger FinancialHolding_CustomTrigger on FinServ__FinancialHolding__c (after insert, after update) {
     if(TriggerUtil.isTriggerActive('FinancialHolding_CustomTrigger')){     
          FinancialHoldingHandler handler = new FinancialHoldingHandler();    
          //handler to invoke account cash balance rollup from transaction 
          if(Trigger.isAfter){
          if(Trigger.isInsert){
               handler.updateTotalHoldingBalance(Trigger.New);
               }
          if(Trigger.isUpdate){
               handler.updateTotalHoldingBalance(Trigger.New);
               }
          }     
     } 

}