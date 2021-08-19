/**
* 
* @author : Manas Shinde
* Batch job to process and create the school invoice records  
* submitted via CSV File
* 
*/
global with sharing class SubmitSchoolInvoiceBatch implements Database.Batchable<sObject>, Database.Stateful
{
    public String data;
    public String batchId;
    public String fileName;
    public String recID;
    global List<String> errorlist;
    public Boolean isBatchPresent;
    public String term;
    public String year;
    public String invType;
    public SubmitSchoolInvoiceBatch(String base64DataT, String batchIdT, String recIDT, String fileNameT,string termValue , String yearValue,String invoiceType) 
    {
        system.debug('file data: '+base64DataT);
        data = JSON.deserializeUntyped(base64DataT).toString();
        batchId = batchIdT;
        recID = recIDT;
        fileName = fileNameT;
        term = termValue;
        year = yearValue;
        invType = invoiceType;
        errorlist = new List<String>();
    }

    /**
     *  Splits the CSV line items and adds to the List after removing the header record
     * @param bc 
     * @return  `iterable<sObject>`
     */
    global iterable<sObject> start(Database.BatchableContext bc)
    {
        
        list<String> lstCSVLines = data.split('\n');
        lstCSVLines.remove(0);
        System.debug('lstCSVLines....'+lstCSVLines);


        return (iterable<sObject>)lstCSVLines ;
    }
    
    global void execute(Database.BatchableContext bc, List<Object> scope)
    {  
        List<String> csvData = (List<String>) scope;
        System.debug('CSVData....'+csvData);
        List<School_Invoice__c> invList  = new List<School_Invoice__c>();
        list<School_Invoice__c> lstInvoiceToInsert = new list<School_Invoice__c>();
        map<String, Account> ssnToAccMap = new map<String, Account>();
        Map<String,List<String>> dataMap = new Map<String,List<String>>();
        List<String> studentIdList = new List<String>();
        Set<String> ssnSet = new Set<String>();
        Set<String> rateCodeSet = new Set<String>();
        String strSSNBirthDate;
        Date inputDate;
        String strRequestedAmount;
        String strRequestedUnits;

        //Map<String,List<String>> ssnToDataMap = new Map<String,List<String>>();
        Savepoint sp = Database.setSavepoint();
        try 
        {
            for(Integer i = 1; i <= csvData.size(); i++)
            {
                
                String csvLine = csvData[i-1];
                String prevLine = csvLine;
                List<String> csvRowData = csvLine.split(',');
                System.debug('csvRowData ?????????? '+csvRowData);
                if(String.isNotBlank(csvRowData[1])){
                    ssnSet.add(csvRowData[1]);
                    if(String.isNotBlank(csvRowData[2])){
                        inputDate=Date.parse(csvRowData[2]);  
                        strSSNBirthDate = csvRowData[1] + '-' + String.valueOf(inputDate);
                        System.debug('strSSNBirthDate >>>>>>>>>>>>' + strSSNBirthDate);
                    }
                    dataMap.put(strSSNBirthDate,csvRowData);
                }

                if(String.isNotBlank(csvRowData[3])){
                    rateCodeSet.add(csvRowData[3]);
                }

                if(String.isNotBlank(csvRowData[0])){
                    studentIdList.add(csvRowData[0]);
                    dataMap.put(csvRowData[0],csvRowData);
                }
            }

            System.debug('dataMap >>>>>>>>>>>>' + dataMap);

            //Get beneficiary account information based on SSN
            map<String, String> ssnToAccountMap = new map<String, String>();
            ssnToAccountMap = SubmitInvoiceController.getAccountBasedOnSSN(ssnSet);

            //Get Beneficiary Accouny information based on Student ID.
            map<String, String> studentIdToAccountMap = new map<String, String>();
            studentIdToAccountMap = SubmitInvoiceController.getAccountBasedOnStudentId(studentIdList,recID);

            map<String, String> rateCodesMap = new map<String, String>();
            rateCodesMap = getRateCodes(rateCodeSet);
            
            // Auto generate the Batch Id 
            String dateFormat = 'yyyyMMddHHmmss';
            DateTime dt = DateTime.now();
            String batchId = dt.format(dateFormat);

            for(String s : dataMap.keySet())
            {
                List<String> strDataList = dataMap.get(s);
                System.debug('strDataList....'+strDataList);
                School_Invoice__c objInv = new School_Invoice__c();
                    objInv.Batch_Id__c = batchId;          
                    //objInv.AccountId__c = recId;
                    String beneficiaryId ;
                    if(null != ssnToAccountMap && null != ssnToAccountMap.get(s)){
                        //objInv.Beneficiary_Id__c = ssnToAccMap.get(String.valueOf(mapObj.get('ssn')));
                        beneficiaryId = ssnToAccountMap.get(s);
                    }

                    if(null != studentIdToAccountMap && null != studentIdToAccountMap.get(s)){
                        beneficiaryId = studentIdToAccountMap.get(s);
                    }

                    System.debug('beneficiaryId....'+beneficiaryId);
                    
                    if(String.isNotBlank(beneficiaryId)){
                        objInv.Beneficiary_Id__c = beneficiaryId;
                    }else{
                        //Mark status as Failed if beneficiary is not found
                        objInv.Status__c = 'Failed';
                    }

                    strRequestedUnits = strDataList[4];
                    if(String.isNotBlank(strRequestedUnits)){
                        objInv.Requested_Credits__c = Integer.valueOf(strRequestedUnits);
                    }
                    strRequestedAmount = strDataList[5];
                    if(String.isNotBlank(strRequestedAmount)){
                        objInv.Requested_Amount__c = Double.valueOf(strRequestedAmount);
                    }
                   
                    if(String.isNotBlank(strDataList[0])){
                        objInv.Student_Id__c = s;
                    }
                    
                    if(String.isNotBlank(strDataList[3]) && null != rateCodesMap){
                        System.debug('rateCode >>>>'+ rateCodesMap.get(strDataList[3]));
                        objInv.Rate_Code__c = String.valueOf(rateCodesMap.get(strDataList[3]));
                    }
                    objInv.Term__c = term;
                    objInv.Claim_Type__c = 'School Invoice';
                    objInv.Year__c = year;
                    objInv.Invoice_Type__c = invType;
                    objInv.isBatch__c = true;
                    objInv.Reference_Number__c = String.valueOf(strDataList[6]);
                    invList.add(objInv);
            }

            if (null != invList && invList.size()>0) {
                insert invList;
            }

        } 
        catch (Exception e) {
            system.debug('in catch...........');

            errorlist.add(e.getMessage()+' StackTrace:'+e.getStackTraceString());
            system.debug('in catch errorlist...........'+errorlist);
            Database.rollBack(sp);
        }
        
    }
    
    global void finish(Database.BatchableContext bc)
    {     
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.toAddresses = new String[]{UserInfo.getUserEmail(), 'mshinde@kyrasolutions.com'};
        
        String message ='';
        system.debug('errorlist...........'+errorlist);
        if(errorlist.size()==0)
        {
            email.setSubject('School Invoice File upload Successful');
            message += 'Records from csv file inserted successfully!';
            
        }else 
        {
            email.setSubject('School Invoice File upload Failed');
            message += 'Below error occured during file upload. Please contact System Administrator<br/>';
            message += String.join(errorlist, ', \r');
        }
        

        email.setHTMLBody(message);
        emailList.add(email);
        
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }
    
    /**
     * Get the rate codes based on the input.
     * @param rateCodeList 
     * @return  `map<String, String>`
     */
    public static map<String, String> getRateCodes(Set<String> rateCodeList) {
        system.debug('rateCodeList >>>>>>>' + rateCodeList);
        list < Rate_Code__c > rateCodes;
        map<String, String> rateCodeMap = new map<String, String>();
        if(rateCodeList != null && rateCodeList.size() > 0){
            rateCodes = [Select Id, Name from Rate_Code__c where Name IN : rateCodeList WITH SECURITY_ENFORCED];
        }

        if(null != rateCodes && rateCodes.size() > 0){
            for(Rate_Code__c rateCode : rateCodes){
                rateCodeMap.put(rateCode.Name,rateCode.Id);
            }
        }
        return rateCodeMap;
    }
}