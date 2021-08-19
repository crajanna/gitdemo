public class ObjectUtility {  
   public static Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = new Map<String,Schema.RecordTypeInfo>();  
   public static Id getObjectRecordTypeId(String sObjectName, String recordTypeName) {  
     sObject obj;  
     Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);  
     if(sObjectType != null) {  
       obj = sObjectType.newsObject();  
       Schema.DescribeSObjectResult sObjDesc = obj.getSObjectType().getDescribe();  
       if(sObjDesc != null) {  
         recordTypeInfoMap = sObjDesc.getRecordTypeInfosByName();  
       }  
       if(!recordTypeInfoMap.containsKey(recordTypeName)) {  
         throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');  
       } else {  
         return recordTypeInfoMap.get(recordTypeName).getRecordTypeId();  
       }  
     }  
     return null;  
   }  
   public class RecordTypeException extends Exception{}  
 }