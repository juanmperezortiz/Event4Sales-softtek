/**
 * @description       : PostInstall package controller
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
public class Event4Sales_PostInstallPackage implements InstallHandler {
    /**
    * @description Install post Install script
    * @author Eduardo Hernandez | 11-03-2023
    * @param context install handler
    **/
    public void onInstall(InstallContext context) {
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
    public void installNewVersion() {
        final List<Event4SalesParams__c> lstParams = new List<Event4SalesParams__c>();
        List<List<Object>> paramsObjects = new List<List<Object>>();
        List<Object> param = new List<Object>{'TriggerAdditionalHost',     0, 'boolean', 'Additional Organizar Trigger'};
        paramsObjects.add(param);
        param = new List<Object>{'EventQuestionsTriggers',    0, 'boolean', 'Enable Event questions trigger'};
        paramsObjects.add(param);
        param = new List<Object>{'MaximumHostsbyEvent',       5, 'Integer', 'Maximum Host by Event'};
        paramsObjects.add(param);
        param = new List<Object>{'MaximumDaysAfterEvent',     5, 'Integer', 'Maximum hours after start event'};
        paramsObjects.add(param);
        param = new List<Object>{'MinimalDaysBeforeEvent',    5, 'Integer', 'Maximum hours before start event'};
        paramsObjects.add(param);
        param = new List<Object>{'TotalQuestions',            5, 'Integer', 'Maximum Question by Event'};
        paramsObjects.add(param);
        param = new List<Object>{'MinimumDaysForNewEvents',   5, 'Integer', 'Minimum days for new Events'};
        paramsObjects.add(param);
        param = new List<Object>{'SendHostNotification',      0, 'boolean', 'Send host Notifications'};
        paramsObjects.add(param);
        param = new List<Object>{'TriggerCustomEvent',        0, 'boolean', 'Trigger CustomEvent'};
        paramsObjects.add(param);

        for(List<Object> paramObject : paramsObjects) {
            EventData event = new EventData();
            event.configName = (String)paramObject[0];
            event.valueParam = (Integer)paramObject[1];
            event.fieldType = (String)paramObject[2];
            event.paramName = (String)paramObject[3];
            lstParams.add(newParam(event));
        }
        insert lstParams;
    }

    /**
    * @description Create new params for Panel
    * @author Eduardo Hernandez | 11-03-2023
    * @param params wrapper class with values for event
    * @return Event4SalesParams__c
    **/
    private static Event4SalesParams__c newParam(EventData params) {
        final Event4SalesParams__c evenParam = new Event4SalesParams__c();
        evenParam.Active__c = true;
        evenParam.Integer_Param__c = params.valueParam;
        evenParam.Type_Field__c = params.fieldType;
        evenParam.Configuration__c = params.configName;
        evenParam.Name = params.paramName;
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

    /**
    * @description EventData
    **/
    public class EventData {
        @AuraEnabled public String configName;
        @AuraEnabled public Integer valueParam;
        @AuraEnabled public String fieldType;
        @AuraEnabled public String paramName;
    }
}