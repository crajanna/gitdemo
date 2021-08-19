public class RebalanceAllocations {
    
    @AuraEnabled
    public static Boolean rebalanceAllocations(String accountId){
           System.debug('Inside rebalanceAllocations ... ' +  accountId);
           Decimal balance = [SELECT FinServ__Balance__c from FinServ__FinancialAccount__c where Id =  :accountId LIMIT 1].FinServ__Balance__c;
           List<Investment_Transaction__c> itItems = new List<Investment_Transaction__c>();
           List<Fund_Allocation__c> faItems = new List<Fund_Allocation__c>();
           for(FinServ__FinancialHolding__c item: [SELECT Id, FinServ__Securities__r.Id , FinServ__MarketValue__c, FinServ__Price__c, FinServ__Shares__c
                                                            from FinServ__FinancialHolding__c 
                                                            where FinServ__FinancialAccount__r.Id = :accountId]){
                System.debug('Inside rebalanceAllocations loop... ' +  accountId);  
                Investment_Transaction__c  itObj = new Investment_Transaction__c();
                itObj.Action_Type__c = 'Sell';
                itObj.Financial_Account__c = accountId;
                itObj.Cost_Basis__c = item.FinServ__MarketValue__c * -1;
                itObj.Buy_Amount__c = item.FinServ__MarketValue__c;                                                   
                itObj.shares_quantity__c = item.FinServ__Shares__c;
                itObj.Purchase_Price__c = item.FinServ__Price__c;
                itObj.Securities__c = item.FinServ__Securities__r.Id;
                itObj.Status__c = 'Processing';
                itItems.add(itObj);
            }
        
            if(balance>0){
                for(Fund_Allocation__c  item: [SELECT Securities__r.Id, Securities__r.FinServ__Price__c, allocation_percentage__c, Active_Indicator__c  from Fund_Allocation__c  where Financial_Account__r.Id =  :accountId
                                                                                  and Allocation_Type__c= 'RA'
                                                                                  and Active_Indicator__c = 'Yes']){
                   Investment_Transaction__c  itObj = new Investment_Transaction__c();
                   itObj.Action_Type__c = 'Buy';
                   itObj.Financial_Account__c = accountId;
                   Decimal cost = item.allocation_percentage__c/100 * balance;
                   Decimal price = item.Securities__r.FinServ__Price__c;
                   itObj.Cost_Basis__c = cost;
                   itObj.Buy_Amount__c = cost;                                                   
                   itObj.shares_quantity__c = cost/price;
                   itObj.Purchase_Price__c = price;
                   itObj.Securities__c = item.Securities__r.Id;
                   itObj.Status__c = 'Processing';
                   itItems.add(itObj);     
                   item.Active_Indicator__c = 'No';
				   faItems.add(item);
                }
            }
            if(!itItems.isEmpty() && Schema.sObjectType.Investment_Transaction__c.fields.Financial_Account__c.isCreateable() ) {
                insert itItems;
            }
            if(!faItems.isEmpty() && Schema.sObjectType.Fund_Allocation__c.fields.Active_Indicator__c.isUpdateable()) {
               update faItems;
            }
        return true;
    }
}