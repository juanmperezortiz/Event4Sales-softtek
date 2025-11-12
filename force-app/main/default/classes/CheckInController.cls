/**
 * @description       : Check In Controller class
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
public without sharing class CheckInController {

    /**Configuration time to start events */
    final static Event4SalesParams__c beforeStartEvent = EventSalesPanel.findParameter('MinimalDaysBeforeEvent');
    /**Configuration time to end events */
    final static Event4SalesParams__c afterStartEvent = EventSalesPanel.findParameter('MaximumDaysAfterEvent');

    /**
    * @description Find event confirmation
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025 
    * @param id 
    * @return Event_Confirmation__c 
    **/
    @AuraEnabled(cacheable = true)
    public static Event_Confirmation__c getEventConfirmation(String id){
        try {
            return[SELECT Id, Check_In__c, Confirmation_Code__c, Custom_Event__r.Date__c, Custom_Event__r.Time_ZoneStr__c FROM Event_Confirmation__c WHERE Id =: id LIMIT 1];    
        } catch (Exception e) {
            return null;
        }
        
    }

    /**
    * @description Retrive events avoid to start
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025 
    * @param id Event to check
    * @return Map<Integer, Datetime> Map with the time to start and end the event
    **/
    @AuraEnabled(cacheable = true)
    public static Map<Integer, Datetime> showEvent(Id id) {
        Map<Integer,Datetime> returnMap = new Map<Integer,Datetime>();
        Event_Confirmation__c event = [SELECT Id, Custom_Event__r.Date__c FROM Event_Confirmation__c WHERE Id =: id LIMIT 1];
        Datetime dateNow = Datetime.now();
        Datetime date2HoursBefore = event.Custom_Event__r.Date__c.addHours(-(Integer.valueOf(beforeStartEvent.Integer_Param__c)));
        Datetime date2HoursAfter = event.Custom_Event__r.Date__c.addHours(-(Integer.valueOf(afterStartEvent.Integer_Param__c)));
        if(dateNow >= date2HoursBefore ){
            if (dateNow <= date2HoursAfter ) {
                returnMap.put(0, dateNow);
            }
            else {
                returnMap.put(1, date2HoursAfter);
            }
        }
        else {
            returnMap.put(-1, date2HoursBefore);
        }
        return returnMap;
    }

    /**
    * @description Update the event confirmation
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025 
    * @param id Event update result
    **/
    @AuraEnabled(cacheable = false)
    public static void updateEventConfirmation(Id id){
        Event_Confirmation__c event = [SELECT Id, Check_In__c FROM Event_Confirmation__c WHERE Id =: id LIMIT 1];
        event.Check_In__c = true;
        update event;
    }
}