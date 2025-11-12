/**
 * @description       : PostInstall package controller
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
global class Event4Sales_PostInstallPackage implements InstallHandler {
    
    /**
    * @description Install post Install script
    * @author Eduardo Hernandez | 11-03-2023 
    * @param context install handler
    **/
    global void onInstall(InstallContext context) {
        String emailTitle = 'Package install successful';
        String emailBody = 'Thanks for installing the package.';
        if (context.previousVersion() == null ) {
            installNewVersion();

        }
        sendConfirmation(context, emailTitle, emailBody);
    }

    /**
    * @description Steps new version in Org
    * @author Eduardo Hernandez | 11-03-2023
    **/
    private void installNewVersion() {
        final List<Event4SalesParams__c> lstParams = new List<Event4SalesParams__c>();
        lstParams.add(newParam('TriggerAdditionalHost',     0, 'boolean', 'Additional Organizar Trigger'));
        lstParams.add(newParam('EventQuestionsTriggers',    0, 'boolean', 'Enable Event questions trigger'));
        lstParams.add(newParam('MaximumHostsbyEvent',       5, 'Integer', 'Maximum Host by Event'));
        lstParams.add(newParam('MaximumDaysAfterEvent',     5, 'Integer', 'Maximum hours after start event'));
        lstParams.add(newParam('MinimalDaysBeforeEvent',    5, 'Integer', 'Maximum hours before start event'));
        lstParams.add(newParam('TotalQuestions',            5, 'Integer', 'Maximum Question by Event'));
        lstParams.add(newParam('MinimumDaysForNewEvents',   5, 'Integer', 'Minimum days for new Events'));
        lstParams.add(newParam('SendHostNotification',      0, 'boolean', 'Send host Notifications'));
        lstParams.add(newParam('TriggerCustomEvent',        0, 'boolean', 'Trigger CustomEvent'));
        insert lstParams;
    }

    /**
    * @description Create new params for Panel
    * @author Eduardo Hernandez | 11-03-2023 
    * @param configName Name of the param configuration
    * @param valueParam param value
    * @param fieldType type of param
    * @param paramName Param name title
    * @return Event4SalesParams__c 
    **/
    private static Event4SalesParams__c newParam(String configName, Integer valueParam, String fieldType, String paramName) {
        final Event4SalesParams__c evenParam = new Event4SalesParams__c();
        evenParam.Active__c = true;
        evenParam.Integer_Param__c = valueParam;
        evenParam.Type_Field__c = fieldType;
        evenParam.Configuration__c = configName;
        evenParam.Name = paramName;
        return evenParam;
    }

    /**
    * @description Send email on finish
    * @author Eduardo Hernandez | 11-03-2023 
    * @param context Install handler
    * @param emailTitle Title email result
    * @param emailBody Body email result
    **/
    private static void sendConfirmation(InstallContext context, String emailTitle, String emailBody) {
        final User userData = [Select Id, Email from User where Id =:context.installerID()];   
        String toAddress= userData.Email;
        String[] toAddresses = new String[]{toAddress};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('support_package@softtek.dev');
        mail.setSenderDisplayName('Event4Sales Support');
        mail.setSubject(emailTitle);
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
    }
}