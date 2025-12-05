/**
 * @description       : Test class
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
@isTest
private class AdditionalOrganaizerHandler_Test {

    /**Generic Event */
    final Static String EVENTNAME = 'Test Event';

    /**Generic LastName */
    final Static String LASTNAME = 'LastNameSmith';

    @TestSetup
    static void makeData() {
        Event4Sales_PostInstallPackage postinstall = new Event4Sales_PostInstallPackage();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1,0), true);
        Custom_Event__c testEventHost = new Custom_Event__c();
        User userEmail = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        testEventHost.Name = EVENTNAME;
        testEventHost.Timezone__c = 'CST';
        testEventHost.Address__c = 'Address';
        testEventHost.Duration__c = 60;
        testEventHost.Minutes_Or_Hours__c = 'Minutes';
        testEventHost.Date__c = Datetime.now() + 8;
        testEventHost.Host__c = userEmail.Id;
        insert testEventHost;
        Profile profileUser = [SELECT Id FROM Profile WHERE Name='Standard User'];
        final String userEmailStr = 'standarduser'+ String.valueOf(Integer.valueOf(Math.random() * 100)) +'@testorg.com';
        User extraUser = new User(
            Alias = 'standt', Email= userEmailStr,
            EmailEncodingKey='UTF-8', LastName= LASTNAME, LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = profileUser.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName=userEmailStr);
        insert extraUser;
        }

    @isTest
    static void additionalOrganizer() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt'];
        System.runAs(standardUser) {
            final Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name =: EVENTNAME].Id;
            final Id organaizerId = [SELECT Id FROM User WHERE LastName =: LASTNAME].Id;
            Additional_Organizer__c extraOrganizer = new Additional_Organizer__c();
            extraOrganizer.Custom_Event__c = eventId;
            extraOrganizer.User__c = organaizerId;
            Test.startTest();
                insert extraOrganizer;
            Test.stopTest();
            System.assertEquals(String.isNotEmpty(extraOrganizer.Id), true, 'Extra Organaizer success');
        }
    }


    @isTest
    static void customEventUpdate() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt'];
        System.runAs(standardUser) {
            final Custom_Event__c eventRecord = [SELECT Id,Date__c FROM Custom_Event__c WHERE Name =: EVENTNAME];
            eventRecord.Date__c = eventRecord.Date__c.addDays(5);
            Test.startTest();
                update eventRecord;
            Test.stopTest();
            System.assertEquals(String.isNotEmpty(eventRecord.Id), true, 'Update success');
        }
    }


    @isTest
    static void customEventUpdateError() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt'];
        System.runAs(standardUser) {
            final Custom_Event__c eventRecord = [SELECT Id,Date__c FROM Custom_Event__c WHERE Name =: EVENTNAME];
            eventRecord.Status__c = 'Published';
            Test.startTest();
                update eventRecord;
                eventRecord.Date__c = eventRecord.Date__c.addDays(-5);
                Database.SaveResult srList = Database.update(eventRecord, false);
            Test.stopTest();
            System.assertEquals(srList.isSuccess(), false, 'Update error');
        }
    }
}