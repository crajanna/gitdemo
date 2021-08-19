import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import { getRecord } from 'lightning/uiRecordApi';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import getAccountRelationShipDetails from '@salesforce/apex/AccountController.getAccountRelationShipDetails';
import getAccountId from '@salesforce/apex/UserController.getUserAccountId';
import 'c/spCssLibraryNew';

const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID]

export default class accountRelationshipComponent extends NavigationMixin(LightningElement) {

    userId = Id;
    userName;
    email;
    accountIduser;
    userContactId;
    accRelationshipList = [];
    hasRendered = true;
    randomNumber;
    accountStr;
    accoundId;

    studentProfilePlaceHolder = FoundationImages + "/img/icon-profile-placeholder-student.svg";

    connectedCallback() {
        this.randomNumber = Math.random();
    }

    showLogo = false;
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
            //console.log(JSON.stringify(data.fields));
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
            this.userContactId = data.fields.ContactId.value;
            
            getAccountRelationShipDetails({
                    relatedAccountId: this.accountIduser,
                    reciprocalRole: 'Parent/Guardian',
                    randomNumber: this.randomNumber
                })
                .then(result => {
                    this.accRelationshipList = JSON.parse(JSON.stringify(result));
                    console.log('this.accRelationshipList ==> '+JSON.stringify(this.accRelationshipList));
                    this.showLogo = true;

                })
                .catch(error => {
                    console.log(error);
                });
        }
    }


    @api
    refreshData() {
        getAccountId()
            .then(data => {
                this.accountIduser = data;
                getAccountRelationShipDetails({
                        relatedAccountId: this.accountIduser,
                        reciprocalRole: 'Parent/Guardian',
                        randomNumber: this.randomNumber
                    })
                    .then(result => {
                        this.accRelationshipList = JSON.parse(JSON.stringify(result));
                        this.showLogo = true;

                    })
                    .catch(error => {
                        console.log(error);
                    });

            }).catch(error => {
                //console.log('..'+error);
            });
    }

    editStudentProfile(event){
        this.accountStr = event.currentTarget.id;
        if(this.accountStr != null || this.accountStr != undefined){
            const myArr = this.accountStr.split('-');
            this.accoundId = myArr[0];
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'editbeneficiary'
            },
            state: {
                accountId: this.accoundId
            }
        });
    }

}