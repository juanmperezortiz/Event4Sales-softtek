/**
 * @description       :
 * @author            : Eduardo Hernandez
 * @group             :
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
public without sharing class AdditionalOrganaizer_Handler {
    /**
    * @description Notification to Host when a new Additional Organizer is added
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025
    * @param additionalOrganaizer Additional Organizer record
    **/
    public static void sendHostNotification(Additional_Organizer__c additionalOrganaizer) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        final List<String> toAddress = new List<String>();
        final List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        final User hostadded = [Select Id, email from User where Id =: additionalOrganaizer.User__c WITH SECURITY_ENFORCED];
        final Custom_Event__c eventData = [Select Id, Name, Date__c, Time_ZoneStr__c, Type_of_Event__c
            from Custom_Event__c where Id =: additionalOrganaizer.Custom_Event__c WITH SECURITY_ENFORCED];
        toAddress.add(hostadded.Email);
        final String body = '<div>You was added as Host in a new Event!' + '</div>' +
            '<div>Event Name: ' + eventData.Name + '</div>' +
            '<div>Event Date: ' + eventData.Date__c + '</div>' +
            '<div>Event Timezone: ' + eventData.Time_ZoneStr__c + '</div>' +
            '<div>Event Type: ' + eventData.Type_of_Event__c + '</div>' +
            '<div><a href= "' + URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Custom_Event__c/' + eventData.Id + '/view">Event URL: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + eventData.Id + '</a></div>';
        mail.setToAddresses(toAddress);
        mail.setHtmlBody(body);
        mail.setSubject('New Host');
        emailList.add(mail);
        Messaging.sendEmail(emailList);
    }
}