import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
import COMPANYNAME_FILED from '@salesforce/schema/Account.Name';
import EMAIL_FIELD from '@salesforce/schema/Account.Email__c';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import WEBSITE_FIELD from '@salesforce/schema/Account.Website';
import STREET_FIELD from '@salesforce/schema/Account.ShippingStreet';
import CITY_FIELD from '@salesforce/schema/Account.ShippingCity';
import STATE_FIELD from '@salesforce/schema/Account.ShippingState';
import ZIPCODE_FIELD from '@salesforce/schema/Account.ShippingPostalCode';
import BILL_STREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import BILL_CITY_FIELD from '@salesforce/schema/Account.BillingCity';
import BILL_STATE_FIELD from '@salesforce/schema/Account.BillingState';
import BILL_ZIPCODE_FIELD from '@salesforce/schema/Account.BillingPostalCode';
import findLogo from '@salesforce/apex/FpDashboardController.findImageByRecord';
import uploadLogo from '@salesforce/apex/FpDashboardController.uploadLogoToRecord';
import getStates from '@salesforce/apex/FpDashboardController.getStateOptionsList';
import user_id from '@salesforce/user/Id';

const FIELDS = [COMPANYNAME_FILED, EMAIL_FIELD, PHONE_FIELD, WEBSITE_FIELD, STREET_FIELD, CITY_FIELD, STATE_FIELD, ZIPCODE_FIELD];

