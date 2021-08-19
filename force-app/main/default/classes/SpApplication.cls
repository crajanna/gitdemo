public with sharing class SpApplication {
    @AuraEnabled public String Name {get;set;}
    @AuraEnabled public Date DateOfBirth {get;set;}
    @AuraEnabled public String Grade {get;set;}
    @AuraEnabled public String AddressLn1 {get;set;}
    @AuraEnabled public String City {get;set;}
    @AuraEnabled public String State {get;set;}
    @AuraEnabled public String ZipCode {get;set;}
    @AuraEnabled public String Email {get;set;}

    public SpApplication() {

    }
}