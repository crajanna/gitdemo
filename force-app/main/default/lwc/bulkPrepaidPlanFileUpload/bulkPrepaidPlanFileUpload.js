import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import createPrepaidPlans from '@salesforce/apex/bulkPrepaidUploadController.createPrepaidPlans';

const columns = [
    { label: 'Primary Owner', fieldName: 'FinServ__PrimaryOwner__c' }, 
    { label: 'Ownership', fieldName: 'FinServ__Ownership__c' },
    { label: 'Type', fieldName: 'FinServ__FinancialAccountType__c'}
];

export default class BulkPrepaidPlanFileUpload extends LightningElement {
    @api recordId;
    @track error;
    @track columns = columns;
    @track data;

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }
    
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        // calling apex class
        createPrepaidPlans({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {
            window.console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Prepaid Plans are created based CSV file!!!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );     
        })

    }
}