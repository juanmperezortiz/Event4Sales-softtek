/**
 * @description       : Panel Configuration class
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
public without sharing class EventSalesPanel {
        
    @AuraEnabled
    public static Map<String, Object> findConfigurations() {
        final Map<String, Object> response = new Map<String, Object>();
        try {
            final List<EventsParams> lstParams = new List<EventsParams>();
            for (Event4SalesParams__c paramItem : [Select Id, Name, Active__c, Configuration__c, Integer_Param__c, Type_Field__c from Event4SalesParams__c Order By Type_Field__c DESC]) {
                final EventsParams eventParam = new EventsParams();
                eventParam.booleanParam = paramItem.Active__c;
                eventParam.integerParam = Integer.valueOf(paramItem.Integer_Param__c) > 0 ? Integer.valueOf(paramItem.Integer_Param__c) : 0;
                if (paramItem.Type_Field__c.equalsIgnoreCase('boolean')) {
                    eventParam.isBoolean = true;
                }
                if (paramItem.Type_Field__c.equalsIgnoreCase('integer')) {
                    eventParam.isInteger = true;
                }
                eventParam.paramLabel = paramItem.Name;
                eventParam.paramName = paramItem.Configuration__c;
                eventParam.paramId = paramItem.Id;
                lstParams.add(eventParam);
                response.put('lstParams', lstParams);
            }
            response.put('isOk', true);
        } catch (QueryException quEx) {
            response.put('isOk', false);
            throw new AuraHandledException(quEx.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> updateConfigurations(String jsonLstParams) {
        final Map<String, Object> response = new Map<String, Object>();
        try {
            System.debug('lstParams::: '+jsonLstParams);
            List<EventSalesPanel.EventsParams> lstParamsV = (List<EventSalesPanel.EventsParams>)JSON.deserialize(jsonLstParams, List<EventSalesPanel.EventsParams>.class);
            final List<Event4SalesParams__c> lstEventObjects = new List<Event4SalesParams__c>();
            for (EventsParams eventParamItem : lstParamsV) {
                final Event4SalesParams__c eventSales = new Event4SalesParams__c();
                eventSales.Id = eventParamItem.paramId;
                eventSales.Active__c = eventParamItem.booleanParam;
                eventSales.Integer_Param__c = eventParamItem.integerParam;
                lstEventObjects.add(eventSales);
            }
            update lstEventObjects;
            response.put('isOk', true);
        } catch (DmlException dmEx) {
            response.put('isOk', false);
            System.debug('dmEx::: '+dmEx.getMessage());
            throw new AuraHandledException(dmEx.getMessage());
        }
        return response;
    }

    public static Event4SalesParams__c findParameter(String paramName) {
        return [Select Id, Name, Active__c, Configuration__c, Integer_Param__c from Event4SalesParams__c where Configuration__c =: paramName limit 1];
    }

    public class EventsParams {
        @AuraEnabled
        public Integer integerParam{get;set;}
        @AuraEnabled
        public Boolean isBoolean{get;set;}
        @AuraEnabled
        public Boolean booleanParam{get;set;}
        @AuraEnabled
        public Boolean isInteger{get;set;}
        @AuraEnabled
        public String paramName{get;set;}
        @AuraEnabled
        public String paramLabel{get;set;}
        @AuraEnabled
        public Id paramId{get;set;}

        public EventsParams() {
            this.isBoolean = false;
            this.isInteger = false;
        }
    }
}