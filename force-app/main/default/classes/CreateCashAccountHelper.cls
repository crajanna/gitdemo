public without sharing class CreateCashAccountHelper {

    public static void createCashAccount(Account acc){
          System.debug('createCashAccount..in trigger helper 4');
          FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(
        	FinServ__PrimaryOwner__c = acc.Id,
        	Name = 'Cash Account',
        	FinServ__FinancialAccountType__c = 'Cash Account',
        	FinServ__Status__c = 'Active',
        	//FinServ__Nickname__c = acc.Name + ' ' + 'Cash Account',
        	FinServ__OpenDate__c = Date.today());
         System.debug('createCashAccount..in trigger helper 5');
          //     insert finAcc; 
         System.debug('createCashAccount..in trigger helper 6');
        
           }
    }