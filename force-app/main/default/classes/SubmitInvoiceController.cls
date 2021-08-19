/**
* 
* @author : Manas Shinde
* Class contains the logic to create the School Invoice record and to call the invoice batch if invoice 
* is submitted via CSV File
* 
*/
public with sharing class SubmitInvoiceController {

    /**
     *  Get Rate Codes based on below input parameters.
     * @param schoolId (Id of Eduacational Institute)
     * @param termValue (Spring/Summer/Fall)
     * @param yearValue 
     * @param invoiceType (Type of Invoice)
     * @return  `List<Rate_Code__c>`
     * @exception 
     */
    @AuraEnabled(cacheable=true)
    public static List<Rate_Code__c> getClaimRateCodes(String schoolId,string termValue , String yearValue,String invoiceType) {
        try {

            List<String> coverageTypes = new List<String>();
            if(String.isNotBlank(invoiceType)){
                if(invoiceType != 'Dormitory'){
                    coverageTypes = invoiceType.split('/');
                }else{
                    coverageTypes.add(invoiceType);
                }
            }
                       
            List < Rate_Code__c > relationList ;           
            if(String.isNotBlank(schoolId) && String.isNotBlank(termValue) && String.isNotBlank(yearValue) && coverageTypes.size() >0){
                relationList = [Select id, Name From Rate_Code__c where id IN (Select Rate_Code__c from
                School_Rate__c where Rate_Code__r.Educational_Institutes__c = :schoolId AND Term__c =: termValue AND Year__c =: yearValue and Coverage_Type__c IN : coverageTypes) 
                WITH SECURITY_ENFORCED ]; 
            }     
                 
            return relationList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }       
    }

    /** Create the School Invoice Record.
     * 
     * @param invRecords (Json String array of individual rows on LWC Screen)
     * @param recId (Id of Eduacational Institute)
     * @param term (Spring/Summer/Fall)
     * @param year 
     * @param selectedCollege 
     * @param invoiceType (Type of Invoice)
     * @return  `String`
     */
    @AuraEnabled
    public static String createInvoice(String invRecords, String recId, String term, String year, String selectedCollege,String invoiceType)
    {
        try 
        {
            List<School_Invoice__c> invList  = new List<School_Invoice__c>();
            List<Object> listObj = (List<Object>)System.JSON.deserializeUntyped(invRecords); 
            Set<String> ssnSet = new Set<String>();
            List<String> studentIdList = new List<String>();

            List<String> ssnBirthDateList = new List<String>();
            system.debug('listObj...'+listObj);
            String strRequestedAmount;
            String strRequestedUnits;
            String rateCode;

            for (Object s : listObj) {
                map<String,Object> mapObj = (map<String,Object>)s;
                if(mapObj != null && String.isNotBlank(String.valueOf(mapObj.get('ssn'))))
                {
                    ssnSet.add(String.valueOf(mapObj.get('ssn')));
                    ssnBirthDateList.add(String.valueOf(mapObj.get('ssn'))+ '-' +String.valueOf(mapObj.get('birthDate')));
                }
                if(mapObj != null && String.isNotBlank(String.valueOf(mapObj.get('studentId'))))
                {
                    studentIdList.add(String.valueOf(mapObj.get('studentId')));
                }
            }
            map<String, String> ssnToAccountMap = new map<String, String>();
            ssnToAccountMap = getAccountBasedOnSSN(ssnSet);

            map<String, String> studentIdToAccountMap = new map<String, String>();
            studentIdToAccountMap = getAccountBasedOnStudentId(studentIdList,recId);
           
            String dateFormat = 'yyyyMMddHHmmss';
            DateTime dt = DateTime.now();
            String batchId = dt.format(dateFormat);
            
            Account  instType = [select Institution_Type__c from Account where id =: recId WITH SECURITY_ENFORCED];

            for (Object s : listObj) {
                map<String,Object> mapObj = (map<String,Object>)s;
                if(mapObj != null && (String.isNotBlank(String.valueOf(mapObj.get('studentId'))) || String.isNotBlank(String.valueOf(mapObj.get('ssn')))))
                {
                    School_Invoice__c objInv = new School_Invoice__c();
                    objInv.Batch_Id__c = batchId;          
                    //objInv.AccountId__c = recId;
                    String beneficiaryId ;
                    if(null != ssnToAccountMap.get(String.valueOf(mapObj.get('ssn'))+ '-' +String.valueOf(mapObj.get('birthDate')))){
                        //objInv.Beneficiary_Id__c = ssnToAccMap.get(String.valueOf(mapObj.get('ssn')));
                        beneficiaryId = ssnToAccountMap.get(String.valueOf(mapObj.get('ssn'))+ '-' +String.valueOf(mapObj.get('birthDate')));
                    }

                    if(null != studentIdToAccountMap.get(String.valueOf(mapObj.get('studentId')))){
                        beneficiaryId = studentIdToAccountMap.get(String.valueOf(mapObj.get('studentId')));
                    }
                    
                    if(String.isNotBlank(beneficiaryId)){
                        objInv.Beneficiary_Id__c = beneficiaryId;
                    }else{
                        objInv.Status__c = 'Failed';
                        system.debug('status failed >>>>>>>>>>');
                    }

                    strRequestedUnits = String.valueOf(mapObj.get('creditHrBilled'));
                    if(String.isNotBlank(strRequestedUnits)){
                        objInv.Requested_Credits__c = Integer.valueOf(strRequestedUnits);
                    }
                    strRequestedAmount = String.valueOf(mapObj.get('amtBilled'));
                    if(String.isNotBlank(strRequestedAmount)){
                        objInv.Requested_Amount__c = Double.valueOf(strRequestedAmount);
                    }
                   
                    if(String.isNotBlank(String.valueOf(mapObj.get('studentId')))){
                        objInv.Student_Id__c = String.valueOf(mapObj.get('studentId'));
                    }
                    
                    System.debug('rateCode >>>>'+ mapObj.get('rateCode'));
                    rateCode = String.valueOf(mapObj.get('rateCode'));
                    if(String.isNotBlank(rateCode)){
                        objInv.Rate_Code__c = String.valueOf(mapObj.get('rateCode'));
                    }
                    objInv.Term__c = term;
                    objInv.Claim_Type__c = 'School Invoice';
                    objInv.Year__c = year;
                    objInv.Invoice_Type__c = invoiceType;
                    objInv.isBatch__c = false;
                    objInv.Reference_Number__c = String.valueOf(mapObj.get('referenceNbr'));
                    invList.add(objInv);
                }
            }
            system.debug('invList...'+invList);
            if (invList.size()>0) {
                insert invList;
            }
            return 'success';
        } catch (Exception e) {
            System.debug('Error Msg....'+e.getMessage());
            System.debug('Stack trace Msg....'+e.getStackTraceString());
            return 'error';
        }
        
    }

    /**
     *  Get beneficiary account information based on SSN
     * @param ssnSet 
     * @return  `map<String, String>`
     */
    public static  map<String, String> getAccountBasedOnSSN(Set<String> ssnSet){

        map<String, String> ssnToAccMap = new map<String, String>();
            String strBirthDate ;              
            for(Account acc : [SELECT Id, FinServ__TaxId__pc,PersonBirthdate FROM Account  WHERE FinServ__TaxId__pc IN : ssnSet])
            {
                
                if(null != acc.PersonBirthdate){
                    strBirthDate = String.valueOf(acc.PersonBirthdate).removeEnd(' 00:00:00');
                    ssnToAccMap.put(acc.FinServ__TaxId__pc+ '-' + strBirthDate, acc.Id);
                }
            }
            system.debug('ssnToAccMap >>>>>>>>>>' + ssnToAccMap);

            return ssnToAccMap;
    }

    /**
     * Get Beneficiary Accouny information based on Student ID.
     * @param studentIdList 
     * @param schoolId 
     * @return  `map<String, String>`
     */
    public static  map<String, String> getAccountBasedOnStudentId(List<String> studentIdList,String schoolId){
        map<String, String> studentIdToAccMap = new map<String, String>();
        List<Student_Detail__c> studentDetailList = [SELECT Account__r.Id, Student_Id__c FROM Student_Detail__c  
        WHERE Student_Id__c IN  : studentIdList and Educational_Institutes__c = :schoolId];
        for(Student_Detail__c std : studentDetailList)
        {
            studentIdToAccMap.put(std.Student_Id__c, std.Account__r.Id);
        }
        return studentIdToAccMap;
    }


    /** Calls the batch job to process the records submitted by upload process using CSV File.
     * 
     * @param base64Data 
     * @param recID (Id of Eduacational Institute)
     * @param fileName (Uploaded File Name)
     * @param termValue (Spring/Summer/Fall)
     * @param yearValue 
     * @param invoiceType (Type of Invoice)
     */
    @AuraEnabled
    public static void saveFile(String base64Data, String recID, String fileName,string termValue , String yearValue,String invoiceType)
    {
        String dateFormat = 'yyyyMMddHHmmss';
        DateTime dt = DateTime.now();
        String batchId = dt.format(dateFormat);
        system.debug('batchId inController...'+batchId);
        String jobId = Database.executeBatch(new SubmitSchoolInvoiceBatch(base64Data, batchId, recID, fileName,termValue,yearValue,invoiceType), 10);
    }

   
}