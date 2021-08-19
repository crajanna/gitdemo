public class ECController {
     public String email {get; set;}
     public String userName {get; set;}
     public String password {get; set {password = value == null ? value : value.trim(); } }
     public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    
      private boolean isValidPassword() {
        return password == confirmPassword;
    }
    
	 public PageReference goToGetStartedPage() {
            PageReference pageRef = new PageReference('/apex/ECRegistrationPage');
            pageRef.setRedirect(true);
            return pageRef;
        }
    
   public PageReference registerUser() {
       System.debug('objCust current value is'+email);
    try {
        
               if (!isValidPassword()) {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
                    ApexPages.addMessage(msg);
                    return null;
                }    

                 RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
                 Account newPersonAccount = new Account();
          
                 newPersonAccount.FirstName = email;
                 newPersonAccount.LastName =  userName;
                 newPersonAccount.RecordType = personAccountRecordType;
                 insert newPersonAccount; 
        
    }
    catch(System.DMLException e) {
            ApexPages.addMessages(e);
             return null;
    }  
       PageReference pageRef = new PageReference('/apex/ECPlanSelectionPage');
            pageRef.setRedirect(true);
            return pageRef;
 }
}