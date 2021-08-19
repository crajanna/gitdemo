import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {getRecord, updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import ACCOUNT_ID_PC from '@salesforce/schema/Account.Id';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import findResourceByRecord from '@salesforce/apex/ResourceController.findResourceByRecord';

import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';

const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID]
const accountFields = [ACCOUNT_ID_PC];
export default class EnrollmentHeader extends NavigationMixin(LightningElement) {

    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imagesymgray= My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';

    @api title;
    @api contactNumber;
    @api businessHours;
    showLogo;
    profileSrcData;
    userId = Id;
    userName;
    email;
    accountIduser;
    userContactId;


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

    @wire(getRecord, {
        recordId:'$accountIduser',
        fields: accountFields
    }) wireAccount({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
             this.accountIdpc = data.fields.Id.value;
             findResourceByRecord({recordId: this.accountIdpc,                
                                  description: 'Profile_Logo'
         }).then(result => {
            console.log('profile ..'+JSON.stringify(result));   
               this.profileSrcData = result;
         }).catch(error => {
            console.log('profile upload error..'+JSON.stringify(error));   
        });

          }
    }


    handleTitleClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

}