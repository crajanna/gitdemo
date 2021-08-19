import { LightningElement, api, track } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import {  ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertCon from '@salesforce/apex/insertObject.insertCon';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import  'c/mainCssLibrary';

export default class RegistrationPage extends LightningElement {

    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imagesymblack= My_Resource + '/img/logo-fl-prepaid-symbol-black-260px.png';

    @api contactId;

    // renderedCallback() {
    //     Promise.all([
    //         loadScript(this, bootstrap + '/bootstrap-4.6.0-dist/js/bootstrap.js'),          
    //         loadStyle(this, bootstrap + '/bootstrap-4.6.0-dist/css/bootstrap.css')
    //     ])
    //         .then(() => {
    //             console.log("All scripts and CSS are loaded. perform any initialization function.")
    //         })
    //         .catch(error => {
    //             console.log("failed to load the scripts");
    //         });
    // }

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
        window.console.log('In createRec ===> '+this.conRecord.FirstName + this.conRecord.LastName );
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
                window.console.log('result ===> ' + this.error);
            });
    }

   
    handleSuccess(event) {
        const conId = event.detail.id;
        this.dispatchEvent(new CustomEvent('next', {detail: conId}));
    }

}