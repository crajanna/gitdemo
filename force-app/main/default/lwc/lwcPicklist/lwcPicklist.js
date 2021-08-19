import { LightningElement,wire,track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import GENDER from '@salesforce/schema/Contact.FinServ__Gender__c';
import updatePersonAccount from '@salesforce/apex/CreatePersonAccount.updatePersonAccount';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

export default class LwcPicklistWithRecordtype extends LightningElement {
    @wire(getPicklistValues,
        {
            recordTypeId: '0124W000001bAJgQAM', //pass id dynamically
            fieldApiName: GENDER
        }
    )
    stageValues;
    @track conRecord = CONTACT_OBJECT;
    handleBeneficiaryDateChange(event) {
        this.conRecord.Birthdate = event.detail.value;
        window.console.log('birthDate ==> ' + this.conRecord.Birthdate);
    }

    updateProfileInfo() {
        updatePersonAccount({
            con: this.conRecord
        })
            .then(result => {               
                window.console.log('result ===> ' + result);
               
                // Show success messsage
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Object Created Successfully',
                    variant: 'success'
                }), );
            })
            .catch(error => {
                this.error = error.message;
            });
    }
}