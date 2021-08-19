import { LightningElement, wire, api} from 'lwc';
import getProduct from '@salesforce/apex/FPPedgeController.getProduct';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import {getRecord } from 'lightning/uiRecordApi';
import ACC_FIRST_NAME from '@salesforce/schema/Account.FirstName';
import ACC_LAST_NAME from '@salesforce/schema/Account.LastName';
import ACCOUNT_ID_PC from '@salesforce/schema/Account.Id';
import getAccountId from '@salesforce/apex/CreateFinancialAccount.getAccountId';
import getAccountInfo from '@salesforce/apex/AccountController.getAccountInfo';
import saveAccountDetails from '@salesforce/apex/AccountController.saveAccountDetails';
import createAccountAccountRelationShip from '@salesforce/apex/AccountController.createAccountAccountRelationShip';


import 'c/spCssLibrary';
const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID]
const accountFields = [ACCOUNT_ID_PC, ACC_FIRST_NAME, ACC_LAST_NAME];
export default class SpGuardianInformation extends  NavigationMixin(LightningElement) {
    @api selectProgramId;
    @api selectedStudentId;
    @api guardianId;
    @api accountId;
    userId = Id;
    productData;
    productId;
    productName;
    productImgURL;
    priductDescription;
    productDidYouKnow;
    productLearnMoreURL;
    displayStudentQuestions = true;
    conRecord = {};
    guardianEmail ='';
    studentInterest = {};
    profileData = {};
    resVerificationData = {}
    hasRendered = false;

    existingGauardian = [];

    @wire(getRecord, {
        recordId: Id,
        fields: userFileds
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            console.log( JSON.stringify( error ) );
        } else if (data) {
            console.log( JSON.stringify( data.fields ) );
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
            this.userContactId = data.fields.ContactId.value;
          }
    }

    @wire(getRecord, {
        recordId:'$accountIduser',
        fields: accountFields
    }) wireAccount({
        error,
        data
    }) {
        if (error) {
            console.log( JSON.stringify( error ) );
        } else if (data) {
             this.existingGauardian = this.existingGauardian.filter(item => item.value  != this.accountIduser);
             const option = {
                label: data.fields.FirstName.value + ' ' + data.fields.LastName.value,
                value: this.accountIduser,
            };
            this.existingGauardian = [ ...this.existingGauardian, option ];
          }
    }

    @wire(getProduct, { productId: '$selectProgramId' })
    getProduct({ error, data }) {
        
        if (error) {
            console.log( JSON.stringify( error ) );
        } else if (data) {
            this.productData = data;
            this.productId = this.productData.Id;
            console.log('this.productId => '+this.productId);
            this.productName = this.productData.Name;
            this.productImgURL = FoundationImages + '/img/' + this.productData.Pledge_Image__c;
            this.priductDescription = this.productData.Description;
            this.productDidYouKnow = this.productData.Did_You_Know__c;
            this.productLearnMoreURL = this.productData.Learn_More_URL__c;
        }
    }
    renderedCallback(){
        if(!this.hasRendered){
            this.clearData();
            this.hasRendered = true;
        }
    }
    
    connectedCallback(){        
        getAccountId({ userID: this.userId})
        .then(data => {
            this.accountIduser = data; 
            getAccountInfo({'accountId': this.accountIduser})
            .then(data => {
                if (data) {

                    this.existingGauardian = this.existingGauardian.filter(item => item.value  != data.Id);

                    const option = {
                        label: data.FirstName + ' ' + data.LastName,
                        value: data.Id,
                    };
                    this.existingGauardian = [ ...this.existingGauardian, option ];                    
                }
            })
            .catch(error => {
                console.error("Error in fetching contact information" , error);
        });    

      }) .catch(error => {
          //console.log('..'+error);
     });
   } 

    handleGoBack(event) {
        console.log('test');
        const passEvent = new CustomEvent('previous', {
            detail: {
                selectedStudentId: this.selectedStudentId
                
            }
        });
        this.dispatchEvent(passEvent);
    }

    handleaddressData(event){

        this.conRecord.OtherStreet = event.detail.street;
        this.conRecord.OtherCity= event.detail.city;
        this.conRecord.OtherStateCode= event.detail.stateCode;
        this.conRecord.OtherPostalCode= event.detail.postalCode;
        this.conRecord.OtherCountryCode= event.detail.countryCode;
        this.conRecord.OtherState= event.detail.province;
        this.conRecord.OtherCountry= event.detail.country;
    }

    
    handleGuardianInfo(){
        console.log('handleGuardianInfo..'+this.selectedStudentId);
        console.log('guardianId..'+this.guardianId);
        if(this.isValid()){
             this.saveGuardinInfo();
        }else{
            window.scroll(0, 0);
       }   
    }

    handleContactGeneralInfo(event){
        this.conRecord = event.detail.conRecord;
    }
    saveGuardinInfo() {  

        console.log('selected student id..'+this.selectedStudentId);

        if(this.guardianEmail){
            this.conRecord.Email=this.guardianEmail;
        }
        this.isLoading = true;
        saveAccountDetails({
            con: this.conRecord,
            studentInterest: JSON.stringify(this.studentInterest),
            profileData: JSON.stringify(this.profileData),  
            resVerificationData: JSON.stringify(this.resVerificationData)             
         })
         .then(result => {
             window.console.log('guardian id..'+JSON.stringify(result)); 
             this.guardianId = result.Id;
             createAccountAccountRelationShip({
                accountId : this.selectedStudentId,
                relatedAccountId: result.Id,
                reciprocalRole : 'Parent/Guardian'
            })
           .then(result => {
               this.isLoading = false;
           })
           .catch(error => {
               this.isLoading = false;
               console.log(error);
           });
             this.conRecord = {};
             this.clearData();
             this.gotoNext();
             this.isLoading = false;
         })
         .catch(error => {
             this.isLoading = false;
             console.log(error);
         });
     }
 
    gotoNext(){
        console.log('Step 2 -> Next -> AccountId : '+this.accountId);
        console.log('Step 2 -> Next -> selectedStudentId : '+this.selectedStudentId);
        console.log('Step 2 -> Next -> guardianId : '+this.guardianId);
        const passEvent = new CustomEvent('next', {
            detail: {
                selectedStudentId: this.selectedStudentId,
                guardianId:this.guardianId,
                accountId: this.accountId
            }
        });
        this.dispatchEvent(passEvent);
    }

    handleGuardianEmailChange(event){
        this.guardianEmail = event.target.value;
        console.log('email..'+this.guardianEmail);
    }

    handleExistingGuardianSelection(event){

        getAccountInfo({'accountId': event.target.value, randomNumber: Math.random()})
        .then(data => {
            if (data) {
             
                this.guardianEmail = data.PersonEmail?data.PersonEmail:'';             

            }
        })
        .catch(error => {
            console.error("Error in fetching contact information" , error);
       }); 

        this.template.querySelector('c-contact-info-component').fetchContactInfo(event.target.value);
        this.template.querySelector('c-address-component').fetchAddressInfo(event.target.value);     
    }

    clearData(){
        this.template.querySelector('c-contact-info-component').clearData();
        this.template.querySelector('c-address-component').clearData();     
    }

    isValid(){
        var val = true;
        if(!this.template.querySelector('c-contact-info-component').validate()) {
            val = false;
        }
        return val;
    }
}