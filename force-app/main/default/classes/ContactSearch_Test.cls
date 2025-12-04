/**
 * @description       : Test class
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
@isTest
private class ContactSearch_Test {

    /**Generic Event */
    final Static String EVENTNAME = 'Test Event';

    /**Generic LastName */
    final Static String LASTNAME = 'LastNameSmith';

    @TestSetup
    static void makeData() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User standardUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        insert standardUser;

        System.runAs(standardUser) {
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
            final Contact contactRec = new Contact();
            contactRec.LastName = LASTNAME;
            contactRec.Email = 'EMAILTESTING@TEST.COM';
            insert contactRec;
            Event_Confirmation__c testConfirm = new Event_Confirmation__c(
                Guest_First_Name__c = 'First', Guest_Last_Name__c = 'Last',
                Email__c = 'email@email.com', Check_In__c = false,
                Custom_Event__c = testEventHost.Id,
                Contact__c = contactRec.Id
            );
            insert testConfirm;
        }
    }

    @isTest
    private static void getContacts() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Test.startTest();
            List<Contact> lsContacst = [Select Id,Name from Contact];
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = lsContacst[0].Id;
            Test.setFixedSearchResults(fixedSearchResults);
            final List<Contact> lstContacts = ContactSearch.getContacts(LASTNAME);
            System.assert(lstContacts.size()>0, 'Contact find');
            Test.stopTest();
        }
    }

    @isTest
    private static void getAllReadyInvitedContacts() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Test.startTest();
            List<Contact> lsContacst = [Select Id,Name from Contact];
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = lsContacst[0].Id;
            Test.setFixedSearchResults(fixedSearchResults);
            final Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
            final List<Event_Confirmation__c> lstConfirms = ContactSearch.getAllReadyInvitedContacts(eventId);
            System.assert(lstConfirms.size()>0, 'Contact find');
            Test.stopTest();
        }
    }

    @isTest
    private static void createInvitation() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Test.startTest();
            List<Contact> lsContacst = [Select Id,Name from Contact];
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = lsContacst[0].Id;
            Test.setFixedSearchResults(fixedSearchResults);
            final List<Contact> lstContacts = ContactSearch.getContacts(LASTNAME);
            final List<Id> lstContIds = new List<Id>{lstContacts[0].Id};
            final Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
            final List<Event_Confirmation__c> lstConfirms = ContactSearch.createInvitation(lstContIds, eventId);
            System.assert(lstConfirms.size()>0, 'Confirmation find');
            Test.stopTest();
        }
    }

    @isTest
    private static void sendEmails() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Test.startTest();
            List<Contact> lsContacst = [Select Id,Name from Contact];
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = lsContacst[0].Id;
            Test.setFixedSearchResults(fixedSearchResults);
            final Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
            ContactSearch.sendEmails(eventId);
            Integer invocations = Limits.getEmailInvocations();
            System.AssertEquals(1, invocations, 'An email should be sent');
            Test.stopTest();
        }
    }
}