import { LightningElement, wire, track, api } from 'lwc';
import getScholarshipApplicationReview from '@salesforce/apex/ScholarshipController.getScholarshipApplicationReview';
import getSPChoosePrograms from '@salesforce/apex/ScholarshipController.getSPChoosePrograms';
import userId from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import My_Resource from '@salesforce/resourceUrl/FoundationImages';
import 'c/spCssLibraryNew';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';


import ACC_NAME from '@salesforce/schema/Account.Name';
import ACC_WEBSITE from '@salesforce/schema/Account.Website';
import ACC_PHONE from '@salesforce/schema/Account.Phone';
import ACC_EMAIL from '@salesforce/schema/Account.Email__c';

import ACC_BILLING_STREET from '@salesforce/schema/Account.BillingStreet';
import ACC_BILLING_CITY from '@salesforce/schema/Account.BillingCity';
import ACC_BILLING_STATE from '@salesforce/schema/Account.BillingState';
import ACC_BILLING_COUNTRY from '@salesforce/schema/Account.BillingCountry';
import ACC_BILLING_POSTALCODE from '@salesforce/schema/Account.BillingPostalCode';
import ACC_BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';
import ACC_BILLING_COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';

import ACC_SHIPPING_STREET from '@salesforce/schema/Account.ShippingStreet';
import ACC_SHIPPING_CITY from '@salesforce/schema/Account.ShippingCity';
import ACC_SHIPPING_STATE from '@salesforce/schema/Account.ShippingState';
import ACC_SHIPPING_COUNTRY from '@salesforce/schema/Account.ShippingCountry';
import ACC_SHIPPING_POSTALCODE from '@salesforce/schema/Account.ShippingPostalCode';
import ACC_SHIPPING_STATE_CODE from '@salesforce/schema/Account.ShippingStateCode';
import ACC_SHIPPING_COUNTRY_CODE from '@salesforce/schema/Account.ShippingCountryCode';

import getAccountRelationShipDetails from '@salesforce/apex/AccountController.getAccountRelationShipDetails';
import findUserProfilePic from '@salesforce/apex/ScholarshipController.findUserProfilePic';

const userFileds = [NAME_FIELD, ACCOUNT_ID];
const accountFileds = [ACC_NAME, ACC_WEBSITE, ACC_PHONE, ACC_EMAIL,
    ACC_BILLING_STREET, ACC_BILLING_CITY, ACC_BILLING_STATE, ACC_BILLING_COUNTRY, ACC_BILLING_POSTALCODE, ACC_BILLING_STATE_CODE, ACC_BILLING_COUNTRY_CODE];

export default class SpCustomMetaDataPOC extends NavigationMixin(LightningElement) {

    pledgeIcon = My_Resource + "/img/icon-pledges.svg";
    plusIcon = My_Resource + "/img/icon-plus.svg";
    taskIcon = My_Resource + "/img/icon-tasks.svg";
    statusReviewIcon = My_Resource + "/img/icon-applications.svg";
    scholarshipIcon = My_Resource + "/img/icon-scholarship.svg";
    scholarshipBooksIcon = My_Resource + "/img/bg-cta-books-sp.jpg";

    addressIcon = My_Resource + "/img/icon-address-sp.svg";
    phoneIcon = My_Resource + "/img/icon-phone-sp.svg";
    emailIcon = My_Resource + "/img/icon-email-sp.svg";
    editIcon = My_Resource + "/img/icon-edit-sp.svg";

    userId = Id;
    userName;
    email;
    accountId;

    accountIduser;
    accountData = {};


    userContactId;
    hasRendered = true;
    accRelationshipList = [];

    accName;
    accPhone;
    accEmail;
    accBillingStreet;
    accBillingCity;
    accBillingState;
    accBillingPostalCode;
    accBillingCountry;
    accBillingStateCode;
    accBillingCountryCode;

    @wire(getRecord, { recordId: Id, fields: userFileds }) wireuser1({ error, data }) {
        if (error) {
            this.error = error;
            console.log('getrecord error:' + JSON.stringify(this.error));

        } else if (data) {
            //console.log('getrecord data:' + JSON.stringify(data.fields));
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;
            console.log('wire - >  this.accountIduser ==> ' + this.accountIduser);
        }
    }

