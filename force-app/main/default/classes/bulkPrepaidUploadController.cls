public with sharing class bulkPrepaidUploadController
{
    @AuraEnabled
    public static list<InsurancePolicy> createPrepaidPlans(Id idContentDocument)
    {
        list<InsurancePolicy> lst_TotalPolicyCreated = new list<InsurancePolicy>();
        if(idContentDocument != null) 
        {
             // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

            for(Integer i = 1; i < lstCSVLines.size(); i++)
            {
                 list<InsurancePolicy> lstPolicyToInsert = new list<InsurancePolicy>();
                 list<String> csvR = lstCSVLines[i].split(',');
                 lstPolicyToInsert = PrepaidBulkPolicyController.createPolicy(csvR[0],Id.valueOf(csvR[1]),csvR[2],csvR[3],csvR[4],Decimal.valueOf(csvR[5]),csvR[6],csvR[7],csvR[8]);
                 lst_TotalPolicyCreated.addAll(lstPolicyToInsert);
            }
        }
        return lst_TotalPolicyCreated;  
    }
}