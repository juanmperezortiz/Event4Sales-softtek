import { api, LightningElement, track } from 'lwc';
import getContacts from '@salesforce/apex/ContactSearch.getContacts';
import createInvitation from '@salesforce/apex/ContactSearch.createInvitation';
import sendEmails from '@salesforce/apex/ContactSearch.sendEmails';
import getAllReadyInvitedContacts from '@salesforce/apex/ContactSearch.getAllReadyInvitedContacts';


export default class SelectGuests extends LightningElement {
    searchText;
    @api recordId;
    currentRecordId;
    allReadyInvitedContacts = [];

    @track checkedContactList = [];
    @track contactList;
    @track pillList = [];
    @track ids = [];
    @track contactIds = [];

    connectedCallback(){
        this.currentRecordId = this.recordId;
        getAllReadyInvitedContacts({eventId: this.recordId}).then(result =>{
            console.log(result);
            result.forEach(element => {
                this.allReadyInvitedContacts = [...this.allReadyInvitedContacts, element.Contact__c];
            });
            
        })
    }

    handleItemRemove(event){
        const index = event.detail.index;
        this.pillList.splice(index, 1);
    }

    handleSearchInput(event){
        this.searchText = event.target.value;
    }

    searchContactsHandler(){
        getContacts({textSearch: this.searchText}).then(result => {
            var allContacts = result;
            this.contactList = allContacts.filter(contact => !this.allReadyInvitedContacts.find(invited => contact.Id === invited));
        }).catch(error => {
            this.contactList = null;
        });
    }
    

    handleCheckbox(event){
        if(event.target.checked){
            var contact = this.contactList.find(ele => ele.Id === event.target.dataset.id);
            this.checkedContactList = [...this.checkedContactList, contact];
        }
        else{
            this.checkedContactList = this.checkedContactList.filter(ele => ele.Id !== event.target.dataset.id);
        }   
    }

    handleAddInvitees(){
        this.checkedContactList.forEach(element => {
            if(!this.pillList.find(ele => ele.label === element.Name)){
                this.pillList  = [...this.pillList, {
                    type: 'avatar',
                    label: element.Name,
                    fallbackIconName:'standard:contact',
                    id: element.Id
                }];
                this.contactIds = [...this.contactIds, element.Id];
            }
        });
    }

    handleCreateInvitation(){
        createInvitation({ids: this.contactIds, eventId: this.currentRecordId}).then(result => {
            console.log(result);
            console.log(this.currentRecordId);
        });
    }

    handleInvitations(){
        sendEmails({eventId: this.currentRecordId}).then(result => {
            
        })
    }
}