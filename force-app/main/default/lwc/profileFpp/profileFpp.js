import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import ACC_FIRST_NAME from '@salesforce/schema/Account.FirstName';
import ACC_LAST_NAME from '@salesforce/schema/Account.LastName';
import ACCOUNT_ID_PC from '@salesforce/schema/Account.Id';
import ACC_PERSON_BIRTH_DATE from '@salesforce/schema/Account.PersonBirthdate';



import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CONTRACT_ID from '@salesforce/schema/Contract.Id';
import ENROLLMENT_STATUS_C from '@salesforce/schema/Contract.Enrollment_Status__c';
import findResourceByRecord from '@salesforce/apex/ResourceController.findResourceByRecord';
import getAccountId from '@salesforce/apex/CreateFinancialAccount.getAccountId';
import saveAccountDetails from '@salesforce/apex/AccountController.saveAccountDetails';

const accountFields = [ACCOUNT_ID_PC, ACC_FIRST_NAME, ACC_LAST_NAME, ACC_PERSON_BIRTH_DATE];
const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID]

export default class ProfileFpp extends NavigationMixin(LightningElement) {
    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imagePathIconHelp = My_Resource + '/img/icon-help.png';
    imageFpo90 = My_Resource + '/img/img-fpo-alt-90px.png';
    imagesymgray = My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';


    @api contractId;
    profileSrcData;
    userId = Id;
    userName;
    email;
    accountIduser;
    userContactId;

    accountIdpc;

    conRecord;

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
            this.error = error;
        } else if (data) {
            console.log(JSON.stringify(data.fields));
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
            this.userContactId = data.fields.ContactId.value;
        }
    }

    connectedCallback(){
        getAccountId({ userID: this.userId})
        .then(data => {
            this.accountIduser = data;
            this.template.querySelector('c-contact-info-component').fetchContactInfo(this.accountIduser);
            this.template.querySelector('c-address-component').fetchAddressInfo(this.accountIduser);  
            this.template.querySelector('c-profile-image-component').fetchProfileInfo(this.accountIduser);      
          }) .catch(error => {
          //console.log('..'+error);
     });
   } 

    @wire(getRecord, {
        recordId: '$accountIduser',
        fields: accountFields
    }) wireAccount({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.accountIdpc = data.fields.Id.value;
            findResourceByRecord({
                recordId: this.accountIdpc,
                description: 'Profile_Logo'
            }).then(result => {
                this.profileSrcData = result;
            }).catch(error => {
                console.log('profile upload error..' + JSON.stringify(error));
            });
        }
    }


    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;


    handleBeneficiaryChange(event) {
    }


    handleLogout(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
        });
    }

    updateProfileInfo() {

        this.isLoading = true;
        saveAccountDetails({
             con: this.conRecord,
             studentInterest: JSON.stringify(this.studentInterest),
             profileData: JSON.stringify(this.profileData),  
             resVerificationData: JSON.stringify(this.resVerificationData)  
         })
         .then(result => {
             window.console.log(JSON.stringify(result)); 
             this.updateContract();
             this.goToNextPage();
             this.isLoading = false;
         })
         .catch(error => {
             this.isLoading = false;
             console.log(error);
         });

        window.console.log('profile this.contractId ==> ' + this.contractId);
    }


    updateContract() {
        window.console.log('inside ReviewSelectionFpp updateContract ===> ');
        const fields = {};
        fields[CONTRACT_ID.fieldApiName] = this.contractId;
        fields[ENROLLMENT_STATUS_C.fieldApiName] = "Your Profile";

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
            detail: { contractId: this.contractId }
        });
        this.dispatchEvent(passEvent);
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


    handleProfileImage(event){
        this.profileData.file = event.detail.profileImageData;
        this.profileData.fileName= event.detail.profileFileName;
        this.profileData.description= 'Profile_Logo';
    }
}