import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import { NavigationMixin } from 'lightning/navigation';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import RESIDENCY_DOC from '@salesforce/schema/Contact.Residency_Documentation__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import 'c/cssLibraryFpp';
const MAX_FILE_SIZE = 100000000; //10mb 

export default class ResidencyVerificationComponent extends LightningElement {

    resDoc = [];
    resDocFileName;
    showDocUpload = false;
    showDriverLicense = false;
    resVerificationValue = 'Online verificaton';
    resDocSelected;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

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


    handleResVerificationChange(event){
        this.showDocUpload = false;
        this.resVerificationValue = event.detail.value;
        if(event.detail.value == 'Online verificaton'){
            this.showDocUpload = true;
        }
    }

    handleResDocListChange(event){
        this.showDocUpload = true;
        this.showDriverLicense =false;
        this.resDocSelected = event.detail.value;
        if(event.detail.value == 'Driver’s license'){
            this.showDocUpload = false;
            this.showDriverLicense =true;
        }
    }

    
    async handleResDocFileChange(event){
        if (event.target.files.length !=1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: "test",
                    variant: 'error'
                })
            );
        } else{
            this.resDoc = await Promise.all(
                [...event.target.files].map(file => this.readFile(file))
              );
              window.console.log( 'this.resDoc[0].base64'+this.resDoc[0].base64);   
              window.console.log( 'fileName'+this.resDoc[0].fileName );   
              this.resDocFileName = this.resDoc[0].fileName;
              this.sendResidencyDocumentData();
              // Here, you can now upload the files to the server //
        } 
     }

     
    readFile(fileSource) {
        return new Promise((resolve, reject) => {
          const fileReader = new FileReader();
          const fileName = fileSource.name;
          fileReader.onerror = () => reject(fileReader.error);
          fileReader.onload = () => resolve({ fileName, base64: fileReader.result.split(',')[1]});
          fileReader.readAsDataURL(fileSource);
        });
      }

      sendResidencyDocumentData(){
        const passEvent = new CustomEvent('handleresidencydocument', {
            detail:{
                resVerificationType: this.resVerificationValue,
                docFile: encodeURIComponent(this.resDoc[0].base64),  
                docFileName: this.resDoc[0].fileName,
                docType: this.resDocSelected
            } 
        });
         this.dispatchEvent(passEvent);
    }

}