/**
 * @description       : Trigger for event Questions
 * @description       : This trigger is used to validate the number of questions for an event
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
trigger RelatedQuestionsTrigger on Event_Question__c (before insert, before update) {

    /**Configuration for total questions */
    final Event4SalesParams__c totalQuestions = EventSalesPanel.findParameter('TotalQuestions');
    /**Configuration to enable quiestons in the event */
    final Event4SalesParams__c activeEventQuestions  = EventSalesPanel.findParameter('EventQuestionsTriggers');

    Event_Question__c eventQuestion = trigger.new[0];

    if (activeEventQuestions.Active__c) {
        if(Trigger.isInsert) {
            List<Event_Question__c> questions = [SELECT Id FROM Event_Question__c WHERE Custom_Event__c =: eventQuestion.Custom_Event__c];
            if ((questions.size() +1) > Integer.valueOf(totalQuestions.Integer_Param__c)) {
                for (Event_Question__c e : trigger.new) {
                    e.addError('Too many questions for this event. (Max '+String.valueOf(Integer.valueOf(totalQuestions.Integer_Param__c))+' questions)');
                }
            }
        }
        if(Trigger.isUpdate) {
            String status = [SELECT Status__c FROM Custom_Event__c WHERE Id =: eventQuestion.Custom_Event__c LIMIT 1].Status__c;
            if (status == 'Published' || status == 'Closed') {
                for (Event_Question__c e : trigger.new) {
                    e.addError('You can\'t edit this record because the event status is Publised or Closed');
                }
            }
        }
    }
}