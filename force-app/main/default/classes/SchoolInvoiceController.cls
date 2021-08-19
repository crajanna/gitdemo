public with sharing class SchoolInvoiceController {
    
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
    public static List<Rate_Code__c> getRateCodes(String schoolInvoiceHeaderId) {
        try {

            School_Invoice_Header__c sih = [select Educational_Institute__r.Id , Term__c , Year__c,Invoice_Type__c from School_Invoice_Header__c where id = :schoolInvoiceHeaderId WITH SECURITY_ENFORCED];
            
            String schoolId = sih.Educational_Institute__r.Id;

            List<String> coverageTypes = new List<String>();
            if(String.isNotBlank(sih.Invoice_Type__c)){
                if(sih.Invoice_Type__c != 'Dormitory'){
                    coverageTypes = sih.Invoice_Type__c.split('/');
                }else{
                    coverageTypes.add(sih.Invoice_Type__c);
                }
            }

            List < Rate_Code__c > relationList ;           
            if(String.isNotBlank(schoolInvoiceHeaderId)){
                relationList = [Select id, Name From Rate_Code__c where id IN (Select Rate_Code__c from
                School_Rate__c where  Term__c =: sih.Term__c AND Year__c =: sih.Year__c and Coverage_Type__c IN : coverageTypes) and Educational_Institutes__c = :schoolId
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
    public static String createInvoice(String strSchoolInvoiceData)
    {
        Decimal requestedUnitValue;
        Decimal requestedAmountValue;
        Date birthDate;
        School_Invoice_Detail__c objInv = new School_Invoice_Detail__c();
        try{
            Map<String, Object> schoolInvoiceData = (Map<String, Object>)JSON.deserializeUntyped(strSchoolInvoiceData);
            String schoolHeaderId = String.valueOf(schoolInvoiceData.get('schoolHeaderId'));
            String ssn = String.valueOf(schoolInvoiceData.get('ssn'));
            String studentId = String.valueOf(schoolInvoiceData.get('studentId'));
            String strBirthDate = String.valueOf(schoolInvoiceData.get('birthDate'));
            String strRequestedUnits = String.valueOf(schoolInvoiceData.get('requestedUnitValue'));
            String rateCodeValue = String.valueOf(schoolInvoiceData.get('rateCodeValue'));
            String strRequestedAmount = String.valueOf(schoolInvoiceData.get('requestedAmountValue'));
            String referenceNbr = String.valueOf(schoolInvoiceData.get('referenceNbr'));

            if(String.isNotBlank(strRequestedUnits)){
                requestedUnitValue = Integer.valueOf(strRequestedUnits);
            }

            if(String.isNotBlank(strRequestedAmount)){
                requestedAmountValue = Integer.valueOf(strRequestedAmount);
            }

            if(String.isNotBlank(strBirthDate)){
                birthDate = Date.valueOf(strBirthDate);
            }          

            String beneficiaryId ;
            if(String.isNotBlank(ssn) && null != birthDate){
                beneficiaryId = getAccountBasedOnSSNAndBirthDate(ssn,birthDate);
            }

            if(String.isNotBlank(studentId)){
                beneficiaryId = getAccountBasedOnStudentId(studentId,schoolHeaderId);
            }

            system.debug('beneficiaryId >>>>>' + beneficiaryId);

            if(String.isNotBlank(beneficiaryId)){
                objInv.Beneficiary_Id__c = beneficiaryId;
            }else{
                objInv.Status__c = 'Failed';
                system.debug('status failed >>>>>>>>>>');
            }
            objInv.School_Invoice_Header__c = schoolHeaderId;
            objInv.Requested_Credits__c = requestedUnitValue;
            objInv.Requested_Amount__c = requestedAmountValue;
            objInv.Student_Id__c = studentId;
            objInv.SSN__c = ssn;
            objInv.BirthDate__c = birthDate;

            if(String.isNotBlank(rateCodeValue)){
                objInv.Rate_Code__c = rateCodeValue;
            }

            objInv.Reference_Number__c = referenceNbr;     

            insert objInv;

    }catch(Exception e){
        throw new AuraHandledException(e.getMessage());
    }
        return objInv.Id;
    }

        /**
     *  Get beneficiary account information based on SSN and BirthDate
     * @param ssn 
     * @param birthDate 
     * @return  `String`
     */
    public static String getAccountBasedOnSSNAndBirthDate(String ssn , Date birthDate){

        map<String, String> ssnToAccMap = new map<String, String>();
            String strBeneficiaryId ;              
            for(Account acc : [SELECT Id, FinServ__TaxId__pc,PersonBirthdate FROM Account  WHERE FinServ__TaxId__pc = : ssn and PersonBirthdate = :birthDate])
            {
                
                if(null != acc){
                    strBeneficiaryId = acc.Id;
                }
            }
            system.debug('strBeneficiaryId >>>>>>>>>>' + strBeneficiaryId);

            return strBeneficiaryId;
    }

    /**
     * Get Beneficiary Accouny information based on Student ID.
     * @param studentId 
     * @return  `String`
     */
    public static  String getAccountBasedOnStudentId(String studentId,String schoolHeaderId){
        String beneficiaryId;

        School_Invoice_Header__c sih = [select Educational_Institute__r.Id , Term__c , Year__c from School_Invoice_Header__c where id = :schoolHeaderId WITH SECURITY_ENFORCED];
            
        String schoolId = sih.Educational_Institute__r.Id;

        List<Student_Detail__c> studentDetailList = [SELECT Account__r.Id, Student_Id__c FROM Student_Detail__c  
                    WHERE Student_Id__c =  : studentId and Educational_Institutes__c = :schoolId];
        for(Student_Detail__c std : studentDetailList)
        {
            beneficiaryId = std.Account__r.Id;
        }
        return beneficiaryId;
    }
}