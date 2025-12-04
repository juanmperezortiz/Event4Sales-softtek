/**
 * @description       : Test class
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
@isTest
private class EventSalesPanel_Test {
    /**Generic Event */
    final Static String EVENTNAME = 'Test Event';

    /**Generic LastName */
    final Static String LASTNAME = 'LastNameSmith';

    @TestSetup
    static void makeData(){
        Event4Sales_PostInstallPackage postinstall = new Event4Sales_PostInstallPackage();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1,0), true);

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        insert u;
    }

    @isTest
    private static void findConfigurations() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Test.startTest();
                Map<String, Object> findConfigurations = EventSalesPanel.findConfigurations();
            Test.stopTest();
            System.assert(findConfigurations.containsKey('isOk'), 'Params find');
        }
    }

    @isTest
    private static void updateConfigurations() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            final List<EventSalesPanel.EventsParams> params = new List<EventSalesPanel.EventsParams>();
            final EventSalesPanel.EventsParams param = new EventSalesPanel.EventsParams();
            final Id paramId = [Select Id from Event4SalesParams__c where Configuration__c = 'TriggerAdditionalHost'].Id;
            param.integerParam = 0;
            param.isBoolean = true;
            param.booleanParam = false;
            param.isInteger = false;
            param.paramName = 'TriggerAdditionalHost';
            param.paramLabel = 'Additional Organizar Trigger';
            param.paramId = paramId;
            params.add(param);
            final String paramJson = JSON.serialize(params);
            Test.startTest();
                Map<String, Object> findConfigurations = EventSalesPanel.updateConfigurations(paramJson);
            Test.stopTest();
            System.assert(findConfigurations.containsKey('isOk'), 'Params find');
        }
    }
}