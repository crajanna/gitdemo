import { LightningElement, wire, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import saveAccountDetails from '@salesforce/apex/AccountController.saveAccountDetails';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import {getRecord } from 'lightning/uiRecordApi';
import createAccountAccountRelationShip from '@salesforce/apex/AccountController.createAccountAccountRelationShip';


import 'c/cssLibraryFpp';
const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID]

export default class EpAddNewBeneficiary extends  NavigationMixin(LightningElement) {

    conRecord;
    isLoading = false;
    userName;
    email;
    accountIduser;
    userContactId;

    studentInterest = {};
    profileData = {};
    resVerificationData = {}

    @wire(getRecord, {
        recordId: Id,
        fields: userFileds
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            console.log( JSON.stringify( data.fields ) );
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
            this.userContactId = data.fields.ContactId.value;
          }
    }

    handleContactGeneralInfo(event){
        this.conRecord = event.detail.conRecord;
    }

    handleaddressData(event){
        console.log('event address..'+event.detail.street);

        this.conRecord.OtherStreet = event.detail.street;
        this.conRecord.OtherCity= event.detail.city;
        this.conRecord.OtherStateCode= event.detail.stateCode;
        this.conRecord.OtherPostalCode= event.detail.postalCode;
        this.conRecord.OtherCountryCode= event.detail.countryCode;
        this.conRecord.OtherState= event.detail.province;
        this.conRecord.OtherCountry= event.detail.country;
    }

    handleResidencyDocument(event){
        this.resVerificationData.verificationType = event.detail.resVerificationType;
        this.resVerificationData.file= event.detail.docFile;
        this.resVerificationData.fileName= event.detail.docFileName;
        this.resVerificationData.docType= event.detail.docType;
    }

    handleProfileImage(event){
        this.profileData.file = event.detail.profileImageData;
        this.profileData.fileName= event.detail.profileFileName;
        this.profileData.description= 'Profile_Logo';
    }

    handleSave(){       
        this.createBeneficiaryInfoWithFile();
        this.conRecord = {};
   }

    createBeneficiaryInfoWithFile() {  
        this.isLoading = true;
        saveAccountDetails({
             con: this.conRecord,
             studentInterest: JSON.stringify(this.studentInterest),
             profileData: JSON.stringify(this.profileData),  
             resVerificationData: JSON.stringify(this.resVerificationData)  
         })
         .then(result => {
             window.console.log(JSON.stringify(result));
             
             createAccountAccountRelationShip({
                  accountId : result.Id,
                  relatedAccountId: this.accountIduser,
                  reciprocalRole : 'Parent/Guardian'
              })
             .then(result => {
                 window.console.log('ep acc-acc relationship..'+JSON.stringify(result));            
                 this.isLoading = false;
             })
             .catch(error => {
                 this.isLoading = false;
                 console.log(error);
             });
 
             this.backToHomePage();
             this.isLoading = false;
         })
         .catch(error => {
             this.isLoading = false;
             console.log(error);
         });
     }

     handleCancel(){       
       this.backToHomePage();
   }

     backToHomePage(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

}