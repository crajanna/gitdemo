public without sharing class PaypalController {

    public  static String paypalSrc {get;set;}

    public  static Decimal transactionAmount {get;set;}

    public  static String transactionId {get;set;}

    public static String recordType {get;set;}

    public PaypalController(){

        
        Paypal_Settings__mdt paypalMdt = [SELECT Client_Id__c FROM Paypal_Settings__mdt];    
        paypalSrc = paypalMdt.Client_Id__c;

        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
        Id userId = UserInfo.getUserId();
        User user = [SELECT AccountId FROM User WHERE Id = :userId];
        String pkey = 'PAYPAL'+user.AccountId; 
   
       if(!Test.isRunningTest()){
            FpPayPalCachedData data = (FpPayPalCachedData)Cache.Session.get(pkey);
            transactionAmount = ( Decimal.ValueOf(data.transferAmount)+ Decimal.ValueOf(data.fee)).setScale(2);
            recordType = data.recordTypeId;
            transactionId = '';  
        }else{
            //This else condition is for only Test execution.
            Transfer_Fund__c data = [select Id , Transfer_Amount__c, Fee__c, RecordType.DeveloperName, Contract__r.Pledge__c ,Contract__r.Product__r.Name from Transfer_Fund__c t LIMIT 1];
              transactionAmount = 0;
            recordType = '';
            transactionId = '';    
        }
        
    }

}