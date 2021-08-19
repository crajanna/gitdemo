/**
 * Name: TransferFundTriggerHandler
 * Description: apex based sharing implementation for security work
 * Test Class: TransferFundTriggerHandlerTest
 * Created By: Satish Nikam - 8/18/2021
 * Modifications Log: 
 * Date         Modified By    Modification Details
 * 8/18/2021   Satish Nikam    Original Implementation for apex based sharing
**/
public class TransferFundTriggerHandler {
    public TransferFundTriggerHandler() {

    }

    public void OnAfterInsert(List <Transfer_Fund__c> newTFList) {
        Map<Id,Set<Id>> transIdTOFinAcctMap = new Map<Id,Set<Id>>();
        Set<Id> finAcctSet = new Set<Id>();
        for(Transfer_Fund__c newTF : newTFList){
            Set<Id> finIdSet = new Set<Id>();
            finIdSet.add(newTF.Financial_Account_Investment__c); 
            finIdSet.add(newTF.Financial_Account_Cash__c);
            
            finAcctSet.addAll(finIdSet);
            transIdTOFinAcctMap.put(newTF.Id,finIdSet);
        }

        for(FinServ__FinancialAccountRole__c farRecord:[Select Id,FinServ__RelatedAccount__c,FinServ__FinancialAccount__c,FinServ__Role__c From FinServ__FinancialAccountRole__c 
                                                                Where FinServ__FinancialAccount__c = :finAcctSet]){
            //finAcctToPrimaryRolePersonAcctMap.put(farPrimaryOwner.FinServ__FinancialAccount__c,farPrimaryOwner.FinServ__RelatedAccount__c);
            //primaryAcctToFinRoleMap.put(farPrimaryOwner.FinServ__RelatedAccount__c,farPrimaryOwner);
        }
    }
}