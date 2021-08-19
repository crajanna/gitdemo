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
import ACC_ID from '@salesforce/schema/Account.Id';
import ACC_WEBSITE from '@salesforce/schema/Account.Website';
import ACC_PHONE from '@salesforce/schema/Account.Phone';
import ACC_USE_ADDRESS from '@salesforce/schema/Account.Use_Address__c';

import ACC_EMAIL from '@salesforce/schema/Account.Email__c';
import ACC_FAX from '@salesforce/schema/Account.Fax';
import ACC_BILLING_STREET from '@salesforce/schema/Account.BillingStreet';
import ACC_BILLING_CITY from '@salesforce/schema/Account.BillingCity';
import ACC_BILLING_STATE  from '@salesforce/schema/Account.BillingState';
import ACC_BILLING_COUNTRY  from '@salesforce/schema/Account.BillingCountry';
import ACC_BILLING_POSTALCODE  from '@salesforce/schema/Account.BillingPostalCode';
import ACC_BILLING_STATE_CODE  from '@salesforce/schema/Account.BillingStateCode';
import ACC_BILLING_COUNTRY_CODE  from '@salesforce/schema/Account.BillingCountryCode';
import ACC_SHIPPING_STREET from '@salesforce/schema/Account.ShippingStreet';
import ACC_SHIPPING_CITY from '@salesforce/schema/Account.ShippingCity';
import ACC_SHIPPING_STATE  from '@salesforce/schema/Account.ShippingState';
import ACC_SHIPPING_COUNTRY  from '@salesforce/schema/Account.ShippingCountry';
import ACC_SHIPPING_POSTALCODE  from '@salesforce/schema/Account.ShippingPostalCode';
import ACC_SHIPPING_STATE_CODE  from '@salesforce/schema/Account.ShippingStateCode';
import ACC_SHIPPING_COUNTRY_CODE  from '@salesforce/schema/Account.ShippingCountryCode';
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
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import getStateOptions from '@salesforce/apex/CreatePersonAccount.getStateOptionsList';
import getCountryOptions from '@salesforce/apex/CreatePersonAccount.getCountryOptionsList';


const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID];
const contactFields = [CON_FIRST_NAME, CON_MID_NAME, CON_LAST_NAME,
    CON_MAILING_STREET,CON_MAILING_CITY, CON_MAILING_STATE, CON_MAILING_COUNTRY, CON_MAILING_POSTALCODE, CON_MAILING_STATE_CODE, CON_MAILING_COUNTRY_CODE];

export default class BusinessInfoDonation extends LightningElement {
    userId = Id;
    userName;
    email;
    accountIduser;
    userContactId;
    website;
    email;
    phone;
    fax;
    fieldName = 'Use_Address__c';
    objectName = 'Account';
   


    @track conRecord = CONTACT_OBJECT;
    @track accRecord = ACCOUNT_OBJECT;
    @track countryValues = []; 
    @track stateValues = [];
    @track userAddress = [];
    @track userAddressOption;
    @track fieldLabelName;
    

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountInfo;
    @wire(getPicklistValues,
        {
            recordTypeId: '0124W000001bAJVQA2', 
            fieldApiName: ACC_USE_ADDRESS
        }
    )
    useAddressValues;

