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
    }

    @isTest
    public static void TestTriggerUpdate(){
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

    @isTest
    public static void TestTriggerEST(){
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
    }

    @isTest
    public static void TestTriggerMST(){
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
    }

    @isTest
    public static void TestTriggerPST(){
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
    }

    @isTest
    public static void TestTriggerAlaska(){
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
    }

    @isTest
    public static void TestTriggerHawaii(){
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
    }
}