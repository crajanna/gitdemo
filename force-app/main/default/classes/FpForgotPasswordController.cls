/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class FpForgotPasswordController {
    public String username {get; set;}   
    public String errors{get; private set;}   
       	
  	/*public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
        
        List<Apexpages.Message> messages = ApexPages.getMessages();
        for (Apexpages.Message error : messages)  {
            String strError = error.getSummary();
            if(strError != null && strError == 'Invalid Email Address'){
                errors = 'Invalid Username';
            }
        }

        pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
    
    public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null; 
  	}*/
    
    @AuraEnabled(cacheable=true)
  	public static Boolean forgotPassword(String username) {
  		boolean success = Site.forgotPassword(username);
  		System.debug('success ? '+success);
  		if (success) {  			
  			return true;
  		}
  		return false;
  	}
    
    
}