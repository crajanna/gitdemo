trigger SchoolInvoiceTrigger on School_Invoice__c(after insert) {  
        for (School_Invoice__c sInvoice: Trigger.New) {
             SchoolInvoiceCalculations.processBeneficiaryClaims(string.valueof(sInvoice.Beneficiary_Id__c), 
            null, sInvoice.Claim_Type__c, sInvoice.Term__c, sInvoice.Year__c, 
            sInvoice.Requested_Credits__c, sInvoice.Requested_Amount__c,sInvoice.Batch_Id__c,
            sInvoice.Uploaded_File_Link__c,sInvoice.Rate_Code__c,sInvoice.Description__c,sInvoice.Institution_Type__c,sInvoice.Id,sInvoice.Status__c);
        }
}