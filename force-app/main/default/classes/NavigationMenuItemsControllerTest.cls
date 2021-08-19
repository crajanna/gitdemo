@isTest
public with sharing class NavigationMenuItemsControllerTest {
    
    @isTest
    public static void getNavigationMenuItemsTest(){
        Network ntk = [SELECT id, name FROM Network WHERE Name = 'Scholarship' LIMIT 1];
        NavigationLinkSet navLinkSet = new NavigationLinkSet(MasterLabel='label', NetworkId=ntk.Id);
        
        Test.startTest();
         NavigationMenuItemsController.getNavigationMenuItems('Navigation Menu', 'xyz');   
        Test.stopTest();
    }
}