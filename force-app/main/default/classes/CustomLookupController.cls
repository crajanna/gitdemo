public without sharing class CustomLookupController {
    
    @AuraEnabled
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm){
        String searchKeyword = searchTerm + '*';
        String returningQuery = '';
        returningQuery = objectName+' ( Id, '+String.join(fields,',')+')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 20';
        System.debug(' query '+query);
        List<List<sObject>> searchRecords = Search.Query(Query);
        return searchRecords.get(0);
    }

       //This method retrieves the data from database table. It search input is '*', then retrieve all records
       @AuraEnabled (cacheable=true)
       public static List<SObjectQueryResult> retrieveRecords(String objectName, 
                                                       String fieldAPINames,
                                                       String filterFieldAPIName,
                                                       String strInput){
           
           List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
           if(strInput.equals('*')){
               strInput = '';
           }
           String str = strInput ;
           String strQueryField = '';
           List<String> fieldList = fieldAPINames.split(',');
   
           //check if Id is already been passed
           if(!fieldList.contains('Id')){
               fieldList.add('Id');
               strQueryField = String.join(fieldList, ',');
           }else {
               strQueryField = fieldAPINames;
           }
   
           Id RecordTypeId  = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
           String strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                           + ' FROM ' 
                           + String.escapeSingleQuotes(objectName) 
                           + ' WHERE ' + filterFieldAPIName + '  LIKE \'' + str + '%\' '
                           + ' AND RecordTypeId =\''+RecordTypeId +'\' '
                           + ' ORDER BY ' + filterFieldAPIName
                           + ' LIMIT 50';
                           
           System.debug('strQuery=' + strQuery);
   
           List<SObject> lstResult = database.query(strQuery);
           //create list of records that can be easily be parsable at js controller.
           for(String strField:fieldList){
               for(SObject sobj:lstResult){                
                   if(strField != 'Id'){
                       SObjectQueryResult result = new SObjectQueryResult();
                       result.recordId = (String) sobj.get('Id');
                       result.recordName = (String) sobj.get(strField);
                       lstReturnResult.add(result);
                   }                
               }
           }
           return lstReturnResult;
       }
       
       public class SObjectQueryResult {
           @AuraEnabled
           public String recordId;
   
           @AuraEnabled
           public String recordName;
       }
}