export default class FpDashboardEditAccount extends NavigationMixin(LightningElement) {
    @api myranger;
    currentAccountId;
    showLogo = false;
    showSpinner = false;
    @track profileVersionId;
    @track stateList = [];
    stateData = [];
    userId = user_id;
    randomNum;
    error = '';
    accountValues = {
        companyName: "",
        email: "",
        phone: "",
        website: "",
        address1: "",
        address2: "",
        city: "",
        state: "",
        zip: ""
    };

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.currentPageReference) {
            this.currentAccountId = this.currentPageReference.state.accountId;
        }
    }

    @wire(getStates)
    states(data, error) {
        if (data) {
            var stateList = data.data;
            for (var state in stateList) {
                this.stateData.push({ value: state }); //Here we are creating the array to show on UI.
            }

            this.updateDefaultState();
        } else {

        }
    }

    @wire(getRecord, { recordId: '$currentAccountId', fields: FIELDS })
    defaultAccountValues(data, error) {
        if (data && data.data && data.data.fields) {
            var result = data.data.fields;
            this.accountValues = {
                companyName: result.Name.value ? result.Name.value : null,
                email: result.Email__c.value ? result.Email__c.value : null,
                phone: result.Phone.value ? result.Phone.value : null,
                website: result.Website.value ? result.Website.value : null,
                mobile: result.Phone.value ? result.Phone.value : null,
                address1: result.ShippingStreet.value ? result.ShippingStreet.value : null,
                address2: null,
                city: result.ShippingCity.value ? result.ShippingCity.value : null,
                state: result.ShippingState.value ? result.ShippingState.value : null,
                zip: result.ShippingPostalCode.value ? result.ShippingPostalCode.value : null,
            };
            this.accountValues.phone = this.formatPhone(this.accountValues.phone);
            this.updateDefaultState();
        } else {

        }
    }

    @wire(findLogo, { recordId: '$currentAccountId', randomNum: '$randomNum', description: 'Company Logo' })
    profileLogowireContact({
        error,
        data
    }) {
        if (error) {
            this.error = error;
            this.showLogo = false;
        } else if (data) {
            this.profileVersionId = data;
            this.showLogo = true;
        }

    }

    connectedCallback() {
        this.randomNum = Math.random(); 
    }

    updateDefaultState() {

        if (this.accountValues.state != '' && this.stateData.length > 0 && this.stateList.length == 0) {
            this.stateData.forEach(state => {
                let eachState = {
                    value: state.value,
                    selected: state.value == this.accountValues.state ? true : false
                }
                this.stateList.push(eachState);
            });
        }

    }

    readFile(fileSource) {
        return new Promise((resolve, reject) => {
            const fileReader = new FileReader();
            const fileName = fileSource.name;
            fileReader.onerror = () => reject(fileReader.error);
            fileReader.onload = () => resolve({ fileName, base64: fileReader.result.split(',')[1] });
            fileReader.readAsDataURL(fileSource);
        });
    }

    async handleFileChange(event) {
        if (event.target.files.length != 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: "test",
                    variant: 'error'
                })
            );
        } else {
            this.profileImage = await Promise.all(
                [...event.target.files].map(file => this.readFile(file))
            );

            uploadLogo({
                accountId: this.currentAccountId,
                file: encodeURIComponent(this.profileImage[0].base64),
                fileName: this.profileImage[0].fileName
            })
                .then(result => {
                    this.profileVersionId = result;
                    this.showLogo = true;
                })
                .catch(error => {
                    this.error = error.message;
                    this.showLogo = false;
                });
        }
    }


    handleEdit(event) {

        this.template.querySelector('.file1').click();
    }

    handlePhone(event) {
        const x = event.target.value
            .replace(/\D+/g, '')
            .match(/(\d{0,3})(\d{0,3})(\d{0,4})/);

        let phoneVal = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        event.target.value = phoneVal;
        this.accountValues['phone'] = phoneVal; 
    }

    handleChange(event) {
        var elementName = event.target.name;
        var elementValue = event.target.value;
        try {
            this.accountValues[elementName] = elementValue;
        } catch (e) {

        }
    }

    formatPhone(num) {
        const x = num
            .replace(/\D+/g, '')
            .match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
        let phoneVal = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        num = phoneVal;
        return num;
    }

    checkValid(event) {
        let name = event.target.name;
        let value = event.target.value;
        let constraint = {
            isMobile: /^\(\d{3}\)\s\d{3}-\d{4}$/,
            isWebsite: /[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)?/gi,
            isText: /^[a-zA-Z0-9_ ]+$/i,
            isEmail: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
            isZip: /^\d{5}$|^\d{5}-\d{4}$/
        }

        if (value !== '') {
            if (name == 'phone' && !value.match(constraint.isMobile)) {
                this.error = name;
                return this.showToast('Error', 'Please enter valid Phone Number', 'error');
            } else {
                this.error = '';
            }
            if (!new RegExp(constraint.isText).test(value) && (name == 'companyName' || name == 'city' || name == 'address1' || name == 'address2')) {
                this.error = name;
                if (name == 'companyName')
                    return this.showToast('Error', 'Please enter valid Company Name', 'error');
                else if (name == 'city')
                    return this.showToast('Error', 'Please enter valid City', 'error');
                else if (name == 'address1')
                    return this.showToast('Error', 'Please enter valid Address1', 'error');
                else if (name == 'address2')
                    return this.showToast('Error', 'Please enter valid address1', 'error');
            } else {
                this.error = '';
            }
            if (name == 'website' && !value.match(constraint.isWebsite)) {
                this.error = name;
                return this.showToast('Error', 'Please enter valid Website URL', 'error');
            } else {
                this.error = '';
            }
            if (name == 'email' && !value.match(constraint.isEmail)) {
                this.error = name;
                return this.showToast('Error', 'Please enter valid Email', 'error');
            } else {
                this.error = '';
            }
            if (name == 'zip' && !value.match(constraint.isZip)) {
                this.error = name;
                return this.showToast('Error', 'Please enter valid Zip-code', 'error');
            } else {
                this.error = '';
            }
        } else {
            if (name == 'email') {
                this.error = name;
                return this.showToast('Error', 'Please enter valid Email', 'error');
            }
        }

    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            type: variant
        });
        this.dispatchEvent(evt);
    }

    closeModal() {
        const selectedEvent = new CustomEvent('closemodal', { detail: false });
        this.dispatchEvent(selectedEvent);
    }

    handleUpdate() {
        if (this.accountValues.email === null ||
            this.accountValues.email === undefined ||
            this.accountValues.email === '') {
            return this.showToast('Error', 'Please fill required fields', 'error')
        } else {
            if (this.error == '') {

                this.showSpinner = true;
                var accId = this.currentAccountId;
                const fields = {};
                fields[ACCOUNTID_FIELD.fieldApiName] = accId;
                fields[COMPANYNAME_FILED.fieldApiName] = this.accountValues.companyName;
                fields[EMAIL_FIELD.fieldApiName] = this.accountValues.email;
                fields[PHONE_FIELD.fieldApiName] = this.accountValues.phone;
                fields[WEBSITE_FIELD.fieldApiName] = this.accountValues.website;
                fields[STREET_FIELD.fieldApiName] = this.accountValues.address1;
                fields[CITY_FIELD.fieldApiName] = this.accountValues.city;
                fields[STATE_FIELD.fieldApiName] = this.accountValues.state;
                fields[ZIPCODE_FIELD.fieldApiName] = this.accountValues.zip;
                fields[BILL_STREET_FIELD.fieldApiName] = this.accountValues.address1;
                fields[BILL_CITY_FIELD.fieldApiName] = this.accountValues.city;
                fields[BILL_STATE_FIELD.fieldApiName] = this.accountValues.state;
                fields[BILL_ZIPCODE_FIELD.fieldApiName] = this.accountValues.zip;
                const accountInput = { fields };
                this.handleNav();
                updateRecord(accountInput)
                    .then((result) => {
                        this.showSpinner = false;
                        this.handleSuccess();
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        this.handleNav();
                    })
            } else {
                this.showToast('Error', 'Entered values are not valid', 'error');
            }
        }
    }

    handleSuccess() {
        const toast = new ShowToastEvent({
            title: "Success!",
            message: 'Record has been saved.',
            variant: "success"
        });
        this.dispatchEvent(toast);
        this.handleNav();
    }

    handleNav() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'mydashboard'
            }
        });
    }

}