    /**
     * Fetching User Object properties
     *  
     */
    @wire(getRecord, { recordId: Id, fields: userFileds }) 
    wireuser({ error, data }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            console.log( JSON.stringify( data.fields ) );
            this.userName = data.fields.Name.value;
             this.accountIduser = data.fields.AccountId.value;
            //this.accountIduser = '001P000001nnAlzIAE';            
            this.email = data.fields.Email.value;
            this.userContactId = data.fields.ContactId.value;
          }
    }

    /**
     * Fetching Contact Object properties
     *  
     */    
    @wire(getRecord, { recordId:'$userContactId', fields: contactFields }) 
    wireContact({ error, data }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            console.log( JSON.stringify( data.fields ) );
            this.conRecord.FirstName = data.fields.FirstName.value;
            this.conRecord.LastName = data.fields.LastName.value;
            this.conRecord.MiddleName = data.fields.MiddleName.value;            
        }
    }
   
    /**
     * Fetching State Options from Apex (CreatePersonAccount.getStateOptionsList)
     *  
     */
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

    /**
     * Fetching State Options from Apex (CreatePersonAccount.getCountryOptionsList)
     *  
     */
     @wire(getCountryOptions)
     mapOfCountryData({data, error}) {
          if(data) {                
              for(let key in data) {
                  // Preventing unexcepted data
                  if (data.hasOwnProperty(key)) { 
                      this.userAddress.push({"label":key, "value":data[key]});
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

    get acceptedFormats() {
        return ['.jpg', '.png'];
    }

    handleUseAddressChange(event){
        this.userAddressOption = event.target.value;       
        window.console.log('userAddressOption ==> ' + event.target.value);
    }

    handleWebsiteChange(event){
        this.website = event.target.value;       
        window.console.log('Webiste ==> ' + event.target.value);
    }
    handleEmailChange(event) {
        this.email = event.target.value;        
        window.console.log('Email ==> ' + event.target.value);
    }
    handlePhoneChange(event) {
        this.phone = event.target.value;
        window.console.log('Phone ==> ' + event.target.value);
    }
    handleFaxChange(event) {
        this.fax = event.target.value;
        window.console.log('Fax ==> ' + event.target.value);
    }
  
    /*handleAddressChange(event) {
        this.accRecord.BillingStreet = event.detail.street;
        this.accRecord.BillingCity = event.detail.city;
        this.accRecord.BillingStateCode = event.detail.province;
        this.accRecord.BillingPostalCode = event.detail.postalCode;
        this.accRecord.BillingCountryCode = "US";
        window.console.log('OtherStreet ===> '+this.accRecord.BillingStreet);
        window.console.log('OtherCity ===> '+this.accRecord.BillingCity);
        window.console.log('OtherStateCode ===> '+this.accRecord.BillingStateCode);
        window.console.log('OtherPostalCode ===> '+this.accRecord.BillingPostalCode);
        window.console.log('OtherCountryCode ===> '+this.accRecord.BillingCountryCode);
      
        this.selectedCountryLabel =this.getCountryOptions.find(opt => opt.value === event.detail.country).label;

        if(event.detail.province){
            this.selectedStateLabel = this.getProvinceOptions.find(opt => opt.value === event.detail.province).label;
        }
        
        if(this.selectedCountryLabel){
           this.accRecord.BillingCountry = this.selectedCountryLabel;
           window.console.log('OtherCountry === > '+this.accRecord.BillingCountry);
        }

        if(this.selectedStateLabel){
            this.accRecord.BillingState = this.selectedStateLabel;
            window.console.log('OtherState ===> '+this.accRecord.BillingState);
         }
    }*/

    /**
     * Fetching Shipping address details  
     */
    handleShippingAddressChange(event){
        this.accRecord.ShippingStreet = event.detail.street;
        this.accRecord.ShippingCity = event.detail.city;
        this.accRecord.ShippingStateCode = event.detail.province;
        this.accRecord.ShippingPostalCode = event.detail.postalCode;
        this.accRecord.ShippingCountryCode = "US";
        window.console.log('OtherStreet ===> '+this.accRecord.ShippingStreet);
        window.console.log('OtherCity ===> '+this.accRecord.ShippingCity);
        window.console.log('OtherStateCode ===> '+this.accRecord.ShippingStateCode);
        window.console.log('OtherPostalCode ===> '+this.accRecord.ShippingPostalCode);
        window.console.log('OtherCountryCode ===> '+this.accRecord.ShippingCountryCode);
       
        this.selectedCountryLabel =this.getCountryOptions.find(opt => opt.value === event.detail.country).label;

        if(event.detail.province){
            this.selectedStateLabel = this.getProvinceOptions.find(opt => opt.value === event.detail.province).label;
        }
        
        if(this.selectedCountryLabel){
           this.accRecord.ShippingCountry = this.selectedCountryLabel;
           window.console.log('OtherCountry ===> '+this.accRecord.ShippingCountry);
        }

        if(this.selectedStateLabel){
            this.accRecord.ShippingState = this.selectedStateLabel;
            window.console.log('OtherState ===> '+this.accRecord.ShippingState);
         }
    }

    /**
     * Updating Business Account Info
     */
    updateBusinessAccountInfo() {
        // this.accountIduser = '001P000001nnAlzIAE';
         const fields = {};
         fields[ACC_ID.fieldApiName] = this.accountIduser;
         fields[ACC_BILLING_STREET.fieldApiName]  = this.accRecord.BillingStreet;
         fields[ACC_BILLING_CITY.fieldApiName]  = this.accRecord.Billingcity;
         fields[ACC_BILLING_STATE.fieldApiName]  = this.accRecord.BillingState;
         fields[ACC_BILLING_COUNTRY.fieldApiName]  = this.accRecord.BillingCountry;
         fields[ACC_BILLING_POSTALCODE.fieldApiName]  = this.accRecord.BillingPostalCode;
         fields[ACC_BILLING_STATE_CODE.fieldApiName]  = this.accRecord.BillingStateCode;
         fields[ACC_BILLING_COUNTRY_CODE.fieldApiName]  = this.accRecord.BillingCountryCode;

         fields[ACC_SHIPPING_STREET.fieldApiName]  = this.accRecord.ShippingStreet;
         fields[ACC_SHIPPING_CITY.fieldApiName]  = this.accRecord.Shippingcity;
         fields[ACC_SHIPPING_STATE.fieldApiName]  = this.accRecord.ShippingState;
         fields[ACC_SHIPPING_COUNTRY.fieldApiName]  = this.accRecord.ShippingCountry;
         fields[ACC_SHIPPING_POSTALCODE.fieldApiName]  = this.accRecord.ShippingPostalCode;
         fields[ACC_SHIPPING_STATE_CODE.fieldApiName]  = this.accRecord.ShippingStateCode;
         fields[ACC_SHIPPING_COUNTRY_CODE.fieldApiName]  = this.accRecord.ShippingCountryCode;

         fields[ACC_WEBSITE.fieldApiName] = this.website;
         //fields[ACC_EMAIL.fieldApiName] = this.email;
         fields[ACC_PHONE.fieldApiName] = this.phone;
         fields[ACC_FAX.fieldApiName] = this.fax;
         fields[ACC_USE_ADDRESS.fieldApiName] = this.userAddressOption;


         const recordInput = { fields }; 
 
 
         updateRecord(recordInput)
             .then(() => {                
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Success',
                         message: 'Account updated successfully',
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


         
}