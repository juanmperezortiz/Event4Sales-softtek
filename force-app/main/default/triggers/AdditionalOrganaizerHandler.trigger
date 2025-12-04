/**
 * @description       : Trigger for Additional Organizer
 * @description       : This trigger is used to validate the number of additional organizers for an event
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
trigger AdditionalOrganaizerHandler on Additional_Organizer__c (before insert, before update, after insert) {

    /**Configuration for Additional Host */
    final Event4SalesParams__c newHostValid = EventSalesPanel.findParameter('TriggerAdditionalHost');
    /**Configuration for Maximum host by event */
    final Event4SalesParams__c totalHostes = EventSalesPanel.findParameter('MaximumHostsbyEvent');

    Additional_Organizer__c additionalOrganaizer = trigger.new[0];

    if (newHostValid.Active__c) {
        if (trigger.isBefore) {
            final List<Additional_Organizer__c> lstEvent = [Select Id from Additional_Organizer__c where Custom_Event__c =: additionalOrganaizer.Custom_Event__c WITH SECURITY_ENFORCED];
            if (lstEvent.size() > Integer.valueOf(totalHostes.Integer_Param__c)) {
                additionalOrganaizer.addError('You are reached the maximum host by event');
            }
        }
    } else {
        additionalOrganaizer.addError('You cant add new hosts to the event');
    }

    if (trigger.isAfter) {
        if (trigger.isInsert) {
            AdditionalOrganaizer_Handler.sendHostNotification(additionalOrganaizer);
        }
    }
}