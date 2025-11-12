/**
 * @description       : Scheduled event controller
 * @author            : Eduardo Hernandez
 * @group             : Softtek
 * @last modified on  : 11-11-2025
 * @last modified by  : Eduardo Hernandez Cuamatzi
**/
public without sharing class ScheduledEventCalendar_Ctrl {
    
    /**Final Map of all TimeZones */
    final static Map<String, String> MAPTIMEZONES = new Map<String, String>();

    static {
        Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        final Date dateNow = System.now().date();
		for(Schema.PicklistEntry pickListVal : ple) {
            MAPTIMEZONES.put(pickListVal.getLabel(), pickListVal.getValue());
		}
    }

    /**
    * @description Return map of datetimes
    * @author Eduardo Hernandez | 05-19-2023 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> findTimeZones(String recordId) {
        final Map<String, Object> response = new Map<String, Object>();
        try {
            response.put('initData', initData(recordId));
            response.put('timeZones', MAPTIMEZONES);
            response.put('isOk', true);
        } catch (Exception exc) {
            response.put('isOk', false);
            response.put('msjError', exc.getMessage());
        }
        return response;
    }

    /**
    * @description Update record event 
    * @author Eduardo Hernandez | 05-17-2023 
    * @return Map<String, Object> Result update event record
    **/
    @AuraEnabled
    public static Map<String, Object> updateEvent(String recordId, String timeZoneStr, String timeselect) {
        final Map<String, Object> response = new Map<String, Object>();
        try {
            final Custom_Event__c eventRecord = [Select Id,Timezone_Hours__c,Minutes_Or_Hours__c,Hours_to_Add__c, Date__c,Duration__c from Custom_Event__c where Id =: recordId];
            final Custom_Event__c eventUpdate = new Custom_Event__c();
            final String timeItem = MAPTIMEZONES.get(timeZoneStr);
            final Timezone timezoneRecord = Timezone.getTimeZone(timeItem);
            final TimeZone timezonUser = UserInfo.getTimeZone();
            final DateTime timeScheduled = parseTime(timeselect);
            final Integer offtsettone = timezoneRecord.getOffset(timeScheduled);
            final Integer offtsettUser = timezonUser.getOffset(timeScheduled);
            final DateTime timeScheduledReal = timeScheduled.addSeconds(parseMilli(offtsettUser));
            String startDate2 = timeScheduledReal.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss')+'Z';
            final DateTime timeScheduled2 = parseTime(startDate2);
            final DateTime timeScheduledGMT = timeScheduled2.addSeconds(-1*parseMilli(offtsettone));
            final DateTime timeScheduledGMTLocal = timeScheduledGMT.addSeconds(parseMilli(offtsettUser));
            final Datetime dateEventReal = timeScheduled.addSeconds(parseMilli(eventRecord.Hours_to_Add__c));
            Integer minutesAdd = Integer.valueOf(eventRecord.Duration__c);
            if (eventRecord.Minutes_Or_Hours__c.equalsIgnoreCase('Hours')) {
                minutesAdd = Integer.valueOf(eventRecord.Duration__c*60);
            }
            final Datetime dateEventEndReal = dateEventReal.addMinutes(minutesAdd);
            eventUpdate.Id = recordId;
            eventUpdate.Time_ZoneStr__c = timezoneStr;
            eventUpdate.Date__c = dateEventReal;
            eventUpdate.Timezone_Hours__c = offtsettone;
            eventUpdate.Hours_to_Add__c = offtsettUser;
            eventUpdate.Status__c = 'Published';
            eventUpdate.Datetime_Selected__c = timeselect;
            eventUpdate.Event_End_DateTime__c = dateEventEndReal;
            update eventUpdate;
            response.put('isOk', true);
        } catch (DmlException dmlEx) {
            response.put('isOk', false);
            response.put('msjError', dmlEx.getMessage());
        }
        return response;
    }

    /**
    * @description Parse Date Strint to DateTime
    * @author Eduardo Hernandez | 05-19-2023 
    * @param timeselect Date time input from lwc
    * @return Datetime parse datetime
    **/
    private static Datetime parseTime(String timeselect) {
        String dtString = timeselect.replace('T', ' ');
        dtString = dtString.replace('Z', '');
        DateTime datime = DateTime.valueOfGMT(dtString);
        System.debug('datime::: '+datime);
        return datime;
    }

    /**
    * @description Recover init data to display in the LWC
    * @author Eduardo Hernandez | 05-24-2023 
    * @param recordId Custom event record Id
    * @return Map<String, String> Map of data values with times formated
    **/
    private static Map<String, String> initData(String recordId) {
        final Custom_Event__c eventRecord = [Select Id,Timezone_Hours__c,Type_of_Event__c,Time_ZoneStr__c,Status__c,Purpose__c, Hours_to_Add__c, Date__c, Datetime_Selected__c from Custom_Event__c where Id =: recordId];
        final Map<String, String> data = new Map<String, String>();
        if (String.isNotBlank(eventRecord.Datetime_Selected__c)) {
            final Datetime timeSelected = parseTime(eventRecord.Datetime_Selected__c);
            final String timeItem = MAPTIMEZONES.get(eventRecord.Time_ZoneStr__c);
            final Timezone timezoneRecord = Timezone.getTimeZone(timeItem);
            final TimeZone timezonUser = UserInfo.getTimeZone();
            final Integer offtsettone = timezoneRecord.getOffset(timeSelected);
            final Integer offtsettUser = timezonUser.getOffset(timeSelected);
            final Datetime dateEventReal = timeSelected.addSeconds(parseMilli(eventRecord.Hours_to_Add__c));
            final DateTime dateEvent = dateEventReal.addSeconds(-1*parseMilli(offtsettone));
            final DateTime dateEventUser = dateEvent.addSeconds(parseMilli(offtsettUser));
            final String dateUserStr = dateEventUser.yearGmt() + '/' + (dateEventUser.monthGmt() < 10 ? ('0'+dateEventUser.monthGmt()) : String.valueOf(dateEventUser.monthGmt())) + '/' + (dateEventUser.dayGmt() < 10 ? ('0'+dateEventUser.dayGmt()) : String.valueOf(dateEventUser.dayGmt()));
            final String dateEventStr = dateEventReal.yearGmt() + '/' + (dateEventReal.monthGmt() < 10 ? ('0'+dateEventReal.monthGmt()) : String.valueOf(dateEventReal.monthGmt())) + '/' + (dateEventReal.dayGmt() < 10 ? ('0'+dateEventReal.dayGmt()) : String.valueOf(dateEventReal.dayGmt()));
            final String timeEventStr = (dateEventReal.hourGmt() < 10 ? ('0'+dateEventReal.hourGmt()) : String.valueOf(dateEventReal.hourGmt())) + ':' + (dateEventReal.minuteGmt() < 10 ? ('0'+dateEventReal.minuteGmt()) : String.valueOf(dateEventReal.minuteGmt()));
            final String timeUserStr = (dateEventUser.hourGmt() < 10 ? ('0'+dateEventUser.hourGmt()) : String.valueOf(dateEventUser.hourGmt())) + ':' + (dateEventUser.minuteGmt() < 10 ? ('0'+dateEventUser.minuteGmt()) : String.valueOf(dateEventUser.minuteGmt()));
            data.put('dateEvent', String.valueOfGmt(dateEvent));
            data.put('dateUser', String.valueOfGmt(dateEventReal));
            data.put('dateEventDay', dateEventStr);
            data.put('dateEventDayUser', dateUserStr);
            data.put('hourEvent', timeEventStr);
            data.put('hourEventUser', timeUserStr);
            data.put('eventTimeZone', eventRecord.Time_ZoneStr__c);
            data.put('eventTimeZoneUser', timezonUser.getDisplayName());
        }
        data.put('status', eventRecord.Status__c);
        return data;
    }

    /**
    * @description Parse milliseconds to seconds
    * @author Eduardo Hernandez | 05-30-2023 
    * @param milliSeconds milliseconds to conver
    * @return Integer Total seconds equivalent
    **/
    private static Integer parseMilli(Decimal milliSeconds) {
        return Integer.valueOf(milliSeconds/1000);
    }
}