/**
 * @description       : eventConfirmationForm Controller
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
public without sharing class EventConfirmationController {
    @AuraEnabled(cacheable = true)
    public static Map<String, Object> getCustomEvent(String id) {
        final Map<String, Object> response = new Map<String, Object>();
        try {
            final Custom_Event__c eventRecord = [SELECT Name, Date__c, Time_ZoneStr__c, 
            Address__c, Duration__c, Minutes_Or_Hours__c, Purpose__c, 
            Status__c, Host__r.Name, Timezone__c,
            (SELECT Id, Name, Type_of_Question__c, Options__c, Required__c FROM Event_Questions__r)
            FROM Custom_Event__c WHERE Id =: id LIMIT 1];
            response.put('eventRecord', eventRecord);
            response.put('formateDate', ScheduledEventCalendar_Ctrl.findTimeZones(id));
            response.put('isOk', true);
            response.put('nameuser', System.UserInfo.getName());
        } catch (Exception e) {
            response.put('isOk', false);
            response.put('isOk', e.getMessage());
        } 
        return response;
    }

    @AuraEnabled(cacheable = false)
    public static Id createEventConfirmation(Id eventId, String firstName, String lastName, String email){
        Event_Confirmation__c eventConf = new Event_Confirmation__c(Guest_First_Name__c = firstName,
        Guest_Last_Name__c = lastName, Custom_Event__c = eventId, Email__c = email);
        Contact[] contact = [SELECT Id FROM Contact WHERE Email =: email LIMIT 1];    
        if(contact.size() > 0){
            eventConf.Contact__c = contact[0].id;
        }

        insert eventConf;
        return eventConf.Id;
    }

    @AuraEnabled(cacheable = false)
    public static void answersList(List<Map<String,String>> object2, Id eventConfirmationId){
        List<Answer__c> answers = new List<Answer__c>();
        for (Map<String,String> obj : object2) {
            Event_Question__c eventQuestion = [SELECT Id FROM Event_Question__c WHERE Id =: obj.get('key')];
            Answer__c answer = new Answer__c(Event_Confirmation__c = eventConfirmationId);
            answer.Event_Question__c = eventQuestion.Id;
            if(obj.get('value') == 'true'){
                answer.Name = 'Yes';
            }
            else if(obj.get('value') == 'false') {
                answer.Name = 'No';
            }
            else {
                answer.Name = obj.get('value');
            }
            answers.add(answer);
        }
        insert answers;
        Event_Confirmation__c eventSend = [SELECT Id, Custom_Event__r.Send_Event_Confirmation_Emails__c FROM Event_Confirmation__c WHERE Id =: eventConfirmationId];
        if(eventSend.Custom_Event__r.Send_Event_Confirmation_Emails__c){
            Event_Confirmation__c event = [SELECT Id, Guest_First_Name__c, Guest_Last_Name__c,
            Email__c, Contact__c, Custom_Event__c, EvName__c FROM Event_Confirmation__c WHERE Id =: eventConfirmationId];
        
            List<Answer__c> answersEmail = [SELECT Name, Event_Question__r.Name FROM Answer__c WHERE Event_Confirmation__c =: eventConfirmationId];

            EventConfirmationEmailHandler handler = new EventConfirmationEmailHandler();
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            
            Messaging.SingleEmailMessage mailHostOrganizer = handler.hostOrganizerEmail(event, answers);

            emailList.add(mailHostOrganizer);

            Messaging.sendEmail(emailList);
        }
    }

    @AuraEnabled
    public static Map<String, Object> generateICS(String recordId) {
        final Map<String, Object> response = new Map<String, Object>();
        try {
            Event_Confirmation__c eventConfirmation = [Select Id, EvDateStart__c, EvDateEnd__c, EvName__c, URL__c, Confirmation_Code__c, EvHostName__c, 
            EvEmail__c, EvAddress__c from Event_Confirmation__c where Id =: recordId limit 1];
            response.put('base64file', EventConfirmationController.generateICSBase64(eventConfirmation));
            response.put('eventConfirm', eventConfirmation);
            response.put('isOk', true);
        } catch (QueryException quEx) {
            response.put('isOk', false);
            response.put('msjError', quEx.getMessage());
        }
        return response;
    }

    private static String generateICSBase64(Event_Confirmation__c eventConfirmation) {
        String baseStr = '';
        String icsfile = EventConfirmationController.generateICSfile(eventConfirmation);
        Blob baseStrblob = Blob.valueOf(icsfile);
        baseStr = EncodingUtil.base64Encode(baseStrblob);
        return baseStr;
    }

    private static String generateICSfile(Event_Confirmation__c eventConfirmation) {
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
        return icsFile;
    }
}