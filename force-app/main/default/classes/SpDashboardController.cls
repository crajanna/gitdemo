public with sharing class SpDashboardController {
    public SpDashboardController() {

    }

    /*
    @AuraEnabled(cacheable=true)
    public static SpApplication getApplicationData(String recordId) {
        SpApplication appData = new SpApplication(); 
        List<Contact> lstContact = [SELECT Id, LastName, Email, MailingCity, Contact_Count__c FROM CONTACT WHERE Title='Scholarship' ORDER BY CreatedDate Desc LIMIT 1]; 
        
        if(lstContact.size() > 0) {
            Contact myContact = lstContact[0];
            appData.Id = myContact.Id;  
            appData.Name = myContact.LastName;
            appData.Email = myContact.Email;
            appData.City = myContact.MailingCity;  
            appData.CurrentStep = (Integer)myContact.Contact_Count__c;                    
            appData.DateOfBirth = system.today();     
        }                  
       return appData;                
    }

    @InvocableMethod
    public static List<String> createContact(List<String>  wrapperJson){
        SpApplication myApp = (SpApplication)JSON.deserialize(wrapperJson[0], SpApplication.class);

        Contact myContact = new Contact(Id=myApp.Id, LastName=myApp.Name, Email=myApp.Email, MailingCity=myApp.City, Contact_Count__c=myApp.CurrentStep, Title='Scholarship');
        upsert myContact;
        
        return new List<String>();
    }
    */
}