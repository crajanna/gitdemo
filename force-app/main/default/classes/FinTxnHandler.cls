public class FinTxnHandler {
    
    public static boolean firstRun = true;
    public void onafterInsertRollupBalance(List<FinServ__FinancialAccountTransaction__c> newList){   
    Map<Id,FinServ__FinancialAccount__c> FinAccountMap = new Map<Id,FinServ__FinancialAccount__c>();
        for(FinServ__FinancialAccountTransaction__c txns : newList)
        {
            for(FinServ__FinancialAccount__c FinAccnt : [Select id,RecordTypeId, name,FinServ__CashBalance__c from FinServ__FinancialAccount__c where id =: txns.FinServ__FinancialAccount__c])
            {
                Decimal TempBal = 0;
                Decimal credit_Value = 0;
                List<AggregateResult> sum_Credit = [select SUM(FinServ__Amount__c)amount from FinServ__FinancialAccountTransaction__c 
                                                    where
                                                    FinServ__FinancialAccount__c =: FinAccnt.Id and FinServ__TransactionStatus__c = 'Posted'
                                                    and FinServ__TransactionType__c = 'Credit' and Source_Category__c != 'Pledge'];
                
                
                if(sum_Credit.size()>0) {
                    credit_Value = (Decimal)sum_Credit[0].get('amount');
                }
                Decimal debit_Value = 0;
                List<AggregateResult> sum_debit = null;
                if(FinAccnt.RecordTypeId == Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId())
                {   
                    sum_debit = [select SUM(FinServ__Amount__c)amount from FinServ__FinancialAccountTransaction__c 
                                 where FinServ__FinancialAccount__c =: FinAccnt.Id and FinServ__TransactionStatus__c = 'Posted'
                                 and FinServ__TransactionType__c = 'Debit' and FinServ__TransactionSubtype__c != 'Transfer Out'];
                }else{
                    sum_debit = [select SUM(FinServ__Amount__c)amount from FinServ__FinancialAccountTransaction__c 
                                 where FinServ__FinancialAccount__c =: FinAccnt.Id and FinServ__TransactionStatus__c = 'Posted'
                                 and FinServ__TransactionType__c = 'Debit']; 
                }
                if(sum_debit.size()>0) 
                    debit_Value = (Decimal)sum_debit[0].get('amount');
                
                if(credit_Value == null)
                    credit_Value = 0;
                if(debit_Value == null)
                    debit_Value = 0;
                TempBal = credit_Value-debit_Value;
                FinAccnt.FinServ__CashBalance__c = TempBal;
                FinAccountMap.put(FinAccnt.id, FinAccnt);
            }
        }
        if(!FinAccountMap.isEmpty())
        {
            List<FinServ__FinancialAccount__c> FinAccount_List = FinAccountMap.Values();
            if(!FinAccount_List.isEmpty() && Schema.sObjectType.FinServ__FinancialAccount__c.fields.FinServ__CashBalance__c.isUpdateable()) {
              update FinAccount_List;
            }
        }
    }
    
    public void FeewaiverValid(List<FinServ__FinancialAccountTransaction__c> newList){   
        
        for(FinServ__FinancialAccountTransaction__c Txns : newList)
        {
            if(Txns.FinServ__TransactionSubtype__c == 'Fee Waiver' && Txns.FinServ__TransactionStatus__c == 'Posted')
            {
                Decimal Fee_Value = 0;
                Decimal FeeWaiver_Value = 0;
                decimal Req_feeWaiver = 0;
                Decimal Total_feeWaiver = 0;
                List<AggregateResult> feeamount = [select SUM(FinServ__Amount__c)Fees from FinServ__FinancialAccountTransaction__c where FinServ__Amount__c != null and FinServ__FinancialAccount__c  =: txns.FinServ__FinancialAccount__c and FinServ__TransactionSubtype__c = 'Fee' 
                                                   and FinServ__TransactionStatus__c = 'Posted' ];
                List<AggregateResult> FeeWaiverAmount  = [select SUM(FinServ__Amount__c)Fee_Waiver from FinServ__FinancialAccountTransaction__c where FinServ__FinancialAccount__c  =: txns.FinServ__FinancialAccount__c and FinServ__TransactionSubtype__c = 'Fee Waiver'
                                                          and FinServ__TransactionStatus__c = 'Posted'];
                if(feeamount.size()>0) 
                    Fee_Value = (Decimal)feeamount[0].get('Fees');
                if(FeeWaiverAmount.size()>0) 
                    FeeWaiver_Value = (Decimal)FeeWaiverAmount[0].get('Fee_Waiver');
                Req_feeWaiver = Txns.FinServ__Amount__c;
                Total_feeWaiver = Req_feeWaiver+FeeWaiver_Value;
                //feeamount.get('expr0');
                system.debug('Total fee waiver: ' +Total_feeWaiver);
                system.debug('Req fee waiver: ' +Req_feeWaiver);
                system.debug('Existing fee value: ' +Fee_Value);
                system.debug('Existing fee value: ' +FeeWaiver_Value);
                if(FeeWaiver_Value > Fee_Value)
                    Txns.FinServ__Amount__c.addError('Total Requested Fee waiver: '+ FeeWaiver_Value +' is more than recieved Total fees: ' +Fee_Value);
            }
        }
    } 
    
}