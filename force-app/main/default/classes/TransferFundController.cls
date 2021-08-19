public without sharing class TransferFundController {

    @AuraEnabled
    public static Transfer_Fund__c saveTransferFund(Transfer_Fund__c obj){
        upsert obj;
        return obj;
    }

}