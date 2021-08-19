import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {getRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import {  ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import CON_ID from '@salesforce/schema/Contact.Id';
import CON_FIRST_NAME from '@salesforce/schema/Contact.FirstName';
import CON_LAST_NAME from '@salesforce/schema/Contact.LastName';
import CON_MID_NAME from '@salesforce/schema/Contact.MiddleName';
import CON_MAILING_STREET from '@salesforce/schema/Contact.MailingStreet';
import CON_MAILING_CITY from '@salesforce/schema/Contact.MailingCity';
import CON_MAILING_STATE  from '@salesforce/schema/Contact.MailingState';
import CON_MAILING_COUNTRY  from '@salesforce/schema/Contact.MailingCountry';
import CON_MAILING_POSTALCODE  from '@salesforce/schema/Contact.MailingPostalCode';
import CON_MAILING_STATE_CODE  from '@salesforce/schema/Contact.MailingStateCode';
import CON_MAILING_COUNTRY_CODE  from '@salesforce/schema/Contact.MailingCountryCode';
import CON_HOME_PHONE  from '@salesforce/schema/Contact.Phone';
//import CON_OTHER_PHONE  from '@salesforce/schema/Contact.OtherPhone';
import CON_TITLE  from '@salesforce/schema/Contact.Title';
import 'c/cssLibraryFpp';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

import getStateOptions from '@salesforce/apex/CreatePersonAccount.getStateOptionsList';
import getCountryOptions from '@salesforce/apex/CreatePersonAccount.getCountryOptionsList';

const contactFields = [CON_FIRST_NAME, CON_MID_NAME, CON_LAST_NAME,
    CON_MAILING_STREET,CON_MAILING_CITY, CON_MAILING_STATE, CON_MAILING_COUNTRY, CON_MAILING_POSTALCODE, CON_MAILING_STATE_CODE, CON_MAILING_COUNTRY_CODE];

const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID];

export default class ContactInfoDonation extends NavigationMixin(LightningElement) {
    userId = Id;
    userName;
    email;
    accountIduser;
    userContactId;

    @track conRecord = CONTACT_OBJECT;
    @track countryValues = []; 
    @track stateValues = [];

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
        recordId:'$userContactId',
        fields: contactFields
    }) wireContact({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            console.log( JSON.stringify( data.fields ) );
            this.conRecord.FirstName = data.fields.FirstName.value;
             this.conRecord.LastName = data.fields.LastName.value;
             this.conRecord.MiddleName = data.fields.MiddleName.value;            
          }
    }
    

    @wire(getStateOptions)
    mapOfStateData({data, error}) {
         if(data) {           
             for(let key in data) {                
                 // Preventing unexcepted data
                  if (data.hasOwnProperty(key)) { 
                      this.stateValues.push({"label":key, "value":data[key]});
                  }
             }
         }
         else if(error) {
             window.console.log(error);
         }
     }

     @wire(getCountryOptions)
     mapOfCountryData({data, error}) {
          if(data) {                
              for(let key in data) {
                  // Preventing unexcepted data
                  if (data.hasOwnProperty(key)) { 
                      this.countryValues.push({"label":key, "value":data[key]});
                  }
              }
            
          }
          else if(error) {
              window.console.log(error);
          }
      }

    get getProvinceOptions() {
        return this.stateValues = [...this.stateValues];
    }
    get getCountryOptions() {
        return this.countryValues = [...this.countryValues];
    }

    get titleOptions() {
        return [
            { label: 'Mr', value: 'Mr' },
            { label: 'Mrs', value: 'Mrs' },  
            { label: 'Miss', value: 'Miss' },   
            { label: 'Ms', value: 'Ms' },           
        ];
    }

    handleTitleChange(event){
        this.conRecord.Title = event.target.value;
        window.console.log('Title Name ==> ' + this.conRecord.Title);
    }
    handleFirstNameChange(event) {
        this.conRecord.FirstName = event.target.value;
        window.console.log('First Name ==> ' + this.conRecord.FirstName);
    }
    handleLastNameChange(event) {
        this.conRecord.LastName = event.target.value;
        window.console.log('Last Name ==> ' + this.conRecord.LastName);
    }
    handleMiddleNameChange(event) {
        this.conRecord.MiddleName = event.target.value;
        window.console.log('Middle Name ==> ' + this.conRecord.MiddleName);
    }

    handlePrimaryPhoneChange(event){
        this.conRecord.Phone = event.target.value;
        window.console.log('HomePhone  ==> ' + this.conRecord.Phone);
    }

      
    handleAddressChange(event) {
        this.conRecord.MailingStreet = event.detail.street;
        this.conRecord.MailingCity = event.detail.city;
        this.conRecord.MailingStateCode = event.detail.province;
        this.conRecord.MailingPostalCode = event.detail.postalCode;
        this.conRecord.MailingCountryCode = event.detail.country;
        window.console.log('OtherStreet ===> '+this.conRecord.MailingStreet);
        window.console.log('OtherCity ===> '+this.conRecord.MailingCity);
        window.console.log('OtherStateCode ===> '+this.conRecord.MailingStateCode);
        window.console.log('OtherPostalCode ===> '+this.conRecord.MailingPostalCode);
        window.console.log('OtherCountryCode ===> '+this.conRecord.MailingCountryCode);
       
        this.selectedCountryLabel =this.getCountryOptions.find(opt => opt.value === event.detail.country).label;

        if(event.detail.province){
            this.selectedStateLabel = this.getProvinceOptions.find(opt => opt.value === event.detail.province).label;
        }
        
        if(this.selectedCountryLabel){
           this.conRecord.MailingCountry = this.selectedCountryLabel;
           window.console.log('OtherCountry ===> '+this.conRecord.MailingCountry);
        }

        if(this.selectedStateLabel){
            this.conRecord.MailingState = this.selectedStateLabel;
            window.console.log('OtherState ===> '+this.conRecord.MailingState);
         }
    }

    updateProfileInfo() {
 
         const fields = {};
         fields[CON_ID.fieldApiName] = this.userContactId;
         fields[CON_FIRST_NAME.fieldApiName] = this.conRecord.FirstName;
         fields[CON_MID_NAME.fieldApiName] = this.conRecord.MiddleName;
         fields[CON_LAST_NAME.fieldApiName] = this.conRecord.LastName;   
         fields[CON_HOME_PHONE.fieldApiName]  = this.conRecord.Phone;
         fields[CON_MAILING_STREET.fieldApiName]  = this.conRecord.MailingStreet;
         fields[CON_MAILING_CITY.fieldApiName]  = this.conRecord.Mailingcity;
         fields[CON_MAILING_STATE.fieldApiName]  = this.conRecord.MailingState;
         fields[CON_MAILING_COUNTRY.fieldApiName]  = this.conRecord.MailingCountry;
         fields[CON_MAILING_POSTALCODE.fieldApiName]  = this.conRecord.MailingPostalCode;
         fields[CON_MAILING_STATE_CODE.fieldApiName]  = this.conRecord.MailingStateCode;
         fields[CON_MAILING_COUNTRY_CODE.fieldApiName]  = this.conRecord.MailingCountryCode;
         fields[CON_TITLE.fieldApiName] = this.conRecord.Title;
 
         const recordInput = { fields };
 
 
         updateRecord(recordInput)
             .then(() => {      
                this.goToDashboardPage();          
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Success',
                         message: 'Contact updated successfully',
                         variant: 'success'
                     })
                 );
             })
             .catch(error => {
                window.console.log(JSON.stringify(error));
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Error updating record',
                         message: error.body.message,
                         variant: 'error'
                     })
                 );
             });
 
         }

         goToDashboardPage(){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'dashboard'
                }
            });
        
        }  

}