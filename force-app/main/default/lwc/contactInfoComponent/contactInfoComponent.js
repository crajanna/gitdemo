import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import RACE from '@salesforce/schema/Contact.Race__c';
import GENDER from '@salesforce/schema/Contact.FinServ__Gender__c';
import SUFFIX from '@salesforce/schema/Contact.Suffix__c';
import 'c/cssLibraryFpp';
import getAccountInfo from '@salesforce/apex/AccountController.getAccountInfo';


export default class ContactInfoComponent extends LightningElement {

    randomNumber;

    connectedCallback(){
        this.randomNumber = Math.random();
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

    @track conRecord = CONTACT_OBJECT;


    @wire(getPicklistValues,
        {
            recordTypeId: '$contactInfo.data.defaultRecordTypeId', 
            fieldApiName: RACE
        }
    )
    raceListValues;
   
    @wire(getPicklistValues,
        {
            recordTypeId: '$contactInfo.data.defaultRecordTypeId', 
            fieldApiName: GENDER
        }
    )
    genderListValues;

    @wire(getPicklistValues,
        {
            recordTypeId: '$contactInfo.data.defaultRecordTypeId', 
            fieldApiName: SUFFIX
        }
    )
    suffixListValues;


    handleFirstNameChange(event) {
        this.conRecord.FirstName = event.target.value;
        this.sendContactGeneralData();
    }

    handleLastNameChange(event) {
        this.conRecord.LastName = event.target.value;
        this.sendContactGeneralData();
    }

    handleMiddleNameChange(event) {
        this.conRecord.MiddleName = event.target.value;
        this.sendContactGeneralData();
    }

    handleSsnChange(event) {
        this.conRecord.SSN2__c = event.target.value;
        this.sendContactGeneralData();
    }

    handleSuffixChange(event) {
        this.conRecord.Suffix = event.detail.value;
        this.sendContactGeneralData();
    }

    handleRaceChange(event) {
        this.conRecord.Race__c = event.detail.value;
        this.sendContactGeneralData();
    }
    handleGenderChange(event) {
        this.conRecord.FinServ__Gender__c = event.detail.value;
        this.sendContactGeneralData();
    }

    sendContactGeneralData(){
        const passEvent = new CustomEvent('handlecontactgeneralinfo', {
            detail:{
                conRecord:this.conRecord
            } 
        });
         this.dispatchEvent(passEvent);
    }



    @api
    fetchContactInfo(selectedId) {
        getAccountInfo({'accountId': selectedId, randomNumber: this.randomNumber})
                .then(data => {
                    if (data) {
                        console.log('contactInfoComponent --> fetchContactInfo --> '+ JSON.stringify(data));
                        this.conRecord.FirstName = data.FirstName;
                        this.conRecord.LastName = data.LastName;
                        this.conRecord.MiddleName = data.MiddleName;
                        this.conRecord.SSN2__c = data.SSN2__pc;
                        this.conRecord.Suffix = data.Suffix;
                        this.conRecord.Race__c = data.Race__pc;
                        this.conRecord.FinServ__Gender__c  = data.FinServ__Gender__pc;  
                        this.conRecord.Id  = selectedId;        
                        this.sendContactGeneralData();                       
                    }
                })
                .catch(error => {
                    console.error("Error in fetching contact information" , error);
            });   
    }

    @api
    clearData() {
        this.conRecord.FirstName = '';
        this.conRecord.LastName = '';
        this.conRecord.MiddleName = '';
        this.conRecord.SSN2__c = '';
        this.conRecord.Suffix = '';
        this.conRecord.Race__c = '';
        this.conRecord.FinServ__Gender__c = ''; 
    }


    @api
    validate(){
        var val = true;
        var lastNameComp = this.template.querySelector(".lastNameComp");
        var lastNameCompVal = lastNameComp.value;
       
        lastNameComp.setCustomValidity("");
        lastNameComp.reportValidity();

        if(lastNameCompVal==null || lastNameCompVal.length === 0){
            val = false;
            lastNameComp.setCustomValidity("Enter Last Name");
            lastNameComp.reportValidity();
        }

        return val;

    }

}