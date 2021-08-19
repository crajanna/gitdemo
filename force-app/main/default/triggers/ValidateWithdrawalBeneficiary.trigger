trigger ValidateWithdrawalBeneficiary on Withdrawal__c (before update) {
   if(TriggerUtil.isTriggerActive('ValidateWithdrawalBeneficiary')){     

      Set<ID> RolesAccountSet = new Set<ID>();
      for(Withdrawal__c wc : Trigger.New)
      {
               if(wc.Account__c != null)
               {
                  for(FinServ__FinancialAccountRole__c finRoleAccList:  [select FinServ__RelatedAccount__c, id from FinServ__FinancialAccountRole__c where
                                                                        FinServ__FinancialAccount__c =:wc.Investment_Account__c 
                                                                        and FinServ__Active__c = true])
                  {
                        RolesAccountSet.add(finRoleAccList.FinServ__RelatedAccount__c);
                        
                  }
                  if(RolesAccountSet.contains(wc.Account__c) == false)
                           {
                              wc.Account__c.addError('For the benefit of account doesnot belong to financial account roles or inactive' );  
                           }
               }
               else
               {
                  wc.Account__c.addError('For the Benefit of account is required for Withdrawal Request');
               }        
         }
      }
	
}