import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getEventConfirmations from '@salesforce/apex/EventConfirmationCSV.getEventConfirmations';

export default class DownloadConfirmations extends LightningElement {
    @track urlStateParameters = null;
    urlId = null;
    registered = [];
    attended = [];
    selectedOption = 'Registered';

    get options (){ 
        return [
            { label: 'Registered', value: 'Registered' },
            { label: 'Attended', value: 'Attended' },
        ]
    }

    headers = {
        Guest_First_Name__c: 'First Name',
        Guest_Last_Name__c: 'Last Name',
        Email__c: 'Email'
        }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.attributes;
          this.setParametersBasedOnUrl();
       }
    }

    setParametersBasedOnUrl() {
        this.urlId = this.urlStateParameters.recordId || null;
    }
    connectedCallback(){
        getEventConfirmations({id: this.urlId}).then(result =>{
            this.registered = result;
            this.attended = result.filter(function(confirmation){
                return confirmation.Check_In__c == true || confirmation.Attended__c == true;
            })
        })
    }
    
    handleOption(event){
        this.selectedOption = event.detail.value;
    }

    handleDownload(){
        this.selectedOption == 'Registered' ? this.downloadCSV(this.registered, 'Registered'): this.downloadCSV(this.attended, 'Attended');
    }

    downloadCSV(list, fileName){
        var rowEnd = '\n';
        var csvString = '';
        const actualHeaderKey = Object.keys(this.headers);
        const headerToShow = Object.values(this.headers);
        csvString += headerToShow.join(',');
        csvString += rowEnd;
    
        list.forEach(obj => {
            var line = '';
            actualHeaderKey.forEach(key =>{
                if(line != ''){
                    line += ',';
                }
                var strItem = obj[key] === undefined ? '' : obj[key];
                line += strItem;
            })
            csvString += line + rowEnd;
        });
        var downloadCSVFile = document.createElement('a');
        downloadCSVFile.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadCSVFile.target = '_self';
        downloadCSVFile.download = fileName + '.csv';
        document.body.appendChild(downloadCSVFile);
        downloadCSVFile.click();
    }
}