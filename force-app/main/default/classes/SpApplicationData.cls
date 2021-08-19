public with sharing class SpApplicationData {
    public SpApplicationData() {

    }

    @InvocableMethod
    public static List<String> getApplicationData() {
        SpApplication appData = new SpApplication(); 
        List<Contact> lstContact = new List<Contact>();
        lstContact = [SELECT Id, LastName, Email, MailingCity, Contact_Count__c FROM CONTACT WHERE Title='Scholarship' ORDER BY CreatedDate Desc LIMIT 1]; 

        system.debug('lstContact::' + lstContact);
        
        if(lstContact.size() > 0) {
            Contact myContact = lstContact[0];
            appData.Id = myContact.Id;  
            appData.Name = myContact.LastName;
            appData.Email = myContact.Email;
            appData.City = myContact.MailingCity;  
            appData.CurrentStep = (Integer)myContact.Contact_Count__c;                    
            appData.DateOfBirth = system.today();   
        } else {
            appData.CurrentStep = 1;
        }   
                  
       return new List<String>{JSON.serialize(appData)};                
    }
}