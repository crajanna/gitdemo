import { LightningElement, api, wire, track } from 'lwc';
import getStateOptions from '@salesforce/apex/CreatePersonAccount.getStateOptionsList';
import getCountryOptions from '@salesforce/apex/CreatePersonAccount.getCountryOptionsList';
import SUFFIX from '@salesforce/schema/Contact.Suffix__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class UtilBeneficiaryContactInfo extends LightningElement {
    // @api address;
    @track countryValues1 = [];
    @track stateValues = [];

    address = {
        street: '',
        city: '',
        province: '',
        postalCode: '',
        country: '',
    };

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

    @wire(getPicklistValues,
        {
            recordTypeId: '$contactInfo.data.defaultRecordTypeId', 
            fieldApiName: SUFFIX
        }
    )
    suffixListValues1;

    @wire(getStateOptions)
    mapOfStateData({ data, error }) {
        if (data) {
            console.log('mapOfStateData:: ' + JSON.stringify(data));
            for (let key in data) {
                // Preventing unexcepted data
                if (data.hasOwnProperty(key)) {
                    this.stateValues.push({ "label": key, "value": data[key] });
                }
            }
            // console.log('this.stateValues:: ' + JSON.stringify(this.stateValues));
        }
        else if (error) {
            window.console.log(error);
        }
    }

    @wire(getCountryOptions)
    mapOfCountryData({ data, error }) {
        if (data) {
            console.log('mapOfCountryData:: ' + JSON.stringify(data));
            for (let key in data) {
                // Preventing unexcepted data
                if (data.hasOwnProperty(key)) {
                    this.countryValues1.push({ "label": key, "value": data[key] });
                }
            }
            console.log('this.countryValues1:: ' + JSON.stringify(this.countryValues1));
            this.address.country = this.countryValues1[0].value;
        }
        else if (error) {
            window.console.log(error);
        }
    }

    get getProvinceOptions() {
        return this.stateValues = [...this.stateValues];
    }
    get getCountryOptions() {
        return this.countryValues1 = [...this.countryValues1];
    }

    handleAddressChange(event) {
        this.dispatchEvent(new CustomEvent('adressinput', {detail: event.detail}));
    }
}