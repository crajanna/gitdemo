import { LightningElement, wire, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import saveAccountDetails from '@salesforce/apex/AccountController.saveAccountDetails';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import {getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAccountAccountRelationShip from '@salesforce/apex/AccountController.createAccountAccountRelationShip';


import 'c/spCssLibraryNew';
const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID]

export default class SpNewAccount extends  NavigationMixin(LightningElement) {

    
    productData;
    productId;
    productName;
    productImgURL;
    priductDescription;
    productDidYouKnow;
    productLearnMoreURL;
    displayStudentQuestions = true;
    selectedStudentId;

    resDocSelected;
    profileSrcData;

    docFile;
    docfileName;
    docType;
    profileImage;
    profileImageName;
    resVerificationType;
    conRecord={};
    isLoading = false;
    selectedRelationship;
    userName;
    email;
    accountIduser;
    userContactId;

    goals ='';
    orgList ='';
    hobby3 ='';
    hobby2 ='';
    hobby1 ='';
    hobbyList = [];
    favSubject ='';

    studentInterest = {};
    profileData = {};
    resVerificationData = {}

    relationshipList = [
        {label: "I am a Parent/Guardian to the student", value: "I am a Parent/Guardian to the student"},
        {label: "I am the student", value: "I am the student"}

    ];

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
           // this.clearData();

           this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
            this.userContactId = data.fields.ContactId.value;
          }
    }


    handleSave(){
        this.isLoading = true;

    }

    renderedCallback(){
       this.clearData();
    }

    handleNext(){   
        if(this.isValid()){
         this.createBeneficiaryInfoWithFile();
         this.conRecord = {};
        }else{
            window.scroll(0, 0);
        }    
        
    }


    handleRelationshipToStudentSelection(event){
        this.selectedRelationship = event.target.value;
        this.showExistingStudentInfo = false;
        if(this.selectedRelationship =='I am the student'){
            this.showExistingStudentInfo = false;
            this.template.querySelector('c-contact-info-component').fetchContactInfo(this.accountIduser);
            this.template.querySelector('c-address-component').fetchAddressInfo(this.accountIduser);     
            this.template.querySelector('c-profile-image-component').fetchProfileInfo(this.accountIduser);      
        }else{
            this.showExistingStudentInfo = true;
            this.clearData();
        }
    }

    handleBeneficiaryDateChange(event){
        this.conRecord.Birthdate =event.target.value;
    }

    
    createBeneficiaryInfoWithFile() {  
       this.isLoading = true;
       this.conRecord.Id=null;

       console.log('this.conRecord ==> '+JSON.stringify(this.conRecord));
       console.log('this.studentInterest ==> '+JSON.stringify(this.studentInterest));
       console.log('this.profileData ==> '+JSON.stringify(this.profileData));
       console.log('this.resVerificationData ==> '+JSON.stringify(this.resVerificationData));
       saveAccountDetails({
            con: this.conRecord,
            studentInterest: JSON.stringify(this.studentInterest),
            profileData: JSON.stringify(this.profileData),  
            resVerificationData: JSON.stringify(this.resVerificationData)  
        })
        .then(result => {

            console.log('*** saveAccountDetails --> result ==> '+JSON.stringify(result));
            console.log('*** saveAccountDetails --> result.id ==> '+result.Id);
            console.log('*** saveAccountDetails --> accountIduser ==> '+this.accountIduser);
            createAccountAccountRelationShip({
                 accountId : result.Id,
                 relatedAccountId: this.accountIduser,
                 reciprocalRole : 'Parent/Guardian'
             })
            .then(result => {

                this.isLoading = false;
                
                this.showToast('Success', 'Student has been created successfully', 'success');
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Application Error', 'Something went wrong.', 'error');
                console.log(error);
            });
            this.conRecord ={};
            this.clearData();
            setTimeout(() => { this.backToHomePage(); }, 2000);
            
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            console.log(error);
        });
    }

    showToast(title, message, variant) {
        console.log('showToast called -> title:' + title + ' --- message : ' + message + ' --- variant : ' + variant);
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    clearData(){
        this.template.querySelector('c-contact-info-component').clearData();
        this.template.querySelector('c-address-component').clearData();     
        this.template.querySelector('c-profile-image-component').clearData();   
    }

    //captures the retrieve event propagated from lookup component
    selectItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
       // this.displayItem(args);        
    }

    //captures the remove event propagated from lookup component
    deleteItemEventHandler(event){
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


    handleContactGeneralInfo(event){
        this.conRecord = event.detail.conRecord;
    }

    handleResidencyDocument(event){

        this.resVerificationData.verificationType = event.detail.resVerificationType;
        this.resVerificationData.file= event.detail.docFile;
        this.resVerificationData.fileName= event.detail.docFileName;
        this.resVerificationData.docType= event.detail.docType;

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

    handleProfileImage(event){

        this.profileData.file = event.detail.profileImageData;
        this.profileData.fileName= event.detail.profileFileName;
        this.profileData.description= 'Profile_Logo';
    }

    
    handleFavSubjectChange(event){
        this.studentInterest.Favorite_Subject__c = event.target.value;     

    }

    handleGoalsChange(event){
        this.studentInterest.Goals__c = event.target.value;

        
    }

    handleOrganizationChange(event){
        this.studentInterest.Organization__c = event.target.value;

    }
    
    handleHobby1Change(event){
        this.hobbyList = this.hobbyList.filter(item => item.value  != 'hobby1');
        const option = {
            label: event.target.value,
            value: 'hobby1',
        };
        this.hobbyList = [ ...this.hobbyList, option ];

    }
    handleHobby2Change(event){
        this.hobbyList = this.hobbyList.filter(item => item.value  != 'hobby2');
        const option = {
            label: event.target.value,
            value: 'hobby2',
        };
        this.hobbyList = [ ...this.hobbyList, option ];

    }
    handleHobby3Change(event){
        this.hobbyList = this.hobbyList.filter(item => item.value  != 'hobby3');
        const option = {
            label: event.target.value,
            value: 'hobby3',
        };
        this.hobbyList = [ ...this.hobbyList, option ];

        this.studentInterest.Interests__c = JSON.stringify(this.hobbyList);

    }

    backToHomePage(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

    isValid(){
        var val = true;
        if(!this.template.querySelector('c-contact-info-component').validate()) {
            val = false;
        }
        return val;
    }
}