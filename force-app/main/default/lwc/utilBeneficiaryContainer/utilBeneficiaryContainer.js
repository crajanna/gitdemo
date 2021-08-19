import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import savePersonAccount from '@salesforce/apex/CreatePersonAccount.savePersonAccount';
import savePersonAccountWithFile from '@salesforce/apex/CreatePersonAccount.savePersonAccountWithFile';
import findResourceByRecord from '@salesforce/apex/ResourceController.findResourceByRecord';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import getStateOptions from '@salesforce/apex/CreatePersonAccount.getStateOptionsList';
import getCountryOptions from '@salesforce/apex/CreatePersonAccount.getCountryOptionsList';
import CONTRACT_BENEFICIARY_ACCOUNT_ID from '@salesforce/schema/Contract.Beneficiary_Account__c';
import CONTRACT_ID from '@salesforce/schema/Contract.Id';
import ENROLLMENT_STATUS_C from '@salesforce/schema/Contract.Enrollment_Status__c';

import 'c/cssLibraryFpp';
const MAX_FILE_SIZE = 100000000; //10mb 
const contractfields = [
    'Contract.Beneficiary_Birthdate__c'
];

export default class UtilBeneficiaryContainer extends NavigationMixin(LightningElement) {

    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imagePathIconHelp = My_Resource + '/img/icon-help.png';
    imagesymgray = My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';
    profileImage = [];
    resDoc = [];
    profileFileName;
    resDocFileName;
    @api contractId;
    isLoading = false;
    beneficiaryAccountId;
    profileVersionId;

    beneficiaryDate;

    @track hasRendered = true;
    resDocSelected;
    profileSrcData;
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

    @track countryValues = [];
    @track stateValues = [];

    address = {
        street: '',
        city: '',
        province: '',
        postalCode: '',
        country: '',
    };

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
            console.log('this.stateValues:: ' + JSON.stringify(this.stateValues));
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
                    this.countryValues.push({ "label": key, "value": data[key] });
                }
            }
            this.address.country = this.countryValues[0].value;
        }
        else if (error) {
            window.console.log(error);
        }
    }





    @track conRecord = CONTACT_OBJECT;
    @track selectedCountryLabel;
    @track selectedStateLabel;


    @wire(getRecord, { recordId: '$contractId', fields: ['Contract.Beneficiary_Birthdate__c'] })
    wiredAccount({ error, data }) {
        if (data) {
            this.beneficiaryDate = data.fields.Beneficiary_Birthdate__c.value;
        } else if (error) {
        }
    }



    get getProvinceOptions() {
        return this.stateValues = [...this.stateValues];
    }
    get getCountryOptions() {
        return this.countryValues = [...this.countryValues];
    }

    get stateOptions() {
        return array = Array.from(stateOptionsList.data, ([name, value]) => ({ name, value }));
    }

    get suffixOptions() {
        return [
            { label: '', value: '' },
        ];
    }

    handleChange(event) {
        this._country = event.detail.country;
    }

    handleInputs(event) {
        var elementName = event.detail.name;
        var elementValue = event.detail.value;

        this.conRecord[elementName] = elementValue;

        console.log('this.conRecord:: ' + JSON.stringify(this.conRecord));
    }


    handleResDocListChange(event) {
        this.resDocSelected = event.detail.value;
    }

    handleAddressChange(event) {
        this.conRecord.OtherStreet = event.detail.street;
        this.conRecord.OtherCity = event.detail.city;
        this.conRecord.OtherStateCode = event.detail.province;
        this.conRecord.OtherPostalCode = event.detail.postalCode;
        this.conRecord.OtherCountryCode = event.detail.country;
        window.console.log('OtherStreet ===> ' + this.conRecord.OtherStreet);
        window.console.log('OtherCity ===> ' + this.conRecord.OtherCity);
        window.console.log('OtherStateCode ===> ' + this.conRecord.OtherStateCode);
        window.console.log('OtherPostalCode ===> ' + this.conRecord.OtherPostalCode);
        window.console.log('OtherCountryCode ===> ' + this.conRecord.OtherCountryCode);

        this.selectedCountryLabel = this.getCountryOptions.find(opt => opt.value === event.detail.country).label;

        if (event.detail.province) {
            this.selectedStateLabel = this.getProvinceOptions.find(opt => opt.value === event.detail.province).label;
        }

        if (this.selectedCountryLabel) {
            this.conRecord.OtherCountry = this.selectedCountryLabel;
            window.console.log('OtherCountry ===> ' + this.conRecord.OtherCountry);
        }

        if (this.selectedStateLabel) {
            this.conRecord.OtherState = this.selectedStateLabel;
            window.console.log('OtherState ===> ' + this.conRecord.OtherState);
        }
    }


    handleLogout(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
        });
    }

    createBeneficiaryInfo() {
        window.console.log('this.contractId ===> ' + this.contractId);
        this.isLoading = true;
        savePersonAccount({
            con: this.conRecord,
        })
            .then(result => {
                window.console.log(JSON.stringify(result));
                this.beneficiaryAccountId = result.Id;

                // Clear the user enter values
                this.conRecord = {};

                window.console.log('this.contractId1 ===> ' + this.contractId);
                window.console.log('this.beneficiaryAccountId ===> ' + this.beneficiaryAccountId);
                this.updateContract();
                this.goToNextPage();
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error.message;
            });

    }

    createBeneficiaryInfoWithFile() {
        console.log('1');
        this.isLoading = true;

        savePersonAccountWithFile({
            con: this.conRecord,
            file: encodeURIComponent(this.profileImage[0].base64),
            fileName: this.profileImage[0].fileName,
            description: 'Profile_Logo',
            docfile: encodeURIComponent(this.resDoc[0].base64),
            docfileName: this.resDoc[0].fileName,
            docType: this.resDocSelected

        })
            .then(result => {
                console.log('2');
                window.console.log(JSON.stringify(result));
                console.log('3');
                this.beneficiaryAccountId = result.Id;
                console.log('4');

                this.conRecord = {};

                console.log('5');
                this.updateContract();
                console.log('6');
                this.goToNextPage();
                console.log('7');
                this.isLoading = false;

            })
            .catch(error => {
                console.log('error:: ' + JSON.stringify(error));
                this.error = error.message;
            });
    }

    updateContract() {
        window.console.log('inside updateContract ===> ');
        const fields = {};
        fields[CONTRACT_ID.fieldApiName] = this.contractId;
        fields[CONTRACT_BENEFICIARY_ACCOUNT_ID.fieldApiName] = this.beneficiaryAccountId;
        fields[ENROLLMENT_STATUS_C.fieldApiName] = "Beneficiary Info";

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Profile updated successfully',
                        variant: 'success'
                    })
                );

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    goToNextPage() {
        const passEvent = new CustomEvent('next', {
            detail: {
                contractId: this.contractId,
            }
        });
        this.dispatchEvent(passEvent);
    }

    handleFileChange(event) {
        console.log('event.detail filechange:: ' + JSON.stringify(event.detail));
        this.profileImage = event.detail;
        this.profileFileName = this.profileImage[0].fileName;
        this.profileSrcData = 'data:image/jpg;base64,' + this.profileImage[0].base64;
    }

    handleResDocFileChange(event) {
        console.log('event.detail resdocfilechange:: ' + JSON.stringify(event.detail));
        this.resDoc = event.detail;
        this.resDocFileName = this.resDoc[0].fileName;
    }

}