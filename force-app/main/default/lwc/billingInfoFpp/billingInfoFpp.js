import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {  ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import FINANCIAL_ACCOUNT from '@salesforce/schema/FinServ__FinancialAccount__c';
import FINANCIAL_ACCOUNT_TYPE from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c';
import FINANCIAL_ACCOUNT_NAME from '@salesforce/schema/FinServ__FinancialAccount__c.Name';
import FINANCIAL_ACCOUNT_RECORD_TYPE_ID from '@salesforce/schema/FinServ__FinancialAccount__c.RecordTypeId';
import FINANCIAL_ACCOUNT_NUMBER from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c';
import FINANCIAL_BANK_ACCOUNT_NUMBER from '@salesforce/schema/FinServ__FinancialAccount__c.Bank_Account_Number__c';
import FINANCIAL_ROUTING_NUMBER from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__RoutingNumber__c';
import FINANCIAL_ACCOUNT_PRIMARY_OWNER from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c';
import FINANCIAL_ACCOUNT_OWNER from '@salesforce/schema/FinServ__FinancialAccount__c.OwnerId';
import FINANCIAL_ACCOUNT_STATUS from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__Status__c';

import CONTRACT_BENEFICIARY_ACCOUNT_ID from '@salesforce/schema/Contract.Beneficiary_Account__c';
import CONTRACT_ID from '@salesforce/schema/Contract.Id';
import ENROLLMENT_STATUS_C from '@salesforce/schema/Contract.Enrollment_Status__c';
import SP_BILLING_OPTION from  '@salesforce/schema/Contract.SP_Billing_Option__c';
import CONTRACT_FINANCIAL_ACCOUNT from  '@salesforce/schema/Contract.Financial_Account__c';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';


import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';

const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID];


export default class BillingInfoFpp extends NavigationMixin(LightningElement) {
    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imagePathIconHelp = My_Resource + '/img/icon-help.png'; 
    imageFpo90 =  My_Resource + '/img/img-fpo-alt-90px.png';
    imagesymgray= My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';

    @api contractId;
    @api planBeneficiaryName;

    userId = Id;
    userName;
    email;
    accountIduser;
    userContactId;

    accountId;
    accountType;
    selectedRecordTypeId;
    savingsPlanBillingOption;
    showACH = false;
    paymentMode;
    savingsplanbillingvalue;

    @track finAcctRecord = FINANCIAL_ACCOUNT;
 
    planPayment = 'NEW';
   
