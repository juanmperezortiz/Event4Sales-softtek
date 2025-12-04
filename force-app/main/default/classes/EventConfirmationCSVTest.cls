/**
 * @description       :
 * @author            : Eduardo Hernandez
 * @group             :
 * @last modified on  : 11-03-2023
 * @last modified by  : Eduardo Hernandez
**/
@isTest
private class EventConfirmationCSVTest {
    @isTest
    static void getEventConfirmationsTest() {
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
            Custom_Event__c testEvent = new Custom_Event__c();
            testEvent.Name = 'Test Event';
            testEvent.Timezone__c = 'CST';
            testEvent.Address__c = 'Address';
            testEvent.Duration__c = 60;
            testEvent.Minutes_Or_Hours__c = 'Minutes';
            testEvent.Date__c = Datetime.now() + 8;
            testEvent.Host__c = UserInfo.getUserId();
            insert testEvent;
            Event_Confirmation__c testConfirm = new Event_Confirmation__c(
                Guest_First_Name__c = 'First', Guest_Last_Name__c = 'Last',
                Email__c = 'email@email.com', Check_In__c = false,
                Custom_Event__c = testEvent.Id
            );
            insert testConfirm;
            Test.startTest();
            Event_Confirmation__c classEvent = EventConfirmationCSV.getEventConfirmations(testEvent.Id)[0];
            System.assertEquals(testConfirm.Guest_Last_Name__c, classEvent.Guest_Last_Name__c, 'LastName does not match');
            Test.stopTest();
        }
    }
}