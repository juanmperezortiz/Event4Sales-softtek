import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import findTimeZones from '@salesforce/apex/ScheduledEventCalendar_Ctrl.findTimeZones';
import updateEvent from '@salesforce/apex/ScheduledEventCalendar_Ctrl.updateEvent'
import header from '@salesforce/label/c.scheduled_Headertitle';
import timezone from '@salesforce/label/c.scheduled_timezone';
import timeinput from '@salesforce/label/c.scheduled_timeInput';
import timeUser from '@salesforce/label/c.scheduled_timeUser';
import timeEvent from '@salesforce/label/c.scheduled_timeEvent';
import timeAgain from '@salesforce/label/c.scheduled_again';
import timeFirst from '@salesforce/label/c.scheduled_event';
import eventDateTime from '@salesforce/label/c.scheduled_TitleEventDay';
import eventDateTimeUser from '@salesforce/label/c.scheduled_EventDateTimeUser';


const FIELDS = [
    'Custom_Event__c.Status__c',
    'Custom_Event__c.Date__c',
    'Custom_Event__c.Time_ZoneStr__c',
    'Custom_Event__c.Type_of_Event__c',
];


export default class ScheduledEventCalendar extends LightningElement {  
    
    label = {
        header,
        timezone,
        timeinput,
        timeUser,
        timeEvent,
        timeAgain,
        timeFirst,
        eventDateTime,
        eventDateTimeUser
    };

    @track currentDatetime = "";

    picklistOrdered = [];
    searchResults;
    selectedSearchResult;
    errorValidation = false;
    @track initDatavalues = {};
    isActive = false;
    isInactive = false;
    @api recordId;
    isLoading = true;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    customevent;

    get statusStr() {
        return this.customevent.data.fields.Status__c.value;
    }

    get timezoneStr() {
        return this.customevent.data.fields.Time_ZoneStr__c.value;
    }

    get dateStr() {
        return this.customevent.data.fields.Date__c.value;
    }

    get eventType() {
        return this.customevent.data.fields.Type_of_Event__c.value;
    }

    get selectedValue() {
        return this.selectedSearchResult ? this.selectedSearchResult.value : null;
    }

    connectedCallback() {
        let today = new Date();
        this.currentDatetime = today.toISOString();
        this.refreshData();
    }

    search(event) {
        const input = event.detail.value.toLowerCase();
        const result = this.picklistOrdered.filter((picklistOption) =>
            picklistOption.value.toLowerCase().includes(input)
        );
        this.searchResults = result;
    }

    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedSearchResult = this.picklistOrdered.find(
            (picklistOption) => picklistOption.value === selectedValue
        );
        this.clearSearchResults();
    }

    clearSearchResults() {
        this.searchResults = null;
    }

    showPicklistOptions() {
        if (!this.searchResults) {
            this.searchResults = this.picklistOrdered;
        }
    }

    evaluteChange(event) {
        const input = event.detail.value;
        console.log('input::: ',input);
        const date2 = new Date(input);
        let today = new Date();
        const formatDate = date2.getFullYear() + "-" + (date2.getMonth()+1).toString().padStart(2, '0') + "-" + date2.getDate() + "T" + date2.getHours().toString().padStart(2, '0') + ":" + date2.getMinutes().toString().padStart(2, '0') + ":" + ((date2.getSeconds() + 1).toString().padStart(2, "0")) + 'Z';
        if(date2 < today) {
            this.errorValidation = true;
        } else {
            this.errorValidation = false;
            this.currentDatetime = date2.toISOString();
        }
    }

    onblurfocus() {
        this.clearSearchResults();
    }

    saverecord() {
        this.isLoading = true;
        updateEvent({recordId : this.recordId, timeZoneStr : this.selectedSearchResult.value, timeselect: this.currentDatetime}).then(result => {
            this.isLoading = false;
            if(result) {
                if(result.isOk) {
                    updateRecord({ fields: { Id: this.recordId }});
                    this.refreshData();
                } else {
                    console.log(result.msjError);
                    this.showToastMsg('Error','error',result.msjError);
                }
            }
        }).catch(error => {
            console.log(error);
        });
    }

    refreshData() {
        console.log('refresh data');
        findTimeZones({'recordId': this.recordId}).then((result) => {
            const entries = Object.entries(result.timeZones);
            this.isLoading = false;
            this.initDatavalues = result.initData;
            if(result.initData) {
                if(result.initData.status === "Published") {
                    this.isActive = true;
                    this.isInactive = false;
                } else {
                    this.isInactive = true;
                    this.isActive = false;
                }
            }
            if(this.picklistOrdered.length > 0 === false) {
                entries.forEach( valueItem => {
                    let itemVal = {value: valueItem[0], key: valueItem[1]};
                    this.picklistOrdered.push(itemVal);
                });
                this.picklistOrdered = this.picklistOrdered.sort((a,b)=>{
                    if(a.label < b.label){
                        return -1
                    }
                });   
            }
        }).catch(error => {
            console.log(error.message);
        });
    }

    showToastMsg(title, type, msg) {
        const event = new ShowToastEvent({
            title: title,
            variant: type,
            message: msg
        });
        this.dispatchEvent(event);
    }
}