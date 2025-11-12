import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getconfigurations from '@salesforce/apex/EventSalesPanel.findConfigurations';
import updateConfigurations from '@salesforce/apex/EventSalesPanel.updateConfigurations';

export default class Event4Sales_Panelconfiguration extends LightningElement {

    configurations = [];
    updatebutton = true;
    isLoaded = false;
    hasdata = false;

    connectedCallback() {
        this.isLoaded = true;
        getconfigurations().then(result => {
            this.isLoaded = false;
            if(result && result.isOk) {
                console.log('params:: ', result);
                this.configurations = result.lstParams;
                this.hasdata = true;
            } else {
                this.showToastMsg('Error', 'error', result.message);
            }
        }).catch(error => {
            this.isLoaded = false;
            this.showToastMsg('Error', 'error', error.message);
        });
    }

    onchangeParam(event) {
        this.updatebutton = false;
        let paramValueboll = false;
        let paramValue = '';
        let finalId = '';
        finalId = event.target.getAttribute("data-paramid");
        let typeParam = event.target.getAttribute("data-typeparam");
        paramValue = event.target.value;
        paramValueboll = event.target.checked;
        let isInteger = event.target.getAttribute("data-isinteger");
        let isBoolean = event.target.getAttribute("data-isboolean");
        switch (typeParam) {
            case "integer":
                console.log('typeParam::: ',typeParam, 'Integer');
                paramValue = parseInt(paramValue);
                break;
            case "boolean":
                console.log('typeParam::: ',typeParam, 'boolean');
                paramValueboll = Boolean(paramValueboll);
                break;
            default:
                console.log('typeParam::: ',typeParam);
                break;
        }
        this.configurations.forEach(configParam => {
            console.log('isInteger::: ', isInteger, 'isBoolean::: ', isBoolean, 'paramValue:::',paramValue, 'paramValueboll:::: ',paramValueboll, 'Id:: ',configParam.paramId);
            if(configParam.paramId === finalId) {
                if(isInteger === 'true') {
                    configParam.integerParam = paramValue;
                }
                if(isBoolean === 'true') {
                    configParam.booleanParam = paramValueboll;
                }
            }
        });
        console.log('this.configurations::: ',this.configurations);
    }

    onSaveConfiguration() {
        this.isLoaded = true;
        let lstConfigs = JSON.stringify(this.configurations);
        console.log('lstConfigs:::: ',lstConfigs);
        updateConfigurations({jsonLstParams: lstConfigs}).then(result=> {
            this.isLoaded = false;
            if(result && result.isOk) {
                this.showToastMsg('Configuration updated', 'success', 'New values updated success');
                this.cancelupdate();
            } else {
                this.showToastMsg('Error', 'error', result.message);
            }
        }).catch(error => {
            this.isLoaded = false;
            this.showToastMsg('Error', 'error', error.message);
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

    cancelupdate() {
        this.updatebutton = true;
        this.isLoaded = true;
        getconfigurations().then(result => {
            this.isLoaded = false;
            if(result && result.isOk) {
                this.hasdata = false;
                console.log('params:: ', result);
                this.configurations = result.lstParams;
                this.hasdata = true;
            } else {
                this.showToastMsg('Error', 'error', result.message);
            }
        }).catch(error => {
            this.isLoaded = false;
            this.showToastMsg('Error', 'error', error.message);
        });
    }
}