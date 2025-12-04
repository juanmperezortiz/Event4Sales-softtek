/**
 * @description       :
 * @author            : Eduardo Hernandez
 * @group             :
 * @last modified on  : 11-03-2023
 * @last modified by  : Eduardo Hernandez
**/
@isTest
private class CustomEventTriggerTest {

    @TestSetup
    static void makeData() {
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
    public static void testTriggerUpdate(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Custom_Event__c testEvent = new Custom_Event__c();
            testEvent.Name = 'Test Event';
            testEvent.Timezone__c = 'CST';
            testEvent.Address__c = 'Address';
            testEvent.Duration__c = 60;
            testEvent.Minutes_Or_Hours__c = 'Minutes';
            testEvent.Date__c = Datetime.now() + 8;
            testEvent.Host__c = UserInfo.getUserId();
            testEvent.Status__c = 'Published';
            testEvent.Purpose__c = 'Purpose';
            testEvent.Type_of_Event__c = 'Type';
            insert testEvent;
            testEvent.Timezone__c = 'EST';
            Boolean exceptionOcurred = false;
            try {
                update testEvent;
            } catch (Exception e) {
                exceptionOcurred = true;
            }
            System.assert(exceptionOcurred, 'Exception Worked');
        }
    }

    @isTest
    public static void testTriggerEST(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Custom_Event__c testEvent = new Custom_Event__c();
            testEvent.Name = 'Test Event';
            testEvent.Timezone__c = 'EST';
            testEvent.Address__c = 'Address';
            testEvent.Duration__c = 60;
            testEvent.Minutes_Or_Hours__c = 'Minutes';
            testEvent.Date__c = Datetime.now() + 8;
            testEvent.Host__c = UserInfo.getUserId();
            testEvent.Status__c = 'Published';
            insert testEvent;
            List<Custom_Event__c> eventList = [SELECT Id FROM Custom_Event__c];
            System.assertEquals(1, eventList.size(), 'Event list size should be 1');
        }
    }

    @isTest
    public static void testTriggerMST(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Custom_Event__c testEvent = new Custom_Event__c();
            testEvent.Name = 'Test Event';
            testEvent.Timezone__c = 'MST';
            testEvent.Address__c = 'Address';
            testEvent.Duration__c = 60;
            testEvent.Minutes_Or_Hours__c = 'Minutes';
            testEvent.Date__c = Datetime.now() + 8;
            testEvent.Host__c = UserInfo.getUserId();
            testEvent.Status__c = 'Published';
            insert testEvent;
            List<Custom_Event__c> eventList = [SELECT Id FROM Custom_Event__c];
            System.assertEquals(1, eventList.size(), 'Event list size should be 1');
        }
    }

    @isTest
    public static void testTriggerPST(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Custom_Event__c testEvent = new Custom_Event__c();
            testEvent.Name = 'Test Event';
            testEvent.Timezone__c = 'PST';
            testEvent.Address__c = 'Address';
            testEvent.Duration__c = 60;
            testEvent.Minutes_Or_Hours__c = 'Minutes';
            testEvent.Date__c = Datetime.now() + 8;
            testEvent.Host__c = UserInfo.getUserId();
            testEvent.Status__c = 'Published';
            insert testEvent;
            List<Custom_Event__c> eventList = [SELECT Id FROM Custom_Event__c];
            System.assertEquals(1, eventList.size(), 'Event list size should be 1');
        }
    }

    @isTest
    public static void testTriggerAlaska(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Custom_Event__c testEvent = new Custom_Event__c();
            testEvent.Name = 'Test Event';
            testEvent.Timezone__c = 'Alaska';
            testEvent.Address__c = 'Address';
            testEvent.Duration__c = 60;
            testEvent.Minutes_Or_Hours__c = 'Minutes';
            testEvent.Date__c = Datetime.now() + 8;
            testEvent.Host__c = UserInfo.getUserId();
            testEvent.Status__c = 'Published';
            insert testEvent;
            List<Custom_Event__c> eventList = [SELECT Id FROM Custom_Event__c];
            System.assertEquals(1, eventList.size(), 'Event list size should be 1');
        }
    }

    @isTest
    public static void testTriggerHawaii(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Custom_Event__c testEvent = new Custom_Event__c();
            testEvent.Name = 'Test Event';
            testEvent.Timezone__c = 'Hawaii';
            testEvent.Address__c = 'Address';
            testEvent.Duration__c = 60;
            testEvent.Minutes_Or_Hours__c = 'Minutes';
            testEvent.Date__c = Datetime.now() + 8;
            testEvent.Host__c = UserInfo.getUserId();
            testEvent.Status__c = 'Published';
            insert testEvent;
            List<Custom_Event__c> eventList = [SELECT Id FROM Custom_Event__c];
            System.assertEquals(1, eventList.size(), 'Event list size should be 1');
        }
    }
}