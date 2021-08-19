public with sharing class SchoolInvoiceCalculations {

    public static void processBeneficiaryClaims(string beneficiaryId, string schoolId, string claimTypeValue, 
    string termValue, string yearValue, decimal requestedUnitValue, Decimal requestedAmountValue, string batchId, 
    string URL,String rateCode , String rateCodeDesc, String instType, String schoolInvoiceId,String status) {

                string resultStr;
                String policyPaymentMethod;
                Boolean paymentMethodUpdated = false;
                Boolean isSchoolInvoice = true;
                List < Map < String, Object >> files;

                if(status == 'Pending'){
                  /*  list < InsurancePolicyParticipant > partList = [select InsurancePolicyId
                    from InsurancePolicyParticipant where PrimaryParticipantAccountId =: beneficiaryId WITH SECURITY_ENFORCED order by CreatedDate asc
                    ];
            
                    List <String> policyIds = new List < String > ();
            
                    if (!partList.isEmpty()) {
                        for (InsurancePolicyParticipant pr: partList) {
                            policyIds.add(pr.InsurancePolicyId);
                    }*/

                    Map<String, Object> mapData = new Map<String, Object>();
                    mapData.put('schoolId', schoolId);
                    mapData.put('termValue', termValue);
                    mapData.put('yearValue', yearValue);
                    mapData.put('claimTypeValue', claimTypeValue);
                    mapData.put('requestedUnitValue', requestedUnitValue);
                    mapData.put('requestedAmountValue', requestedAmountValue);
                    mapData.put('files', files);
                    //mapData.put('policyId', policyIds[0]);
                    mapData.put('isSchoolInvoice', isSchoolInvoice);
                    mapData.put('paymentMethodUpdated', paymentMethodUpdated);
                    mapData.put('rateCodeValue', rateCode);
                    mapData.put('schoolInvoiceId', schoolInvoiceId);
                    mapData.put('batchId', batchId);

                    String jsonString = JSON.Serialize(mapData);

                    System.debug('jsonString >>>>'+jsonString);

                    ClaimProcessController.submitClaim(jsonString,null,null);  
                          
            }
}

}