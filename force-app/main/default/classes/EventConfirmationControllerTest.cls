/**
 * @description       : PostInstall Package
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
@isTest
private class EventConfirmationControllerTest {

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
        Contact con = new Contact(Email = 'email@email.com', FirstName = 'First', LastName = 'Last');
    }

    @isTest
    public static void getCustomEventTest(){
        Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
        Test.startTest();
        Map<String, Object> event = EventConfirmationController.getCustomEvent(eventId);
        System.assert(event.get('eventRecord') != null);
        Test.stopTest();
    }

    @isTest
    public static void createEventConfirmationTest(){
        Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
        String firstName = 'First';
        String lastName = 'Last';
        String email = 'email@email.com';
        Test.startTest();
        Id confId = EventConfirmationController.createEventConfirmation(eventId, firstName, lastName, email);
        System.assert(confId != null);
        Test.stopTest();
        
    }

    @isTest
    public static void answersListTestTrue(){
        List<Map<String,String>> listMap = new List<Map<String,String>>();
        Map<String,String> mapAnswer = new Map<String,String>();
        Event_Confirmation__c testConfirm = [SELECT Id FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
        Event_Question__c eventQuestionId = [SELECT Id FROM Event_Question__c WHERE Name =: 'Question' LIMIT 1];
        Test.startTest();
        
        mapAnswer.put('key', eventQuestionId.Id);
        mapAnswer.put('value', 'true');
        listMap.add(mapAnswer);
        EventConfirmationController.answersList(listMap, testConfirm.Id);
        Test.stopTest();
    }

    @isTest
    public static void answersListTestFalse(){
        List<Map<String,String>> listMap = new List<Map<String,String>>();
        Map<String,String> mapAnswer = new Map<String,String>();
        Event_Confirmation__c testConfirm = [SELECT Id FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
        Event_Question__c eventQuestionId = [SELECT Id FROM Event_Question__c WHERE Name =: 'Question' LIMIT 1];
        Test.startTest();
        
        mapAnswer.put('key', eventQuestionId.Id);
        mapAnswer.put('value', 'false');
        listMap.add(mapAnswer);
        EventConfirmationController.answersList(listMap, testConfirm.Id);
        Test.stopTest();
    }

    @isTest
    public static void answersListTestValue(){
        List<Map<String,String>> listMap = new List<Map<String,String>>();
        Map<String,String> mapAnswer = new Map<String,String>();
        Event_Confirmation__c testConfirm = [SELECT Id FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
        Event_Question__c eventQuestionId = [SELECT Id FROM Event_Question__c WHERE Name =: 'Question' LIMIT 1];
        Test.startTest();
        
        mapAnswer.put('key', eventQuestionId.Id);
        mapAnswer.put('value', 'value');
        listMap.add(mapAnswer);
        EventConfirmationController.answersList(listMap, testConfirm.Id);
        Test.stopTest();
    }

    @isTest
    private static void generateICS() {
        final Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
        final Event_Confirmation__c testConfirm = [Select Id from Event_Confirmation__c where Custom_Event__c =: eventId];
        final Map<String, Object> response = EventConfirmationController.generateICS(testConfirm.Id);
        System.assert(response.containsKey('isOk'), 'ICS Generated');
    }

    @isTest
    public static void updateAnsware() {
        final Custom_Event__c eventRecord = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'];
        Event_Confirmation__c testConfirm = [SELECT Id FROM Event_Confirmation__c WHERE Guest_First_Name__c = 'First' LIMIT 1];
        Event_Question__c eventQuestionId = [SELECT Id FROM Event_Question__c WHERE Name =: 'Question' LIMIT 1];
        Test.startTest();
            eventRecord.Status__c = 'Published';
            update eventRecord;
            eventQuestionId.Required__c = true;
            Database.SaveResult srList = Database.update(eventQuestionId, false);
        Test.stopTest();
        System.assertEquals(srList.isSuccess(), false, 'Update error');
    }
}