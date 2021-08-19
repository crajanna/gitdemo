import {  LightningElement, track } from 'lwc';
import {  ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertCon from '@salesforce/apex/insertObject.insertCon';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
export default class insertObject extends LightningElement {
    @track conRecord = CONTACT_OBJECT;
    handleFirstNameChange(event) {
        this.conRecord.FirstName = event.target.value;
        window.console.log('First Name ==> ' + this.conRecord.FirstName);
    }
    handleLastNameChange(event) {
        this.conRecord.LastName = event.target.value;
        window.console.log('Last Name ==> ' + this.conRecord.LastName);
    }
    handlePhoneChange(event) {
        this.conRecord.Phone = event.target.value;
        window.console.log('Phone ==> ' + this.conRecord.Phone);
    }
    handleEmailChange(event) {
        this.conRecord.Email = event.target.value;
        window.console.log('Email ==> ' + this.conRecord.Email);
    }
    createRec() {
        window.console.log('In createRec ===> ');
        insertCon({
                con: this.conRecord
            })
            .then(result => {
                // Clear the user enter values
                this.conRecord = {};
                window.console.log('result ===> ' + result);
                // Show success messsage
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Contact Created Successfully!!',
                    variant: 'success'
                }), );
            })
            .catch(error => {
                this.error = error.message;
            });
    }
}