    @wire(getRecord, { recordId: '$accountIduser', fields: accountFileds }) wireContact({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log('wire -> getReocrd -> this.accountIduser -> ' + this.accountIduser);
            //console.log(JSON.stringify(data.fields));
            this.accName = data.fields.Name.value;
            this.accWebsite = data.fields.Website.value;
            this.accPhone = data.fields.Phone.value;
            this.accEmail = data.fields.Email__c.value;
            this.accBillingStreet = data.fields.BillingStreet.value;
            this.accBillingCity = data.fields.BillingCity.value;
            this.accBillingState = data.fields.BillingState.value;
            this.accBillingPostalCode = data.fields.BillingPostalCode.value;
            this.accBillingCountry = data.fields.BillingCountry.value;
            this.accBillingStateCode = data.fields.BillingStateCode.value;
            this.accBillingCountryCode = data.fields.BillingCountryCode.value;
            // console.log('this.accBillingStreet -> '+this.accBillingStreet+' --- this.accBillingCity --> '+this.accBillingCity+' --- this.accBillingState -->'+this.accBillingState
            // +' --- this.accBillingPostalCode --> '+this.accBillingPostalCode+' ---  this.accBillingCountry --> '+this.accBillingCountry+' --- this.accBillingStateCode -->'+this.accBillingStateCode
            // +' --- this.accBillingCountryCode --> '+this.accBillingCountryCode);

        }
    }

    //APPLICATION STATUS REVIEW
    ownerId = userId;
    @wire(getScholarshipApplicationReview, { userId: '$ownerId' }) reviews;

    // APPLY FOR A SCHOLARSHIP
    scholarshipPrograms;
    applyBy = 'Apply By ';
    @wire(getSPChoosePrograms) scholarshipPrograms;

    @wire(getRecord, {
        recordId: Id,
        fields: [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.accountId = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
        }
    }


    gotoScholarshipPage(event) {
        let selectProgramId = event.target.dataset.targetId;
        console.log('selectProgramId => ' + selectProgramId);

        let selectProgramName = event.target.dataset.targetName;
        console.log('selectProgramName => ' + selectProgramName);

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'studentschoralshipwizard'
            },
            state: {
                selectProgramId: selectProgramId
            }
        });
    }


    gotoLearnMorePage(event) {
        // let te = event.target.href;
        // console.log('te ==> '+te);
        let learnMore = event.target.dataset.targetId;
        console.log('learnMore => ' + learnMore);

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: learnMore
            }
        });
    }


    handleProfileUpdate(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'myprofileinfo'
            }
        });
    }

    handleNewAccount(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'add-scholarship-account'
            }
        });
    }
    profilePic;
    connectedCallback() {
        console.log('this.userId => ' + this.userId);
        console.log('this.ownerId => ' + this.ownerId);




        findUserProfilePic({ userId: this.userId })
            .then(result => {
                console.log('Profile pic url =>' + JSON.stringify(result));
                this.profilePic = result;
                console.log('this.profilePic URL => ' + this.profilePic);
            })
            .catch(error => {
                console.log('Profile pic error =>' + JSON.stringify(error));

            });

        if (this.hasRendered) {
            getAccountRelationShipDetails({
                relatedAccountId: this.accountIduser,
                reciprocalRole: 'Parent/Guardian'
            })
                .then(result => {
                    //console.log('connectedCallback - test..9' + JSON.parse(JSON.stringify(result)));
                    this.accRelationshipList = JSON.parse(JSON.stringify(result));
                    //console.log('connectedCallback - test..999' + JSON.stringify(this.accRelationshipList));

                })
                .catch(error => {
                    console.log(error);
                });
            this.hasRendered = false;
        }
    }

    handleTest(){
        console.log('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    }


    @api refreshData() {
        getAccountId()
            .then(data => {
                this.accountIduser = data;
                getAccountRelationShipDetails({
                    relatedAccountId: this.accountIduser,
                    reciprocalRole: 'Parent/Guardian'
                })
                    .then(result => {
                        console.log('refreshData - test..refresh9' + JSON.parse(JSON.stringify(result)));
                        this.accRelationshipList = JSON.parse(JSON.stringify(result));
                        console.log('refreshData - test..refresh999' + JSON.stringify(this.accRelationshipList));

                    })
                    .catch(error => {
                        console.log(error);
                    });

            }).catch(error => {
                //console.log('..'+error);
            });
    }




}