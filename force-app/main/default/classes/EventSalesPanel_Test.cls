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
    }

    @isTest
    private static void findConfigurations() {
        Test.startTest();
            Map<String, Object> findConfigurations = EventSalesPanel.findConfigurations();
        Test.stopTest();
        System.assert(findConfigurations.containsKey('isOk'), 'Params find');
    }

    @isTest
    private static void updateConfigurations() {
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