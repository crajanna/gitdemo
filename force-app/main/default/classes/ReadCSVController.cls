public with sharing class ReadCSVController {
    @AuraEnabled
    public static list<FinServ__FinancialAccount__c> readCSVFile(Id idContentDocument){
        list<FinServ__FinancialAccount__c> lstAccsToInsert = new list<FinServ__FinancialAccount__c>();
        if(idContentDocument != null) {
            
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

            for(Integer i = 1; i < lstCSVLines.size(); i++){
                FinServ__FinancialAccount__c objAcc = new FinServ__FinancialAccount__c();
                list<String> csvRowData = lstCSVLines[i].split(',');
                System.debug('csvRowData====> '+csvRowData);
                objAcc.FinServ__PrimaryOwner__c = csvRowData[0]; // accName
                objAcc.FinServ__Ownership__c = csvRowData[1];
                objAcc.FinServ__FinancialAccountType__c = csvRowData[2];

                lstAccsToInsert.add(objAcc);
            }

            try{    
                if(!lstAccsToInsert.isEmpty()) {
                    insert lstAccsToInsert;
                }
            }
            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            } 
        }
        return lstAccsToInsert;    
    }
}