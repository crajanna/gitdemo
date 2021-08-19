@isTest
public class FPForgotPasswordControllerTest {
	 
    
    @IsTest(SeeAllData=true) public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	Test.startTest();
        FPForgotPasswordController controller = new FPForgotPasswordController();
    	//controller.username = 'test@salesforce.com';     	
    	Test.stopTest();
    	System.assertEquals(FPForgotPasswordController.forgotPassword('test1@salesforce.com'),false); 
    } 
    
    @IsTest(SeeAllData=true) public static void testForgotPasswordController1() {
    	// Instantiate a new controller with all parameters in the page
    	FPForgotPasswordController controller = new FPForgotPasswordController(); 
    	//controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    }
}