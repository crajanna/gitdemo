/**
 * Handler to roll up the restricted account transactions on Financial Account
 * @author Manas Shinde
 * @since 
 */
public with sharing class RestrictedAccTxnHandler {
    public static boolean firstRun = true;

    /**
     * 
     * @param newList 
     */
    public void onafterInsertRollupBalance(List<Restricted_Account_Transaction__c> newList){   
    List<FinServ__FinancialAccount__c> finAccountList = new List<FinServ__FinancialAccount__c>();
    List<Id> finAcctIdList = new List<Id>();    

   for(Restricted_Account_Transaction__c txns : newList)
    {
        finAcctIdList.add(txns.Financial_Account__c);
    }
            for(FinServ__FinancialAccount__c finAccnt : [Select id,name,SRO_Funds__c,Rollover_Funds__c,
                Gardner_Funds__c,Flag_Court_Order_Funds__c,Donations_Pledge_Funds__c
                from FinServ__FinancialAccount__c where id  IN : finAcctIdList WITH SECURITY_ENFORCED])
            {
                Decimal sroBal = getTotalBalance(finAccnt.id,'SRO');  
                finAccnt.SRO_Funds__c = sroBal;

                Decimal rolloverBal = getTotalBalance(finAccnt.id,'Rollover');  
                finAccnt.Rollover_Funds__c = rolloverBal;

                Decimal gardnerBal = getTotalBalance(finAccnt.id,'Gardner');  
                finAccnt.Gardner_Funds__c = gardnerBal;

                Decimal flagCourtOrderBal = getTotalBalance(finAccnt.id,'Flag/Court Order');  
                finAccnt.Flag_Court_Order_Funds__c = flagCourtOrderBal;

                Decimal donationBal = getTotalBalance(finAccnt.id,'Donations/Pledge');  
                finAccnt.Donations_Pledge_Funds__c = donationBal;

                finAccountList.add(finAccnt);       
            }
        
        if(finAccountList.size()>0)
        {
            if (Schema.sObjectType.FinServ__FinancialAccount__c.isUpdateable()){
                update finAccountList; 
            }
        }
  }

  public Decimal getTotalBalance(Id id , String sourceCategory){
        Decimal bal = 0;
        Decimal creditValue = 0;

        List<AggregateResult> creditSum = [select SUM(Amount__c)amount from Restricted_Account_Transaction__c 
                                            where Financial_Account__c =: id and Transaction_Type__c = 'Credit' 
                                            and Source_Category__c =: sourceCategory WITH SECURITY_ENFORCED];
        
        if(creditSum.size()>0) {
            creditValue = (Decimal)creditSum[0].get('amount');
        }
        
        Decimal debitValue = 0;
        List<AggregateResult> debitSum = null;
        
        debitSum = [select SUM(Amount__c)amount from Restricted_Account_Transaction__c 
                            where Financial_Account__c =: id and Transaction_Type__c = 'Debit' 
                            and Source_Category__c = : sourceCategory WITH SECURITY_ENFORCED];
    
        if(debitSum.size()>0){
            debitValue = (Decimal)debitSum[0].get('amount');
        }
        
        if(creditValue == null){
            creditValue = 0;
        }

        if(debitValue == null){
            debitValue = 0;
        }
        
        bal = creditValue-debitValue;
        return bal;
  }
  
}