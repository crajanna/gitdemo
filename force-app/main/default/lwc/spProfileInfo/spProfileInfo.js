import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import saveAccountDetails from '@salesforce/apex/AccountController.saveAccountDetails';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import { getRecord, getRecordNotifyChange  } from 'lightning/uiRecordApi';
import getAccountId from '@salesforce/apex/CreateFinancialAccount.getAccountId';
import 'c/spCssLibrary';
const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID]
const accountFields = [ 'Account.Phone', 'Account.PersonBirthdate' ];

export default class SpProfileInfo extends NavigationMixin(LightningElement) {

    userId = Id;
    accountId;
    resDocSelected;
    profileSrcData;

    docFile;
    docfileName;
    docType;
    profileImage;
    profileImageName;
    resVerificationType;
    conRecord ={};
    isLoading = false;
    selectedRelationship;
    userName;
    email;
    accountIduser;
    userContactId;

    goals = '';
    orgList = '';
    hobby3 = '';
    hobby2 = '';
    hobby1 = '';
    hobbyList = [];
    favSubject = '';

    studentInterest = {};
    profileData = {};
    resVerificationData = {}

    PersonBirthdate;
    phone;


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
        recordId: Id,
        fields: userFileds
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
            this.userContactId = data.fields.ContactId.value;
        }
    }

    
    @wire(getRecord, {
        recordId: '$accountIduser',
        fields: accountFields
    }) wireAccount({
        error,
        data
    }) {
        if (error) {
        } else if (data) {
            if (data && data.fields) {
             this.phone = data.fields.Phone.value? this.formatPhone(data.fields.Phone.value):'';
             this.PersonBirthdate = data.fields.PersonBirthdate.value;
            }

        }
    }




    handleNext() {
        if(this.isValid()){
            this.createBeneficiaryInfoWithFile();
        }else{
            window.scroll(0, 0);
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

    createBeneficiaryInfoWithFile() {
        this.isLoading = true;
        if(this.phone){
            this.conRecord.Phone = this.phone;            
        }
        if(this.PersonBirthdate){
            this.conRecord.Birthdate = this.PersonBirthdate;
        }
        saveAccountDetails({
            con: this.conRecord,
            studentInterest: JSON.stringify(this.studentInterest),
            profileData: JSON.stringify(this.profileData),
            resVerificationData: JSON.stringify(this.resVerificationData)
        })
            .then(result => {
                getRecordNotifyChange([{recordId: result.Id}]);
                this.conRecord = {};
                this.clearData();
                this.backToHomePage();
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                console.log(error);
            });
    }

    clearData() {
        this.template.querySelector('c-contact-info-component').clearData();
        this.template.querySelector('c-address-component').clearData();
        this.template.querySelector('c-profile-image-component').clearData();
    }

    //captures the retrieve event propagated from lookup component
    selectItemEventHandler(event) {
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        // this.displayItem(args);        
    }

    //captures the remove event propagated from lookup component
    deleteItemEventHandler(event) {
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        // this.displayItem(args);
    }

    //displays the items in comma-delimited way
    // displayItem(args){
    //     this.values = []; //initialize first
    //     args.map(element=>{
    //         this.values.push(element.label);
    //     });

    //     this.isItemExists = (args.length>0);
    //     this.selectedItemsToDisplay = this.values.join(', ');
    // }


    handleContactGeneralInfo(event) {
        this.conRecord = event.detail.conRecord;
    }

    handleaddressData(event) {

        this.conRecord.OtherStreet = event.detail.street;
        this.conRecord.OtherCity = event.detail.city;
        this.conRecord.OtherStateCode = event.detail.stateCode;
        this.conRecord.OtherPostalCode = event.detail.postalCode;
        this.conRecord.OtherCountryCode = event.detail.countryCode;
        this.conRecord.OtherState = event.detail.province;
        this.conRecord.OtherCountry = event.detail.country;
    }

    handleResidencyDocument(event) {

        this.resVerificationData.verificationType = event.detail.resVerificationType;
        this.resVerificationData.file = event.detail.docFile;
        this.resVerificationData.fileName = event.detail.docFileName;
        this.resVerificationData.docType = event.detail.docType;

    }

    handleProfileImage(event) {

        this.profileData.file = event.detail.profileImageData;
        this.profileData.fileName = event.detail.profileFileName;
        this.profileData.description = 'Profile_Logo';
    }

    handlePhoneChange(event){
        const phonePattern = /^\(\d{3}\)\s\d{3}-\d{4}$/;
        const x = event.target.value
            .replace(/\D+/g, '')
            .match(/(\d{0,3})(\d{0,3})(\d{0,4})/);

        let phoneVal = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        event.target.value = phoneVal;
        this.phone = event.target.value;
        this.conRecord.Phone =event.target.value;
    }

    handleBeneficiaryDateChange(event){
        this.PersonBirthdate = event.target.value;
    }
 
    backToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

    clearData() {
        this.template.querySelector('c-contact-info-component').clearData();
        this.template.querySelector('c-address-component').clearData();
        this.template.querySelector('c-profile-image-component').clearData();
    }

    isValid(){
        var val = true;
        if(!this.template.querySelector('c-contact-info-component').validate()) {
            val = false;
        }
        return val;
    }

}