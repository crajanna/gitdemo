import { LightningElement, track, wire, api } from 'lwc';
import createPortalUser from '@salesforce/apex/SPCreatePortalUserController.createPortalUser';
import isExistingUser from '@salesforce/apex/CreatePortalUserController.isExistingUser';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';

import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
// import 'c/spCssLibrary';
import 'c/fpCssLibrary';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class SpSelfRegistration extends LightningElement {

    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track businessName = '';
    @track checkBoxFieldValue = false;
    @track hideBusinessName = false;

    orgUserId = '';
    uniqueEmail = false;
    enableSignup = true;
    @api isLoaded = false;

    imgUrl = FoundationImages + '/img/bg-grad-dad.jpg';
    logoURL = FoundationImages + '/img/logo-flpp-foundation-color.svg';

    @wire(getObjectInfo, { objectApiName: 'ACCOUNT' }) objectInfo;

    contactChangeVal(event) {

        if (event.target.name == 'firstName') {
            this.firstName = event.target.value;
        }

        if (event.target.name == 'lastName') {
            this.lastName = event.target.value;
        }

        if (event.target.name == 'email') {
            this.email = event.target.value;
            isExistingUser({ email: this.email })
                .then(result => {
                    if (result == true) {
                        this.uniqueEmail = true;
                        this.enableSignup = false;
                    } else {
                        this.uniqueEmail = false;
                        this.enableSignup = true;
                    }
                })
                .catch(error => {
                    this.error = error;
                    this.uniqueEmail = false;
                    console.log('Error while fetching Contact info:' + this.error);
                });
        }

        if (event.target.name == 'ownBusiness') {
            if (event.target.checked) {
                this.hideBusinessName = true;
                if (this.firstName != '' && this.lastName != '')
                    this.businessName = this.firstName + ' ' + this.lastName;
            } else {
                this.hideBusinessName = false;
                this.businessName = '';
            }
            console.log('this.businessName:: ' + this.businessName);
        }

        if (event.target.name == 'businessName') {
            this.businessName = event.target.value;
        }

        if (event.target.name == 'acceptTerms') {
            this.checkBoxFieldValue = event.target.checked;
        }
    }

    handleClick() {
        console.log('Button clicked');
        console.log('' + this.firstName + '--- lastName: ' + this.lastName + ' --- ' + this.email);

        let recordTypeId;
        console.log('Person Account RecordType Id : '+recordTypeId);

        createPortalUser({ firstName: this.firstName, lastName: this.lastName, email: this.email, businessName: this.businessName, masterContactAgreement: this.checkBoxFieldValue })
            .then(result => {
                if (result != null) {
                    this.redirectToSuccessPage();
                } else {
                    this.isLoaded = false;
                    this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');
                    this.error = undefined;
                }
            })
            .catch(error => {
                this.isLoaded = false;
                this.error = error;
                this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');
            });

    }


    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            type: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    redirectToSuccessPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'regSuccessResendEmail'
            },
            state: {
                username: this.email
            }
        });
    }

    get logo() {
        return this.logoURL;
    }

    get imageURL() {
        return `background-image: url(${this.imgUrl}) no-repeat center right fixed;`
    }

}