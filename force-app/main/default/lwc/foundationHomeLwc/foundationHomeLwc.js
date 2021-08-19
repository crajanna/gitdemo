import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import getLogoUrl from '@salesforce/apex/DemiImg.getLogoUrl';
import { getRecord } from 'lightning/uiRecordApi';


const userFileds = [ACCOUNT_ID];

export default class FoundationHomeLwc extends NavigationMixin(LightningElement) {

    userId = Id;
    accountIduser;
    fppLogoUrl = '';
    displayFileUpload = false;
    @wire( getRecord, { recordId: Id, fields: userFileds } ) 
    wireuser( { error, data } ) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.accountIduser = data.fields.AccountId.value;
        }
    }

    get acceptedFormats() {
        return ['.jpg', '.png'];
    }


    handleContactClick(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'contactinfopage'
            }
        });
    
    }

    handleBusinessClick(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'businessinfopage'
            }
        });
    
    }
    handleUploadFinished (event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        /*alert("No. of files uploaded : " + uploadedFiles.length);
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }*/
        console.log('No. of files uploaded : ' + uploadedFiles.length);
        if(uploadedFiles.length > 0){
            console.log('accountIduser = > '+this.accountIduser);
            getLogoUrl({accountId: this.accountIduser})
            .then(result => {
                console.log('Logo Url =>: '+result);
                this.fppLogoUrl = result;
                this.displayFileUpload = true;
                window.location.reload();
                })
            .catch(error => {
                console.log('Error Generated :'+error);
                this.displayFileUpload = false;
                console.log('this.displayFileUpload ==> '+this.displayFileUpload);
                this.error = error;
            });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                    variant: 'success',
                }),
            );
        }
    }

    updateLogo(){
        this.this.displayFileUpload = true;
    }
    renderedCallback() {
        console.log('Console call back called');
        getLogoUrl({accountId: this.accountIduser})
            .then(result => {
                console.log('Logo Url =>: '+result);
                this.fppLogoUrl = result;
                this.displayFileUpload = true;
                })
            .catch(error => {
                console.log('Error Generated in render call back:'+error);
                this.displayFileUpload = fasle;
                this.error = error;
            });
    }

    
}