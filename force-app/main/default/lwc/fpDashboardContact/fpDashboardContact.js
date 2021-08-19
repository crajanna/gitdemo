import { LightningElement, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CONTACT_ID_FIELD from '@salesforce/schema/Contact.Id';
import ACC_CON_RELATION_OBJECT from '@salesforce/schema/AccountContactRelation';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import ACCOUNTNAME_FIELD from '@salesforce/schema/Contact.Account.Name';
import MOBILE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import ROLEUP_FIELD from '@salesforce/schema/AccountContactRelation.FinServ__Rollups__c';
import STREET_FIELD from '@salesforce/schema/Contact.MailingStreet';
import CITY_FIELD from '@salesforce/schema/Contact.MailingCity';
import STATE_FIELD from '@salesforce/schema/Contact.MailingState';
import ZIPCODE_FIELD from '@salesforce/schema/Contact.MailingPostalCode';
import account_id from '@salesforce/schema/User.AccountId';
import user_id from '@salesforce/user/Id';
import createContact from '@salesforce/apex/CreatePortalUserController.createContactPortalUser';
import updateContactRole from '@salesforce/apex/FpDashboardController.updateContactRole';
import getStates from '@salesforce/apex/FpDashboardController.getStateOptionsList';

const FIELDS = [FIRSTNAME_FIELD, LASTNAME_FIELD, PHONE_FIELD, ACCOUNTNAME_FIELD, MOBILE_FIELD, TITLE_FIELD, EMAIL_FIELD, STREET_FIELD, CITY_FIELD, STATE_FIELD, ZIPCODE_FIELD];

export default class FpDashboardContact extends NavigationMixin(LightningElement) {

    @track contactValues = {
        firstName: "",
        lastName: "",
        phone: "",
        accountName: "",
        mobile: "",
        title: "",
        email: "",
        roles: "",
        address1: "",
        address2: "",
        city: "",
        state: "",
        zip: ""
    };
    @track stateList = [];
    stateData = [];
    showSpinner = false;
    @track conObjectInfo;
    @track accConObjectInfo;
    currentAccountId = '';
    currentPageReference;
    contactId;
    existingContact;
    error;


    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    conObjectInfo;

    @wire(getObjectInfo, { objectApiName: ACC_CON_RELATION_OBJECT })
    accConObjectInfo;

    get recordTypeId() {
        const rtis = this.conObjectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Business');
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.currentPageReference) {
            this.contactId = this.currentPageReference.state.contactId;
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

    @wire(getRecord, { recordId: user_id, fields: [account_id] })
    user(data, error) {
        if (data) {
            var result = data;
            if (result.data && result.data.fields && result.data.fields.AccountId) {
                this.currentAccountId = result.data.fields ? result.data.fields.AccountId.value : null;
            }
        } else {

        }
    }

    @wire(getRecord, { recordId: '$contactId', fields: FIELDS })
    defaultContactValues(data, error) {
        this.existingContact = data;
        if (data && data.data && data.data.fields) {
            var result = data.data.fields;
            this.contactValues = {
                firstName: result.FirstName.value ? result.FirstName.value : null,
                lastName: result.LastName.value ? result.LastName.value : null,
                phone: result.Phone.value ? result.Phone.value : null,
                mobile: result.MobilePhone.value ? result.MobilePhone.value : null,
                title: result.Title.value ? result.Title.value : null,
                email: result.Email.value ? result.Email.value : null,
                address1: result.MailingStreet.value ? result.MailingStreet.value : null,
                address2: null,
                city: result.MailingCity.value ? result.MailingCity.value : null,
                state: result.MailingState.value ? result.MailingState.value : null,
                zip: result.MailingPostalCode.value ? result.MailingPostalCode.value : null
            };
            this.contactValues.phone = this.formatPhone(this.contactValues.phone);
            this.updateDefaultState();
        } else {

        }
    }

    @wire(getPicklistValues, { recordTypeId: '$accConObjectInfo.data.defaultRecordTypeId', fieldApiName: ROLEUP_FIELD })
    roleValues(data, error) {
        if (data) {
        }

    };

    updateDefaultState() {

        if (this.stateData.length > 0) {
            if (this.contactValues.state != '') {

                this.stateData.forEach(state => {
                    let eachState = {
                        value: state.value,
                        selected: state.value == this.contactValues.state ? true : false
                    }
                    this.stateList.push(eachState);
                });
            } else {
                this.stateList = this.stateData;
            }
        }
    }

    handlePhone(event) {
        const x = event.target.value
            .replace(/\D+/g, '')
            .match(/(\d{0,3})(\d{0,3})(\d{0,4})/);

        let phoneVal = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        event.target.value = phoneVal;

        this.contactValues['phone'] = event.target.value;
    }

    handleChange(event) {
        var elementName = event.target.name;
        var elementValue = event.target.value;
        try {
            this.contactValues[elementName] = elementValue;
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
            if (!new RegExp(constraint.isText).test(value) && (name == 'firstName' || name == 'lastName' || name == 'city' || name == 'address1' || name == 'address2')) {
                this.error = name;
                if (name == 'firstName')
                    return this.showToast('Error', 'Please enter valid First Name', 'error');
                else if (name == 'lastName')
                    return this.showToast('Error', 'Please enter valid Last Name', 'error');
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


    handleSave() {
        if (this.isRequired()) {
            return this.showToast('Error', 'Please fill required fields', 'error');
        } else {
            if (this.error == '') {

                this.showSpinner = true;
                createContact({
                    firstName: this.contactValues.firstName, lastName: this.contactValues.lastName, email: this.contactValues.email,
                    businessName: '', masterContactAgreement: '', accountId: this.currentAccountId
                })
                    .then((result) => {
                        this.contactId = result.ContactId;
                        this.updateMailingAddress();
                        this.handleRoleUpdate();
                        this.showSpinner = false;
                        this.displaySuccessToast('saved');

                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        if(error.body.message.includes('DUPLICATE_USERNAME')){
                            this.showToast('Error', 'Email Address already exist.', 'error');
                        }
                    })


            } else {
                this.showToast('Error', 'Entered values are not valid', 'error');
            }
        }

    }

    isRequired() {
        if (this.contactValues.firstName === null ||
            this.contactValues.firstName === undefined ||
            this.contactValues.firstName === '' ||
            this.contactValues.lastName === null ||
            this.contactValues.lastName === undefined ||
            this.contactValues.lastName === '' ||
            this.contactValues.email === null ||
            this.contactValues.email === undefined ||
            this.contactValues.email === '') {
            return true;
        } else {
            return false;
        }
    }

    handleUpdate() {
        if (this.isRequired()) {
            return this.showToast('Error', 'Please fill required fields', 'error');
        } else {
            if (this.error == '') {
                this.showSpinner = true;
                var fields = {};
                fields[CONTACT_ID_FIELD.fieldApiName] = this.contactId;
                fields[FIRSTNAME_FIELD.fieldApiName] = this.contactValues.firstName ? this.contactValues.firstName : '';
                fields[LASTNAME_FIELD.fieldApiName] = this.contactValues.lastName ? this.contactValues.lastName : '';
                fields[PHONE_FIELD.fieldApiName] = this.contactValues.phone ? this.contactValues.phone : '';
                fields[ACCOUNTNAME_FIELD.fieldApiName] = this.contactValues.accountName;
                fields[MOBILE_FIELD.fieldApiName] = this.contactValues.mobile ? this.contactValues.mobile : '';
                fields[TITLE_FIELD.fieldApiName] = this.contactValues.title ? this.contactValues.title : '';
                fields[EMAIL_FIELD.fieldApiName] = this.contactValues.email ? this.contactValues.email : '';
                fields[STREET_FIELD.fieldApiName] = this.contactValues.address1 ? this.contactValues.address1 : '';
                fields[CITY_FIELD.fieldApiName] = this.contactValues.city ? this.contactValues.city : '';
                fields[STATE_FIELD.fieldApiName] = this.contactValues.state ? this.contactValues.state : '';
                fields[ZIPCODE_FIELD.fieldApiName] = this.contactValues.zip ? this.contactValues.zip : '';

                const contactInput = { fields };

                updateRecord(contactInput)
                    .then((result) => {
                        this.handleRoleUpdate();
                        this.showSpinner = false;

                        this.displaySuccessToast('updated');
                        this.handleNav();
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        if(error.body.message.includes('DUPLICATE_USERNAME')){
                            this.showToast('Error', 'Email Address already exist.', 'error');
                        }
                    })
            } else {
                this.showToast('Error', 'Entered values are not valid', 'error');
            }
        }
    }

    updateMailingAddress() {
        var fields = {};
        fields[CONTACT_ID_FIELD.fieldApiName] = this.contactId;
        fields[STREET_FIELD.fieldApiName] = this.contactValues.address1 ? this.contactValues.address1 : '';
        fields[CITY_FIELD.fieldApiName] = this.contactValues.city ? this.contactValues.city : '';
        fields[STATE_FIELD.fieldApiName] = this.contactValues.state ? this.contactValues.state : '';
        fields[ZIPCODE_FIELD.fieldApiName] = this.contactValues.zip ? this.contactValues.zip : '';
        const contactInput = { fields };

        updateRecord(contactInput)
            .then((result) => {
                this.showSpinner = false;
                this.handleNav();
            })
            .catch((error) => {
                this.showSpinner = false;
                this.displayErrorToast(error);
            })
    }

    handleRoleUpdate() {
        updateContactRole({ accId: this.currentAccountId, conId: this.contactId, role: 'Registered Agent' })
            .then((success) => {
                this.showSpinner = false;
                this.handleNav();
            })
            .catch((error) => {
                this.showSpinner = false;
                this.displayErrorToast(error);
            })
    }


    handleNav() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'mydashboard'
            }
        });
    }

    displaySuccessToast(msg) {
        const toast = new ShowToastEvent({
            title: "Success!",
            message: 'Record has been ' + msg,
            variant: "success"
        });
        this.dispatchEvent(toast);
    }

    displayErrorToast(error) {
        var errMsg = 'Error occurred: ';
        if (error.body && error.body.message) {
            errMsg += error.body.message;
        }
        const toast = new ShowToastEvent({
            title: "Error!",
            message: errMsg,
            variant: "error"
        });
        this.dispatchEvent(toast);
    }

}