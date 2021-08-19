public with sharing class ClaimInputData {
    @AuraEnabled public String Id {get;set;}
    @AuraEnabled public String Name {get;set;}
    @AuraEnabled public Date DateOfBirth {get;set;}
    @AuraEnabled public String Grade {get;set;}
    @AuraEnabled public String AddressLn1 {get;set;}
    @AuraEnabled public String City {get;set;}
    @AuraEnabled public String State {get;set;}
    @AuraEnabled public String ZipCode {get;set;}
    @AuraEnabled public String Email {get;set;}
    @AuraEnabled public String Monthly {get;set;}
    @AuraEnabled public String Annually {get;set;}
    @AuraEnabled public String FavSubject {get;set;}
    @AuraEnabled public String StudentSign {get;set;}
    @AuraEnabled public String ParentSign {get;set;}

    @AuraEnabled public Integer CurrentStep {get;set;}

    public ClaimInputData() {

    }
}