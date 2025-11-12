/**
 * @description       : Find Contacts controller
 * @author            : Eduardo Hernandez Cuamatzi
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/

public class ContactSearch {
    /**
    * @description Find contacts by name, email or phone
    * @description       : This method is used to find contacts by name, email or phone
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025 
    * @param textSearch string value to search
    * @return List<Contact> List of Contacts
    **/
    @AuraEnabled(Cacheable = true)
    public static List<Contact> getContacts(String textSearch) {
        List<Contact> contactList = new List<Contact>();
        try {
            for (List<SObject> lsObject: [FIND :textSearch IN ALL FIELDS RETURNING Contact(Id, Name, Email, Phone)]) {
                contactList = (List<Contact>)lsObject;
            }
        } catch (Exception error) {
            System.debug(error.getMessage() + ' '+ error.getCause());
        }
        return contactList;
    }
    /**
    * @description find all ready invited contacts
    * @description       : This method is used to find all ready invited contacts
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025 
    * @param eventId Event related to the contacts
    * @return List<Event_Confirmation__c> Event Confirmation results
    **/
    @AuraEnabled(Cacheable = false)
    public static List<Event_Confirmation__c> getAllReadyInvitedContacts(Id eventId){
        List<Event_Confirmation__c> contactList = [SELECT Id, Contact__c, Custom_Event__c 
        FROM Event_Confirmation__c WHERE Custom_Event__c =: eventId AND Contact__c != null];
        return contactList;
    }

    /**
    * @description Create invitation
    * @description       : This method is used to create invitation
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025 
    * @param ids Contacts Id
    * @param eventId Event Id
    * @return List<Event_Confirmation__c> List of Event Confirmation results
    **/
    @AuraEnabled(Cacheable = false)
    public static List<Event_Confirmation__c> createInvitation(List<String> ids, Id eventId){
        List<Contact> contactList;
        try {
            contactList = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id IN :ids];
        } catch (Exception e) {
            
        }
        List<Event_Confirmation__c> eventConfirmations = new List<Event_Confirmation__c>();
        for (Contact con : contactList) {
            Event_Confirmation__c eventConfirmation = new Event_Confirmation__c();
            eventConfirmation.Custom_Event__c = eventId;
            eventConfirmation.Contact__c = con.Id;
            eventConfirmation.Email__c = con.Email;
            eventConfirmation.Guest_First_Name__c = con.FirstName;
            eventConfirmation.Guest_Last_Name__c = con.LastName;
            eventConfirmations.add(eventConfirmation);
        }
        insert eventConfirmations;
        return eventConfirmations;
    }
    
    /**
    * @description Send emails
    * @description       : This method is used to send emails
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025 
    * @param eventId Event Id
    **/
    @AuraEnabled(Cacheable = false)
    public static void sendEmails(Id eventId){
        List<Event_Confirmation__c> eventConfirmations = [SELECT Id, EvName__c, Custom_Event__c, 
            Email__c, EvDateStartDisplay__c, 
            EvAddress__c, EvHostName__c, Email_Sended__c 
            FROM Event_Confirmation__c WHERE Custom_Event__c =: eventId AND Email_Sended__c = false];

            List<String> emails = new List<String>();

            for (Event_Confirmation__c confirmation : eventConfirmations) {
                emails.add(confirmation.Email__c);
            }

            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();


            String body = '<div>Congratulations!' + '</div>' +
            '<div>You has been invited to an event!' + '</div>' +
            '<div>Event: ' + eventConfirmations[0].EvName__c + '</div>' +
            '<div>Date/Time: ' + eventConfirmations[0].EvDateStartDisplay__c + '</div>' +
            '<div>Address: ' + eventConfirmations[0].EvAddress__c + '</div>' +
            '<div>Host: ' + eventConfirmations[0].EvHostName__c + '</div>' +
            '<div>Link: <a href="' + eventConfirmations[0].Custom_Event__c + '"> '+ eventConfirmations[0].Custom_Event__c+'</a>' + '</div>';

            email.setToAddresses(emails);
            email.setHtmlBody(body);
            email.setSubject(eventConfirmations[0].EvName__c);
        
            emailList.add(email);
            Messaging.sendEmail(emailList);
    }
}