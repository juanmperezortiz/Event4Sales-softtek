/**
 * @description       : Trigger for Custom Event
 * @description       : This trigger is used to validate the date of the event
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
trigger CustomEventTrigger on Custom_Event__c (before insert, before update) {
    
    /**Configuration for days before event start */
    final Event4SalesParams__c daysBefore = EventSalesPanel.findParameter('MinimumDaysForNewEvents');
    /**Configuration to Enable trigger */
    final Event4SalesParams__c enableTriggerEvent = EventSalesPanel.findParameter('TriggerCustomEvent');
    Custom_Event__c eventNew = trigger.new[0];
    
    if (enableTriggerEvent.Active__c) {
        if (trigger.isBefore && trigger.isUpdate) {
            Custom_Event__c eventOld = trigger.old[0];
            if(eventNew.Date__c != eventOld.Date__c) {
                final Datetime dateEvent = System.now().addDays(Integer.valueOf(daysBefore.Integer_Param__c));
                if (eventOld.Date__c < dateEvent) {
                    eventNew.addError('The minimal days for new events is: '+String.valueOf(Integer.valueOf(daysBefore.Integer_Param__c)) );
                }
            }
        }
    
        if(trigger.isUpdate) {
            Custom_Event__c eventOld = trigger.old[0];
            if((eventNew.Name != eventOld.Name || eventNew.Date__c != eventOld.Date__c ||
                eventNew.Address__c != eventOld.Address__c || eventNew.Duration__c != eventOld.Duration__c ||
                eventNew.Purpose__c != eventOld.Purpose__c || eventNew.Type_of_Event__c != eventOld.Type_of_Event__c ||
                eventNew.Timezone__c != eventOld.Timezone__c)
                && (eventOld.Status__c == 'Published' || eventOld.Status__c == 'Closed')){
                    eventNew.addError('The event can\'t be edited, the event is already Published or Closed');
            }
        }
    }
}