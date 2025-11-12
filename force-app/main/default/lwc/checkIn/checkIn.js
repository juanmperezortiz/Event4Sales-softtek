import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getEventConfirmation from '@salesforce/apex/CheckInController.getEventConfirmation';
import updateEventConfirmation from '@salesforce/apex/CheckInController.updateEventConfirmation';
import showEvent from '@salesforce/apex/CheckInController.showEvent';
import LOGO from '@salesforce/resourceUrl/Logo';

export default class CheckIn extends LightningElement {
    urlStateParameters;
    codeTyped = '';
    urlId;
    data;
    alreadyCheckIn = false;
    confirmText;
    @track showForm = false;
    errorMessage = '';
    checkInClosed = false;
    checkInDate;
    logo = LOGO;
    noCheckinFound = false;

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
        getEventConfirmation({id: this.urlId}).then(result =>{
            this.data = result;
            if(this.data.Check_In__c){
                this.alreadyCheckIn = true;
                this.showForm = false;
                this.confirmText = 'You already checked in before. Enjoy the event!'
            }
        }).catch(error=>{
            this.noCheckinFound = true;
        });
        var url = this.urlId;
        showEvent({id: url}).then(result =>{
            console.log(result);
            for (const key in result) {
                    if(!this.data.Check_In__c){
                    this.checkInDate = result[key];
                    if(key == 0){
                        this.showForm = true;
                    } 
                    else if(key == -1){
                        this.checkInClosed = true;
                        this.errorMessage = 'You cannot check in yet return at: ';
                    }
                    else{
                        this.checkInClosed = true;
                        this.errorMessage = 'The check in is already closed. Closed at: ';
                    }
                }
            }
            
            console.log(this.checkInDate);
        }); 
    }

    handleCode(event){
        this.codeTyped = event.detail.value;
    }

    handleCheckIn(){
        var inputCmp = this.template.querySelector('lightning-input');
        if(this.codeTyped == this.data.Confirmation_Code__c){
            updateEventConfirmation({id: this.data.Id}).then(result =>{
                this.alreadyCheckIn = true;
                this.showForm = false;
                this.confirmText = 'Check in succesful. Enjoy the event!';
            });
            inputCmp.setCustomValidity('');
        } else{
            inputCmp.setCustomValidity('The code is not correct. Please check again the email and try again.');
        }
    }
}