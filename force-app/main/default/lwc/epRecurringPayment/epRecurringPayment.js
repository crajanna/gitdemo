import { LightningElement, wire, api } from 'lwc';
import {createRecord , getRecord} from 'lightning/uiRecordApi';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import 'c/fpCssLibrary';
import { NavigationMixin } from 'lightning/navigation';
import getCashAccountIdByAccount from '@salesforce/apex/CreateFinancialAccount.getCashAccountIdByAccount';
import getCashAccountNumberByAccountId from '@salesforce/apex/CreateFinancialAccount.getCashAccountNumberByAccountId';
const userFileds = [ACCOUNT_ID, USER_CONTACT_ID];
import saveAddFunds from '@salesforce/apex/FinancialAccountController.saveAddFunds';
import FINANCIAL_ACCOUNT from '@salesforce/schema/FinServ__FinancialAccount__c';
import saveTransferFund from '@salesforce/apex/TransferFundController.saveTransferFund';
import saveFinAccount from '@salesforce/apex/FinancialAccountController.saveFinAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TRANSFER_FUND_FREQ from '@salesforce/schema/Transfer_Fund__c.Frequency__c';

export default class EpRecurringPayment extends NavigationMixin(LightningElement) {
    @api beneficiaryAccountId;
    isLoading = false;
    userId = Id;
    accountIduser;
    userContactId;
    finAcctRecord = FINANCIAL_ACCOUNT;
    amount;

    
    @wire(getRecord, {
        recordId: Id,
        fields: userFileds
    }) wireuser1({
        error,
        data
    }) {
        if (error) {
           // 
        } else if (data) {
            //
            this.accountIduser = data.fields.AccountId.value;
            this.userContactId = data.fields.ContactId.value;

        }
    }

    @wire(getRecordTypeId, { objectName: 'Transfer_Fund__c',  strRecordTypeName: 'Contribution' })
    transferFundRecordTypeContId;

    @wire(getPicklistValues,
        {
            recordTypeId: '$transferFundRecordTypeContId.data', 
            fieldApiName: TRANSFER_FUND_FREQ 
        }
    )
    frequencyPicklist;
}