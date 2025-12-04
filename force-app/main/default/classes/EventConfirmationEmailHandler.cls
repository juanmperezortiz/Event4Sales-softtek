/**
 * @description       :
 * @author            : Eduardo Hernandez
 * @group             :
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
public without sharing class EventConfirmationEmailHandler {
    /**
    * @description Send confirmation email
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025
    * @param eventConfirmation
    * @return mail
    **/
    public Messaging.SingleEmailMessage registrationEmail(Event_Confirmation__c eventConfirmation){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String plainText = 'Congratulations!' + '\n' +
            'Here is the event your event file.' +  '\n' +
            'Event: ' + eventConfirmation.EvName__c + '\n' +
            'Date/Time: ' + eventConfirmation.EvDateStartDisplay__c + '\n' +
            'Address: ' + eventConfirmation.EvAddress__c + '\n' +
            'Host: ' + eventConfirmation.EvHostName__c;

        String icsFile = 'BEGIN:VCALENDAR' + '\n' +
            'VERSION:2.0' +  '\n' +
            'PRODID:-//hacksw/handcal//NONSGML v1.0//EN' + '\n' +
            'BEGIN:VEVENT' + '\n' +
            'UID:uid1@example.com' + '\n' +
            'DTSTAMP:' + eventConfirmation.EvDateStart__c + 'Z' + '\n' +
            'DTSTART:' + eventConfirmation.EvDateStart__c + 'Z' + '\n' +
            'DTEND:' + eventConfirmation.EvDateEnd__c + 'Z' + '\n' +
            'SUMMARY:' + eventConfirmation.EvName__c + '\n' +
            'DESCRIPTION:Check in Link: ' + eventConfirmation.URL__c + '\n' +
            '  \\nCode: ' + eventConfirmation.Confirmation_Code__c + '\n' +
            '  \\n**Check in:  From 2 hours before the event start up to 2 hours after the event started**' + '\n' +
            'ORGANIZER;CN=' + eventConfirmation.EvHostName__c + ':mailto:' + eventConfirmation.EvEmail__c + '\n' +
            'STATUS:CONFIRMED' + '\n' +
            'LOCATION:' + eventConfirmation.EvAddress__c + '\n' +
            'BEGIN:VALARM' + '\n' +
            'ACTION:DISPLAY' + '\n' +
            'TRIGGER:-PT2H'  + '\n' +
            'END:VALARM'  + '\n' +
            'END:VEVENT' + '\n' +
            'END:VCALENDAR';

        Blob blobIcs = Blob.valueOf(icsFile);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(eventConfirmation.EvName__c + '.ics');
        efa.setBody(blobIcs);

        List<String> toAddress = new List<String>();
        toAddress.add(eventConfirmation.Email__c);

        mail.setToAddresses(toAddress);
        mail.setPlainTextBody(plainText);
        mail.setSubject(eventConfirmation.EvName__c);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        return mail;
    }

    /**
    * @description Send confirmation email to host
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025
    * @param eventConfirmation
    * @param answers
    * @return mail
    **/
    public Messaging.SingleEmailMessage hostOrganizerEmail(Event_Confirmation__c eventConfirmation, List<Answer__c> answers){
        Custom_Event__c emailHostOrg = [SELECT Host__r.Email, (SELECT Id, User__r.Email FROM Additional_Organizers__r)
        FROM Custom_Event__c WHERE Id =: eventConfirmation.Custom_Event__c WITH SECURITY_ENFORCED LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddress = new List<String>();
        toAddress.add(emailHostOrg.Host__r.Email);
        for (Additional_Organizer__c additionalOrganizer : emailHostOrg.Additional_Organizers__r) {
            toAddress.add(additionalOrganizer.User__r.Email);
        }

        String body = '<div>Congratulations!' + '</div>' +
            '<div>Someone registered to your event.' +  '</div>' +
            '<div>First Name: ' + eventConfirmation.Guest_First_Name__c + '</div>' +
            '<div>Last Name: ' + eventConfirmation.Guest_Last_Name__c + '</div>' +
            '<div>Email Address: ' + eventConfirmation.Email__c + '</div>';
        if(eventConfirmation.Contact__c != null){
            body += '<div><a href= "' + URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Contact/' + eventConfirmation.Contact__c + '/view">Contact URL: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + eventConfirmation.Contact__c + '</a></div>';
        }
        try {

            String answersString = '';

            Map<Id,String> questions = new Map<Id,String>();
            List<Id> ids = new List<Id>();
            for (Answer__c answer : answers) {
                ids.add(answer.Event_Question__c);
            }

            for (Event_Question__c question : [SELECT Name FROM Event_Question__c WHERE Id IN : ids WITH SECURITY_ENFORCED]) {
                questions.put(question.Id, question.Name);
            }

            for (Answer__c answer : answers) {
                answersString += '<div>Question: ' + questions.get(answer.Event_Question__c) + ' Answer: ' + answer.Name + '</div>';
            }
            body += answersString;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' '+ e.getCause());
        }

        mail.setToAddresses(toAddress);
        mail.setHtmlBody(body);
        mail.setSubject(eventConfirmation.EvName__c);
        return mail;
    }
}