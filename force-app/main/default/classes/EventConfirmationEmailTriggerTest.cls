/**
 * @description       : 
 * @author            : Eduardo Hernandez
 * @group             : 
 * @last modified on  : 11-03-2023
 * @last modified by  : Eduardo Hernandez
**/
@isTest
public class EventConfirmationEmailTriggerTest {
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
    }
    
    @isTest
    private static void testTrigger(){
        Id eventId = [SELECT Id FROM Custom_Event__c WHERE Name = 'Test Event'].Id;
        Event_Confirmation__c testConfirm = new Event_Confirmation__c(
            Guest_First_Name__c = 'First', Guest_Last_Name__c = 'Last',
            Email__c = 'email@email.com', Check_In__c = false,
            Custom_Event__c = eventId
        );
        insert testConfirm;
    }
}