    @wire(getRecord, {
        recordId: Id,
        fields: userFileds
    }) wireuser1({
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

    @wire(getRecordTypeId, { objectName: 'FinServ__FinancialAccount__c',  strRecordTypeName: 'BankingAccount' })
    bankingAccountRecordtypeID;
   
    get savingPlanBillingOptions() {
        window.console.log('savingPlanBillingOptions ==> ' );

        return [
            { label: 'Set Up Investment', value: 'Set Up Investment' },
            { label: 'Mail in Payment', value: 'Mail in Payment' },           
        ];
    }

    get paymentOptions() {
        return [
            { label: 'ACH', value: 'ACH' }, 
            { label: 'Check', value: 'Check' },
        ];
    }

    async saveBillingInfo() {
        console.log('saveBillingInfo..1');
        if(this.paymentMode == 'ACH'){
            if(this.finAcctRecord.Id==null){
                this.finAcctRecord.FinServ__PrimaryOwner__c = this.accountIduser;
                this.finAcctRecord.OwnerId = this.userId;
       
                const fields = {};
                fields[FINANCIAL_ACCOUNT_NAME.fieldApiName] = this.finAcctRecord.Name;
                fields[FINANCIAL_BANK_ACCOUNT_NUMBER.fieldApiName] = this.finAcctRecord.FinServ__FinancialAccountNumber__c;
                fields[FINANCIAL_ROUTING_NUMBER.fieldApiName] = this.finAcctRecord.FinServ__RoutingNumber__c;
                fields[FINANCIAL_ACCOUNT_RECORD_TYPE_ID.fieldApiName] = this.bankingAccountRecordtypeID.data;
                fields[FINANCIAL_ACCOUNT_TYPE.fieldApiName] = this.finAcctRecord.FinServ__FinancialAccountType__c;
                fields[FINANCIAL_ACCOUNT_PRIMARY_OWNER.fieldApiName] = this.accountIduser;
                fields[FINANCIAL_ACCOUNT_OWNER.fieldApiName] = this.userId;
                fields[FINANCIAL_ACCOUNT_STATUS.fieldApiName] = 'Active';
          
                const recordInput = { apiName: FINANCIAL_ACCOUNT.objectApiName, fields };
                try{
                    const createRecordResult = await createRecord(recordInput);
                    console.log('saveBillingInfo..2..'+JSON.stringify(createRecordResult));
    
                    this.finAcctRecord.Id = createRecordResult.id;
    
                }catch (error) {
                    console.log('error', error);
                }
            }
    
        }

     
        const fields = {};
        fields[CONTRACT_ID.fieldApiName] = this.contractId;
        fields[ENROLLMENT_STATUS_C.fieldApiName] = "Billing Info";
        fields[SP_BILLING_OPTION.fieldApiName] = this.savingsPlanBillingOption;
        if(this.paymentMode == 'ACH'){
            fields[CONTRACT_FINANCIAL_ACCOUNT.fieldApiName] = this.finAcctRecord.Id;
        }

         const recordInput = { fields };
         const updateRecordResult = await updateRecord(recordInput);
         this.goToNextPage();        
 
        }

        handlePaymentOptionsChange(event){
            this.showACH = false;
            this.paymentMode = event.detail.value;
            if(this.paymentMode == 'ACH'){
                this.showACH = true;
                this.savingsplanbillingvalue = 'Set Up Investment';
            }else{
                this.savingsplanbillingvalue = 'Mail in Payment';
            }
        }

        handleSavingPlanBillingChange(event){
            this.savingsPlanBillingOption = event.detail.value;
        }

        handleFinAccountInfo(event){
            this.finAcctRecord =  event.detail.finAcctRecord;
        }

        // createFinancialAccount(){
        //     window.console.log('Name ==> ' + this.finAcctRecord.Name);
        //     window.console.log('FinServ__FinancialAccountNumber__c ==> ' + this.finAcctRecord.FinServ__FinancialAccountNumber__c);
        //     window.console.log('FinServ__RoutingNumber__c ==> ' + this.finAcctRecord.FinServ__RoutingNumber__c);
        //     window.console.log('selectedRecordTypeId ==> ' + this.selectedRecordTypeId);
        //     window.console.log('this.finAcctRecord.RecordTypeId ==> ' + this.finAcctRecord.RecordTypeId);
        //     window.console.log('this.accountIduser ==> ' + this.accountIduser);
        //     window.console.log('this.userId ==> ' + this.userId);
   
        //     this.finAcctRecord.FinServ__PrimaryOwner__c = this.accountIduser;
        //     this.finAcctRecord.OwnerId = this.userId;
   
        //     const fields = {};
        //     fields[FINANCIAL_ACCOUNT_NAME.fieldApiName] = this.finAcctRecord.Name;
        //     fields[FINANCIAL_ACCOUNT_NUMBER.fieldApiName] = this.finAcctRecord.FinServ__FinancialAccountNumber__c;
        //     fields[FINANCIAL_ROUTING_NUMBER.fieldApiName] = this.finAcctRecord.FinServ__RoutingNumber__c;
        //     fields[FINANCIAL_ACCOUNT_RECORD_TYPE_ID.fieldApiName] = this.selectedRecordTypeId;
        //     fields[FINANCIAL_ACCOUNT_PRIMARY_OWNER.fieldApiName] = this.accountIduser;
        //     fields[FINANCIAL_ACCOUNT_OWNER.fieldApiName] = this.userId;
        //     fields[FINANCIAL_ACCOUNT_STATUS.fieldApiName] = 'Active';
   
   
        //     const recordInput = { apiName: FINANCIAL_ACCOUNT.objectApiName, fields };
   
        //     createRecord(recordInput)
        //     .then(account => {
        //        window.console.log('account ===> ' + JSON.stringify(account));
        //      //  this.goToNextPage();
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Success',
        //                 message: 'Billing Information updated successfully',
        //                 variant: 'success',
        //             }),
        //         );
        //     })
        //     .catch(error => {
        //        window.console.log('error---' + JSON.stringify(error.body) )
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Error creating record',
        //                 message: error.body.message,
        //                 variant: 'error',
        //             }),
        //         );
        //     });
        // }

        // updateContract(){

        //     window.console.log( 'inside updateContract ===>');    
        //     window.console.log( 'inside updateContract ===>');    
        //     window.console.log( 'this.savingsPlanBillingOption..'+ this.savingsPlanBillingOption); 
        //     const fields = {};
        //     fields[CONTRACT_ID.fieldApiName] = this.contractId;
        //     fields[ENROLLMENT_STATUS_C.fieldApiName] = "Billing Info";
        //     fields[SP_BILLING_OPTION.fieldApiName] = this.savingsPlanBillingOption;
        //     fields[CONTRACT_FINANCIAL_ACCOUNT.fieldApiName] = '';
    
        //      const recordInput = { fields };
    
        //     updateRecord(recordInput)
        //         .then(() => {
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     title: 'Success',
        //                     message: 'Profile updated successfully',
        //                     variant: 'success'
        //                 })
        //             );
    
        //         })
        //         .catch(error => {
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     title: 'Error updating record',
        //                     message: error.body.message,
        //                     variant: 'error'
        //                 })
        //             );
        //         });         
        // }
    
         goToNextPage(){
            const passEvent = new CustomEvent('next', {
                detail:{contractId:this.contractId} 
            }); 
             this.dispatchEvent(passEvent);
        }
}