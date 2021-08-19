public with sharing class SpApplicationSave {
    public SpApplicationSave() {

    }

    @InvocableMethod
    public static List<Contact> createContact(List<String>  wrapperJson){
        SpApplication myApp = (SpApplication)JSON.deserialize(wrapperJson[0], SpApplication.class);

        system.debug('myApp in Save' + myApp);

        Contact myContact = new Contact(Id=myApp.Id, LastName=myApp.Name, Email=myApp.Email, MailingCity=myApp.City, Contact_Count__c=myApp.CurrentStep, Title='Scholarship');
        upsert myContact;
        
        return new List<Contact>();
    }
}