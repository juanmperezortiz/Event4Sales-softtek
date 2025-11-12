/**
 * @description       : Event  Confirmation CSV
 * @description       : This class is used to get the event confirmations
 * @description       : and return them in a CSV format
 * @author            : Eduardo Hernandez Cuamatzi
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
public with sharing class EventConfirmationCSV {
    /**
    * @description Find event confirmation
    * @author Eduardo Hernandez Cuamatzi | 11-11-2025 
    * @param id Id of the event
    * @return List<Event_Confirmation__c> List of Event results
    **/
    @AuraEnabled(cacheable = true)
    public static List<Event_Confirmation__c> getEventConfirmations(Id id){
        return[SELECT Guest_First_Name__c, Guest_Last_Name__c, Email__c, Check_In__c, Email_Sended__c
            FROM Event_Confirmation__c WHERE Custom_Event__c =: id];
    }
}