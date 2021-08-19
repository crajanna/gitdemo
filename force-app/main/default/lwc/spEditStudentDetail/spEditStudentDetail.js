import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import saveAccountDetails from '@salesforce/apex/AccountController.saveAccountDetails';
import isAccountRelationShipExist from '@salesforce/apex/AccountController.isAccountRelationShipExist';
import getAccountId from '@salesforce/apex/AccountController.getAccountId';

import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import getAccountInfo from '@salesforce/apex/AccountController.getAccountInfo';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import 'c/spCssLibrary';


export default class SpEditStudentDetail extends NavigationMixin(LightningElement) {
    userId = Id;

    accountIduser;
    beneficiaryAccountId;
    userAccountId;
    conRecord = {};
    studentInterest = {};
    profileData = {};
    resVerificationData = {}
    isLoading = false;
    hasRendered = false;

    goals = '';
    orgList = '';
    hobby3 = '';
    hobby2 = '';
    hobby1 = '';
    hobbyList = [];
    favSubject = '';
    PersonBirthdate;
    randomNumber;


    // Declare the currentPageReference variable in order to track it
    currentPageReference;
    // Injects the page reference that describes the current page
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;

        if (this.connected) {
            // We need to have the currentPageReference, and to be connected before
            // we can use NavigationMixin
            this.generateUrls();
        } else {
            // NavigationMixin doesn't work before connectedCallback, so if we have 
            // the currentPageReference, but haven't connected yet, queue it up
            this.generateUrlOnConnected = true;
        }
    }

    connectedCallback() {
        this.connected = true;

        // If the CurrentPageReference returned before this component was connected,
        // we can use NavigationMixin to generate the URLs
        if (this.generateUrlOnConnected) {
            this.generateUrls();
        }

        this.randomNumber = Math.random();

    }



    generateUrls() {
        if (this.currentPageReference) {
            this.beneficiaryAccountId = this.currentPageReference.state.accountId;
            getAccountId({ userID: this.userId })
                .then(result => {
                    this.accountIduser = result;

                    if (this.accountIduser) {
                        isAccountRelationShipExist({ accountId: this.beneficiaryAccountId, userId: this.userId, relatedAccountId: this.accountIduser, reciprocalRole: 'Parent/Guardian' })
                            .then(result => {
                                if (!result) {
                                    this[NavigationMixin.Navigate]({
                                        type: 'comm__namedPage',
                                        attributes: {
                                            name: 'Home'
                                        }
                                    });
                                    this.showToast('Application Error', 'Unauthorized action performed.', 'error');
                                }
                            })
                            .catch(error => {
                                console.log('Error : ' + error);
                            });
                    }

                })
                .catch(error => {
                    console.log('error : ' + JSON.stringify(error));
                });

        }
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

    renderedCallback() {
        if (!this.hasRendered) {
            if (this.beneficiaryAccountId) {
                this.isLoading = true;
                this.template.querySelector('c-contact-info-component').fetchContactInfo(this.beneficiaryAccountId);
                this.template.querySelector('c-address-component').fetchAddressInfo(this.beneficiaryAccountId);
                this.template.querySelector('c-profile-image-component').fetchProfileInfo(this.beneficiaryAccountId);

                getAccountInfo({ 'accountId': this.beneficiaryAccountId, randomNumber: this.randomNumber })
                    .then(data => {
                        if (data) {

                            this.goals = data.Goals__pc;
                            this.orgList = data.Organization__pc ? data.Organization__pc : '';
                            this.favSubject = data.Favorite_Subject__pc ? data.Favorite_Subject__pc : '';
                            this.PersonBirthdate = data.PersonBirthdate ? data.PersonBirthdate : '';
                            this.conRecord.Birthdate = this.PersonBirthdate;
                            this.studentInterest.Favorite_Subject__c = this.favSubject;
                            this.studentInterest.Goals__c = this.goals;
                            this.studentInterest.Organization__c = this.orgList;

                            if (data.Interests__pc) {
                                this.hobbyList = JSON.parse(data.Interests__pc);
                                this.hobby3 = this.hobbyList.find(opt => opt.value === 'hobby3').label;
                                this.hobby2 = this.hobbyList.find(opt => opt.value === 'hobby2').label;
                                this.hobby1 = this.hobbyList.find(opt => opt.value === 'hobby1').label;
                                this.studentInterest.Interests__c = JSON.stringify(this.hobbyList);
                            }

                        }
                    })
                    .catch(error => {
                        console.error("Error in fetching contact information", error);
                    });

                this.isLoading = false;
                this.hasRendered = true;
            }
        }


    }


    handleBeneficiaryDateChange(event) {
        this.conRecord.Birthdate = event.target.value;
    }

    handleSave() {
        if (this.isValid()) {
            this.createBeneficiaryInfoWithFile();
        } else {
            window.scroll(0, 0);
        }
    }

    createBeneficiaryInfoWithFile() {
        this.isLoading = true;
        if (this.phone) {
            this.conRecord.Phone = this.phone;
        }
        saveAccountDetails({
            con: this.conRecord,
            studentInterest: JSON.stringify(this.studentInterest),
            profileData: JSON.stringify(this.profileData),
            resVerificationData: JSON.stringify(this.resVerificationData)
        })
            .then(result => {
                getRecordNotifyChange([{ recordId: this.beneficiaryAccountId }]);
                this.conRecord = {};
                this.backToHomePage();
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                console.log(error);
            });
    }



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

    backToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });

    }




    handleFavSubjectChange(event) {
        this.studentInterest.Favorite_Subject__c = event.target.value;
    }

    handleGoalsChange(event) {
        this.studentInterest.Goals__c = event.target.value;

    }

    handleOrganizationChange(event) {
        this.studentInterest.Organization__c = event.target.value;
    }

    handleHobby1Change(event) {
        this.hobbyList = this.hobbyList.filter(item => item.value != 'hobby1');
        const option = {
            label: event.target.value,
            value: 'hobby1',
        };
        this.hobbyList = [...this.hobbyList, option];
    }
    handleHobby2Change(event) {
        this.hobbyList = this.hobbyList.filter(item => item.value != 'hobby2');
        const option = {
            label: event.target.value,
            value: 'hobby2',
        };
        this.hobbyList = [...this.hobbyList, option];
    }
    handleHobby3Change(event) {
        this.hobbyList = this.hobbyList.filter(item => item.value != 'hobby3');
        const option = {
            label: event.target.value,
            value: 'hobby3',
        };
        this.hobbyList = [...this.hobbyList, option];
        this.studentInterest.Interests__c = JSON.stringify(this.hobbyList);
    }


    isValid() {
        var val = true;
        if (!this.template.querySelector('c-contact-info-component').validate()) {
            val = false;
        }
        return val;
    }


}