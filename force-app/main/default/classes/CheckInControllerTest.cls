/**
 * @description       :
 * @author            : Eduardo Hernandez
 * @group             :
 * @last modified on  : 11-03-2023
 * @last modified by  : Eduardo Hernandez
**/
@isTest
private class CheckInControllerTest {

    @TestSetup
    static void makeData() {
        Event4Sales_PostInstallPackage postinstall = new Event4Sales_PostInstallPackage();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1,0), true);
        Custom_Event__c testEvent = new Custom_Event__c();
        testEvent.Name = 'Test Event';
        testEvent.Timezone__c = 'CST';
        testEvent.Address__c = 'Address';
        testEvent.Duration__c = 60;
        testEvent.Minutes_Or_Hours__c = 'Minutes';
        testEvent.Date__c = Datetime.now() + 8;
        testEvent.Host__c = UserInfo.getUserId();
        insert testEvent;
        Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
        Event_Confirmation__c testConfirm = new Event_Confirmation__c(
            Guest_First_Name__c = 'First', Guest_Last_Name__c = 'Last',
            Email__c = 'email@email.com', Check_In__c = false,
            Custom_Event__c = eventId
        );
        insert testConfirm;

        Event_Question__c eventQuestion = new Event_Question__c(Name = 'Question', Custom_Event__c = eventId);
        insert eventQuestion;

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
    public static void getEventConfirmationTest(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Event_Confirmation__c testConfirm = [SELECT Id, Confirmation_Code__c FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
            Test.startTest();
            Event_Confirmation__c event = CheckInController.getEventConfirmation(testConfirm.Id);
            System.assert(testConfirm.Confirmation_Code__c == event.Confirmation_Code__c, 'Confirmation code does not match');
            Test.stopTest();
        }
    }

    @isTest
    public static void getEventConfirmationTestExcep(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Test.startTest();
            Event_Confirmation__c event = CheckInController.getEventConfirmation(UserInfo.getUserId());
            System.assertEquals(event, null, 'Query exception');
            Test.stopTest();
        }
    }

    @isTest
    public static void showEventTest(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Event_Confirmation__c testConfirm = [SELECT Id, Confirmation_Code__c FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
            Test.startTest();
            Map<Integer, Datetime> event = CheckInController.showEvent(testConfirm.Id);
            System.assert(event != null, 'Event map is null');
            Test.stopTest();
        }
    }

    @isTest
    public static void updateEventConfirmationTest(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Event_Confirmation__c testConfirm = [SELECT Id, Check_In__c FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
            Test.startTest();
            CheckInController.updateEventConfirmation(testConfirm.Id);
            Event_Confirmation__c afterConfirm = [SELECT Id, Check_In__c FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
            System.assert(testConfirm.Check_In__c != afterConfirm.Check_In__c, 'Check in value does not match');
            Test.stopTest();
        }
    }
}