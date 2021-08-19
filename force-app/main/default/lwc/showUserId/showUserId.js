import { LightningElement, wire } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
const fields=['Name','AccountNumber','OwnerId','AccountSource','ParentId','AnnualRevenue','Type','CreatedById','LastModifiedById','Industry','Description','Phone'];
export default class ShowUserDetail extends LightningElement {
    userId = Id;
    userName;
    email;
    accountId;
    fields = fields;
    @wire(getRecord, {
        recordId: Id,
        fields: [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.accountId = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
        }
    }
}