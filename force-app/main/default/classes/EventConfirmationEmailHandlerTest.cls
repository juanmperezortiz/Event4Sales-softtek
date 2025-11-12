/**
 * @description       : 
 * @author            : Eduardo Hernandez
 * @group             : 
 * @last modified on  : 11-03-2023
 * @last modified by  : Eduardo Hernandez
**/
@isTest
private class EventConfirmationEmailHandlerTest {
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

        Custom_Event__c testEventHost = new Custom_Event__c();
        User userEmail = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        testEventHost.Name = 'Test Event Host';
        testEventHost.Timezone__c = 'CST';
        testEventHost.Address__c = 'Address';
        testEventHost.Duration__c = 60;
        testEventHost.Minutes_Or_Hours__c = 'Minutes';
        testEventHost.Date__c = Datetime.now() + 8;
        testEventHost.Host__c = userEmail.Id;
        insert testEventHost;

        Id eventIdHost = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event Host'].Id;
        Event_Confirmation__c testConfirmHost = new Event_Confirmation__c(
            Guest_First_Name__c = 'First Host', Guest_Last_Name__c = 'Last Host',
            Email__c = 'email@email.com', Check_In__c = false,
            Custom_Event__c = eventIdHost
        );

        Event_Question__c eventQuestion = new Event_Question__c(Name = 'Question', Custom_Event__c = eventId);
        insert eventQuestion;

        insert testConfirmHost;

        
    }

    @isTest
    public static void registrationEmailTest(){
        EventConfirmationEmailHandler eventConfirmationEmailHandler = new EventConfirmationEmailHandler();
        Event_Confirmation__c testConfirm = [SELECT Id, EvEmail__c, EvName__c, EvDateStartDisplay__c, EvAddress__c, EvHostName__c, EvDateStart__c,
            EvDateEnd__c, Email__c, URL__c, Confirmation_Code__c
            FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
        Test.startTest();
        Messaging.SingleEmailMessage event = eventConfirmationEmailHandler.registrationEmail(testConfirm);
        System.assert(event != null);
        Test.stopTest();
    }

    @isTest
    public static void registrationEmailHostTest(){
        EventConfirmationEmailHandler eventConfirmationEmailHandler = new EventConfirmationEmailHandler();
        Event_Confirmation__c testConfirm = [SELECT Id, EvEmail__c, EvName__c, EvDateStartDisplay__c, EvAddress__c, EvHostName__c, EvDateStart__c,
            EvDateEnd__c, Email__c, URL__c, Confirmation_Code__c
            FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First Host' LIMIT 1];
        Test.startTest();
        Messaging.SingleEmailMessage event = eventConfirmationEmailHandler.registrationEmail(testConfirm);
        System.assert(event != null);
        Test.stopTest();
    }

    @isTest
    public static void hostOrganizerEmailTest(){
        EventConfirmationEmailHandler eventConfirmationEmailHandler = new EventConfirmationEmailHandler();
        Event_Confirmation__c testConfirm = [SELECT Id, EvEmail__c, EvName__c, EvDateStartDisplay__c, EvAddress__c, EvHostName__c, EvDateStart__c,
            EvDateEnd__c, Email__c, Custom_Event__c, Guest_First_Name__c, Guest_Last_Name__c, Contact__c
            FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
        Test.startTest();
        Event_Question__c eventQuestion = [SELECT Id, Name, Custom_Event__c FROM Event_Question__c WHERE Name = 'Question'];
        Answer__c ans = new Answer__c(Name = '1', Event_Question__c = eventQuestion.Id, Event_Confirmation__c = testConfirm.Id);
        List<Answer__c> answers = new List<Answer__c>();
        answers.add(ans);
        Messaging.SingleEmailMessage event = eventConfirmationEmailHandler.hostOrganizerEmail(testConfirm, answers);
        System.assert(event != null);
        Test.stopTest();
    }
}