import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import RACE from '@salesforce/schema/Contact.Race__c';
import GENDER from '@salesforce/schema/Contact.FinServ__Gender__c';
import SUFFIX from '@salesforce/schema/Contact.Suffix__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

export default class UtilBeneficiaryGeneralInfo extends LightningElement {
    @api conRecord;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

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

    handleChange(event){
        var elementName = event.target.name;
        var elementValue = event.target.value;

        const userInput = new CustomEvent('generalinput', {detail: {name: elementName, value: elementValue}});
        this.dispatchEvent(userInput);

    }
}