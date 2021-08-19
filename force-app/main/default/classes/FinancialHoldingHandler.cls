public class FinancialHoldingHandler {
    
    public void updateTotalHoldingBalance(List<FinServ__FinancialHolding__c> newList)
       
    {
      Map<Id,FinServ__FinancialAccount__c> FinAccountMap = new Map<Id,FinServ__FinancialAccount__c>();
      for(FinServ__FinancialHolding__c holding_trig_rec : newList)
        {
             for(FinServ__FinancialAccount__c FinAccnt : [Select id,RecordTypeId, name,FinServ__Balance__c from FinServ__FinancialAccount__c where id =: holding_trig_rec.FinServ__FinancialAccount__c])
            {
                Decimal TempBal = 0;
                Decimal holding_Value = 0;
                List<AggregateResult> sum_holding = [select SUM(FinServ__MarketValue__c)MarketValue from FinServ__FinancialHolding__c 
                                                      where
                                                      FinServ__FinancialAccount__c =: FinAccnt.Id];
                
                system.debug('holding value: '+sum_holding);
                  if(sum_holding.size()>0) 
                  {
                     holding_Value = (Decimal)sum_holding[0].get('MarketValue');
                      
                     FinAccnt.FinServ__Balance__c = holding_Value;
                     FinAccountMap.put(FinAccnt.id, FinAccnt);
                      system.debug('holding value: '+ holding_Value+' updated to account: '+FinAccnt);
                  }
                
            }
        if(!FinAccountMap.isEmpty())
        {
            List<FinServ__FinancialAccount__c> FinAccount_List = FinAccountMap.Values();
            if(!FinAccount_List.isEmpty() && Schema.sObjectType.FinServ__FinancialAccount__c.fields.FinServ__Balance__c.isUpdateable()) {
              update FinAccount_List;
            }
        }
        }
    }

}