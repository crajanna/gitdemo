/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class FpChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;} 
    public String errors{get; private set;}       
    
    public PageReference changePassword() {
        PageReference page = Site.changePassword(newPassword, verifyNewPassword, oldpassword); 

        List<Apexpages.Message> messages = ApexPages.getMessages();
        for (Apexpages.Message error : messages)  {
            String strError = error.getSummary();
            if(strError != null){
                errors = '<br>' + strError.replace('Error:','');
            }
        }

        return page;    
    }     
    
   	public FpChangePasswordController() {}
}