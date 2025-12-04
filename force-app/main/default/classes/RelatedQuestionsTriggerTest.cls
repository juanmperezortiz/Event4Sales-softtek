/**
 * @description       :
 * @author            : Eduardo Hernandez Cuamatzi
 * @group             :
 * @last modified on  : 11-06-2023
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
@isTest
private class RelatedQuestionsTriggerTest {
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
        testEvent.Status__c = 'Published';
        testEvent.Purpose__c = 'Purpose';
        testEvent.Type_of_Event__c = 'Type';
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
    public static void testTriggerInsert(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
            List<Event_Question__c> questionsList = new List<Event_Question__c>();
            for (Integer i = 1; i <= 5; i++) {
                Event_Question__c eventQuestion = new Event_Question__c(Name = 'Question ' + i, Custom_Event__c = eventId);
                questionsList.add(eventQuestion);
            }

            insert questionsList;
            Event_Question__c eventQuestionError = new Event_Question__c(Name = 'Question 6', Custom_Event__c = eventId);
            Boolean exceptionOcurred = false;
            try {
                insert eventQuestionError;
            } catch (Exception e) {
                exceptionOcurred = true;
            }
            System.assert(exceptionOcurred, 'Exception Worked');
        }
    }

    @isTest
    public static void testTriggerUpdate(){
        User standardUser = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];
        System.runAs(standardUser) {
            Custom_Event__c event = [SELECT Id, Status__c FROM Custom_Event__c WHERE Name = 'Test Event'];
            event.Status__c = 'Published';
            update event;
            Event_Question__c eventQuestionError = new Event_Question__c(Name = 'Question 6', Custom_Event__c = event.Id);
            insert eventQuestionError;
            eventQuestionError.Name = 'Question Error';
            Boolean exceptionOcurred = false;
            try {
                update eventQuestionError;
            } catch (Exception e) {
                exceptionOcurred = true;
            }
            System.assert(exceptionOcurred, 'Exception Worked');
        }
    }
}