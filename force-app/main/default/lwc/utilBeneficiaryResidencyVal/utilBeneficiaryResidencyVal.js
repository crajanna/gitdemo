import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, wire } from 'lwc';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import RESIDENCY_DOC from '@salesforce/schema/Contact.Residency_Documentation__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UtilBeneficiaryResidencyVal extends LightningElement {
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;
    showDocUpload = false;
    showDriverLicense = false;
    resVerificationValue = 'Online verificaton';
    profileImage = [];
    resDoc = [];

    @wire(getPicklistValues,
        {
            recordTypeId: '$contactInfo.data.defaultRecordTypeId',
            fieldApiName: RESIDENCY_DOC
        }
    )
    resDocPicklistValues;

    get resVerificationOptions() {
        return [
            { label: 'Online verificaton', value: 'Online verificaton' },
            { label: 'Mail in verificaton', value: 'Mail in verificaton' },
        ];
    }

    handleResVerificationChange(event) {
        this.showDocUpload = false;
        if (event.detail.value == 'Online verificaton') {
            this.showDocUpload = true;
        }
    }

    handleResDocListChange(event) {
        this.showDocUpload = true;
        this.showDriverLicense = false;
        this.dispatchEvent(new CustomEvent('resdocselected', { detail: event.detail.value }));
        if (event.detail.value == 'Driver’s license') {
            this.showDocUpload = false;
            this.showDriverLicense = true;
        }
    }

    // handleResDocFileChange(event) {
    //     this.dispatchEvent(new CustomEvent('resdocfilechange', {target: event.target}));
    // }

    // handleFileChange(event) {
    //     console.log('event.target in residencyVal:: '+JSON.stringify(event.target.files));
    //     this.dispatchEvent(new CustomEvent('filechange', {target: event.target}));
    // }

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

            window.console.log('this.profileImage[0].base64' + this.profileImage[0].base64);
            window.console.log('fileName' + this.profileImage[0].fileName);

            this.dispatchEvent(new CustomEvent('filechange', { detail: this.profileImage }));
            // Here, you can now upload the files to the server //
        }
    }

    async handleResDocFileChange(event) {
        if (event.target.files.length != 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: "test",
                    variant: 'error'
                })
            );
        } else {
            this.resDoc = await Promise.all(
                [...event.target.files].map(file => this.readFile(file))
            );
            window.console.log('this.resDoc[0].base64' + this.resDoc[0].base64);
            window.console.log('fileName' + this.resDoc[0].fileName);
            //   this.resDocFileName = this.resDoc[0].fileName;

            this.dispatchEvent(new CustomEvent('resdocfilechange', { detail: this.resDoc }));
            // Here, you can now upload the files to the server //
        }
    }
}