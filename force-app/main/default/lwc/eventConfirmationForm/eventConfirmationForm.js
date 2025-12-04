import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getCustomEvent from '@salesforce/apex/EventConfirmationController.getCustomEvent';
import createEventConfirmation from '@salesforce/apex/EventConfirmationController.createEventConfirmation';
import answersList from '@salesforce/apex/EventConfirmationController.answersList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOGO from '@salesforce/resourceUrl/Logo';
import downloadics from '@salesforce/label/c.eventConfirmation_downloadICS';
import generateICS from '@salesforce/apex/EventConfirmationController.generateICS';

export default class EventConfirmationForm extends LightningElement {

    label = {
        downloadics
    };

    @track answers = [];
    @track questions;
    urlId = null;
    eventId = null;
    guestFirstName = null;
    guestLastName = null;
    @track urlStateParameters = null;
    currentPageReference = null; 
    eventData;
    guestEmail;
    showForm = false;
    successRegistration = false;
    eventClosed = false;
    response;
    logo = LOGO;
    disabled = false;
    @track noEventFound = false;
    errorMessage = "Sorry, we can not found the event registration.";
    disabledClass = "slds-button slds-button_brand slds-button_stretch";
    dateStr = '';
    dateTimeStr = '';
    googleLink = '';
    outlookLink = '';
    officeLink = '';
    yahooLink = '';
    base64file = '';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
       }
    }

    setParametersBasedOnUrl() {
       this.urlId = this.urlStateParameters.id || null;
    }
      
    connectedCallback(){
        console.log(this.urlId);
        getCustomEvent({id: this.urlId}).then(result =>{
            console.log(result);
            if(result && result.isOk) {
                this.processResponse(result.eventRecord);
                this.dateStr = result.formateDate.initData.dateEventDay;
                this.dateTimeStr = result.formateDate.initData.hourEvent;
            }
        }).catch(error => {
            console.log("dshajsdlh");
            console.log(error);
            this.showForm = false;
            this.noEventFound = true;
        })
    }

    processResponse(result) {
        this.eventId = result.Id;
        this.eventData = result;
        this.noEventFound = false;
        var noQuestions = result.Event_Questions__r != undefined ?  true: false;
        if(noQuestions) {
            this.questions = JSON.parse(JSON.stringify(result.Event_Questions__r));
            this.questions.forEach(question => {
                question.isOpenText = false;
                question.isCheckbox = false;
                question.isPicklist = false;
                if(question.Type_of_Question__c == 'Open Text'){
                    question.isOpenText = true;
                }
                else if(question.Type_of_Question__c == 'Checkbox'){
                    question.isCheckbox = true;
                    question.checked = false;
                }
                else{
                    question.isPicklist = true;
                    question.Options = [];
                    question.Options__c.split('%0A').forEach(element => {
                        question.Options = [...question.Options, {label: element, value: element}]
                    });
                }
                this.answers[question.Id.toString()] = '';                
            });
        }
        this.showForm = true;
        if(result.Status__c == "Closed"){
            this.eventClosed = true;
            this.showForm = false;
        }
    }
    errorCallback(){

    }

    handleSubmit(){
        var answersApex = []
        this.disabled = true;
        this.disabledClass = "disabledButton slds-button slds-button_brand slds-button_stretch";
        for(var keyA in this.answers){ 
            answersApex = [...answersApex, {key: keyA, value: String(this.answers[keyA])}];
        }
        const data = {
            eventId: this.eventId,
            firstName: this.guestFirstName,
            lastName: this.guestLastName,
            email: this.guestEmail
        };
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            createEventConfirmation({ eventData : data}).then(result =>{
                this.showForm = false;
                this.successRegistration = true;
                this.response = 'A confirmation has been sent to: ' + this.guestEmail;
                this.eventConfirmationId = result;
                this.downloadics();
                answersList({object2: answersApex, eventConfirmationId: result});
            });
            
        } else {
            this.disabled = false;
            disabledClass = "slds-button slds-button_brand slds-button_stretch";
        }
    }

    handleAnswer(event){
        if(event.detail.value != undefined){
            this.answers[event.target.dataset.id] = event.detail.value;
        }
        else{
            this.answers[event.target.dataset.id] = event.target.checked;
        }
    }

    handleFirstName(event){
        this.guestFirstName = event.detail.value;
    }

    handleLastName(event){
        this.guestLastName = event.detail.value;
    }
    
    handleEmail(event){
        this.guestEmail = event.detail.value;
    }

    showToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    downloadics() {
        generateICS({recordId: this.eventConfirmationId}).then(result => {
            console.log('response::: ', result);
            if(result.isOk) {
                this.base64file = result.base64file;
                this.eventConfirm = result.eventConfirm;
                this.googleLink = this.generateUrlbaseGoogle(result.eventConfirm);
                this.outlookLink = this.generateUrlbaseOutlook(result.eventConfirm);
                this.officeLink = this.generateUrlbaseOffice(result.eventConfirm);
            }
        }).catch(error => {
            console.log(error);
            console.log(error.message);
        });
    }

    downloadICSFile() {
        let downloadLink = document.createElement("a");
        let base64str = this.base64file;
        downloadLink.href = "data:text/ics;base64,"+base64str;
        downloadLink.download = this.eventConfirm.EvName__c+".ics";
        downloadLink.click();
    }

    generateUrlbaseGoogle(eventConfirm) {
        let urlbase = 'https://calendar.google.com/calendar/render?';
        urlbase += 'action=TEMPLATE&';
        urlbase += 'text='+ eventConfirm.EvName__c +'&';
        urlbase += 'dates='+ eventConfirm.EvDateStart__c + 'Z%2F' + eventConfirm.EvDateEnd__c + 'Z&';
        urlbase += 'details=Check in Link: ' + eventConfirm.URL__c + '%0A %0ACode: ' + eventConfirm.Confirmation_Code__c + 
            '%0A %0A**Check in:  From 2 hours before the event start up to 2 hours after the event started**%0A'+ 
            'ORGANIZER;CN=' + eventConfirm.EvHostName__c + ':mailto:' + eventConfirm.EvEmail__c + '&';
        urlbase += 'location=' + eventConfirm.EvAddress__c + '&';
        urlbase += 'trp=true';
        return urlbase.replace(' ', '%20');
    }

    generateUrlbaseOutlook(eventConfirm) {
        let urlbase = 'https://outlook.live.com/calendar/0/action/compose?';
        urlbase += 'allday=false&rru=addevent&';
        urlbase += 'subject='+ eventConfirm.EvName__c+'&';
        urlbase += 'startdt='+ this.dateIso8601(eventConfirm.EvDateStart__c) + '&';
        urlbase += 'enddt=' + this.dateIso8601(eventConfirm.EvDateEnd__c) + '&';
        urlbase += 'body=Check in Link: ' + eventConfirm.URL__c + '%0A %0ACode: ' + eventConfirm.Confirmation_Code__c + 
            '%0A %0A**Check in:  From 2 hours before the event start up to 2 hours after the event started**%0A'+ 
            'ORGANIZER;CN=' + eventConfirm.EvHostName__c + ':mailto:' + eventConfirm.EvEmail__c + '&';
        urlbase += 'location=' + eventConfirm.EvAddress__c + '&';
        urlbase += 'online=1';
        return urlbase.replace(' ', '%20');
    }


    generateUrlbaseOffice(eventConfirm) {
        let urlbase = 'https://outlook.office.com/calendar/0/action/compose?';
        urlbase += 'allday=false&rru=addevent&';
        urlbase += 'subject='+ eventConfirm.EvName__c+'&';
        urlbase += 'startdt='+ this.dateIso8601(eventConfirm.EvDateStart__c) + '&';
        urlbase += 'enddt=' + this.dateIso8601(eventConfirm.EvDateEnd__c) + '&';
        urlbase += 'body=Check in Link: ' + eventConfirm.URL__c + '%0A %0ACode: ' + eventConfirm.Confirmation_Code__c + 
            '%0A %0A**Check in:  From 2 hours before the event start up to 2 hours after the event started**%0A'+ 
            'ORGANIZER;CN=' + eventConfirm.EvHostName__c + ':mailto:' + eventConfirm.EvEmail__c + '&';
        urlbase += 'location=' + eventConfirm.EvAddress__c + '&';
        urlbase += 'online=1';
        return urlbase.replace(' ', '%20');
    }

    dateIso8601(dateconvert) {
        let dateConvertStr = '';
        if(dateconvert.length == 15) {
            //20230718T000000
            let yearStr = dateconvert.substring(0,4);
            let monthStr = dateconvert.substring(4,6);
            let dayStr = dateconvert.substring(6,8);
            let hourStr = dateconvert.substring(9,11);
            let minStr = dateconvert.substring(11,13);
            let secStr = dateconvert.substring(13,15);
            dateConvertStr = yearStr + '-' + monthStr + '-' + dayStr + 'T' + hourStr + ':' + minStr + ':' + secStr + 'Z';
        }
        return dateConvertStr;
    }

    openlinkGoogle() {
        window.open(this.googleLink);
    }

    openlinkOutlook() {
        window.open(this.outlookLink);
    }

    openlinkOffice() {
        window.open(this.officeLink);
    }
}