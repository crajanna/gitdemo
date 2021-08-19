public inherited sharing class CustomLookup {
    @AuraEnabled(cacheable=true)
    public static List<Records> fetchRecords( String ObjectName, String field, String searchString, Integer NumRecords ) {
        List<Records> recordsList = new List<Records>();
        String accountRecordType = Label.Educational_Institutes;
        String query;
        String searchField = 'Name';
        String contractField = 'ContractNumber';
        System.debug('ObjectName >>>>>>>>>>>>'+ObjectName);
        try {
            if(ObjectName == 'Contract'){
                System.debug('ObjectName ****************** '+ObjectName);
                query = 'SELECT Id, ' + contractField + ' FROM '+ objectName + ' WHERE '+ contractField +' LIKE ' +
                '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT ' + NumRecords;          
            }else{
                query = 'SELECT Id, ' + field + ' FROM '+ objectName + ' WHERE '+ field +' LIKE ' +
                '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' AND recordtype.developername = \''+ accountRecordType + '\' LIMIT ' + NumRecords;
            }
			System.debug(query);
	        for(SObject s : Database.query(query)){
	            Records record = new Records();
	            record.Id = String.valueOf(s.get('id'));
                if(ObjectName == 'Contract'){
                    record.val = String.valueOf(s.get(contractField));
                }else{
                    record.val = String.valueOf(s.get(field));
                }
                
               // record.desc = String.valueOf(s.get(searchField));
	            recordsList.add(record);
	        } 
	    } catch (Exception err) {	    	
                throw new AuraHandledException(err.getMessage());
        }
        
        return recordsList;
    }

    public class Records{
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String val {get;set;}
      //  @AuraEnabled public String desc {get;set;}
    }
}