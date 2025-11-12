/**
 * @description       : Test class
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
@isTest
private class Event4Sales_PostInstallPackage_Test {
    
    @isTest
    static void testInstallScript() {
        Event4Sales_PostInstallPackage postinstall = new Event4Sales_PostInstallPackage();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1,0), true);
        List<Event4SalesParams__c> lstParams = [Select Id, Name from Event4SalesParams__c];
        System.assertEquals(lstParams.size(), 9, 'Panel configurations success');
    }
}