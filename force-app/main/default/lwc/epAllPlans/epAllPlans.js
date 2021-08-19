import { LightningElement, wire, api } from 'lwc';
import {NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import getBeneficiaryList from '@salesforce/apex/FinancialAccountController.getBeneficiaryList';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import {getRecord} from 'lightning/uiRecordApi';

const columns = [
    { label: 'NAME', fieldName: 'name',  wrapText: 'true', sortable: true, editable: false },
    { label: 'DOB', fieldName: 'dob', type: 'date', wrapText: 'true', sortable: true, editable: false, typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"
    } },   
    { label: 'OVERVIEW', fieldName: 'amount',  wrapText: 'true', sortable: true, editable: false, type: 'currency', typeAttributes: { currencyCode: 'USD'} },
    { label: 'PREPAID', fieldName: 'amount',  wrapText: 'true', sortable: true, editable: false, type: 'currency', typeAttributes: { currencyCode: 'USD'} },
    { label: 'SAVINGS', fieldName: 'savingsamount',  wrapText: 'true', sortable: true, editable: false, type: 'currency', typeAttributes: { currencyCode: 'USD'} },
    { label: 'DOCS', fieldName: 'document',  editable: false }
  
];

export default class EpAllPlans extends NavigationMixin(LightningElement) { 
    userAccountId;
    records;
    columns = columns;
    @wire(getRecord, {
        recordId: Id,
        fields: [ACCOUNT_ID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        } else if (data) {
            this.userAccountId = data.fields.AccountId.value;
        }
    }

    @wire(getBeneficiaryList, {accountId: '$userAccountId' })
    getBeneficiaryList({ error, data }) {
        if (error) {
          console.log(error);
        } else if (data) {
           this.records = data;
           console.log('allplans11..'+JSON.stringify(this.beneficiaryList));
        }
    }

    handleManageAccount(event){
        localStorage.removeItem('cpBeneficiaryId');
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'manageaccount'
            }
        });
    }

    handleAddBeneficiary(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'addnewbeneficiary'
            }
        });
    }
}