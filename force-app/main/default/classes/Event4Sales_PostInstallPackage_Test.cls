/**
 * @description       : Test Class
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
@isTest
public class ScheduledEventCalendar_Test {

    final Static String EVENTNAME = 'Test Event';
    @TestSetup
    static void makeData() {
        Event4Sales_PostInstallPackage postinstall = new Event4Sales_PostInstallPackage();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1,0), true);
        Custom_Event__c testEvent = new Custom_Event__c();
        testEvent.Name = EVENTNAME;
        testEvent.Address__c = 'Address';
        testEvent.Duration__c = 60;
        testEvent.Minutes_Or_Hours__c = 'Minutes';
        testEvent.Host__c = UserInfo.getUserId();
        insert testEvent;

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
    private static void findTimeZones() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            final Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name =: EVENTNAME].Id;
            Test.startTest();
                final Map<String, Object> response = ScheduledEventCalendar_Ctrl.findTimeZones(eventId);
                System.assertEquals((Boolean)response.get('isOk'), true, 'Response is not OK');
            Test.stopTest();
        }
    }

    @isTest
    private static void updateEvent() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            final Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
            final String timeZoneStr = '(GMT+00:00) Greenwich Mean Time (Africa/Abidjan)';
            final String timeselect = String.valueOf(System.now().addDays(1));
            Test.startTest();
                ScheduledEventCalendar_Ctrl.updateEvent(eventId, timeZoneStr, timeselect);
                final Custom_Event__c event = [SELECT Id,Datetime_Selected__c FROM Custom_Event__c WHERE Name = 'Test Event'];
                System.assertEquals(event.Datetime_Selected__c, timeselect, 'Date does not match');
            Test.stopTest();
        }
    }

    @isTest
    private static void initTimeZone() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            final Custom_Event__c eventRecor = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'];
            eventRecor.Datetime_Selected__c = String.valueOf(System.now().addDays(1));
            eventRecor.Time_ZoneStr__c = '(GMT+00:00) Greenwich Mean Time (Africa/Abidjan)';
            update eventRecor;
            Test.startTest();
                Map<String, Object> updateEventResult = ScheduledEventCalendar_Ctrl.findTimeZones(eventRecor.Id);
                system.assertEquals(updateEventResult.get('isOk'), true, 'Response is not ok');
            Test.stopTest();
        }
    }
}