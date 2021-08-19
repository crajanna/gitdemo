import { LightningElement, wire, api } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';
import getFinancialAccounts from '@salesforce/apex/CreateFinancialAccount.getFinancialAccountsById';
import FINANCIAL_ACCOUNT from '@salesforce/schema/FinServ__FinancialAccount__c';
import FINANCIAL_ACCOUNT_TYPE from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import 'c/cssLibraryFpp';

const userFileds = [ACCOUNT_ID];

export default class BankAccountsComponent extends LightningElement {

    userId = Id;
    accountIduser;

    finAcctRecord = FINANCIAL_ACCOUNT;
    planPayment = null;
    showNewAccountSetup = false;
    showAccTooltip = false;
    showRoutTooltip = false;

    planPaymentsOptions = [
        {label: "Setup Online Payments Now", value: "NEW"}
    ];

    @wire(getRecord, {
        recordId: Id,
        fields: userFileds
    }) wireuser1({
        error,
        data
    }) {
        if (error) {
           this.error = error; 
        } else if (data) {
            this.accountIduser = data.fields.AccountId.value;
          }
    }

    @wire(getRecordTypeId, { objectName: 'FinServ__FinancialAccount__c',  strRecordTypeName: 'BankingAccount' })
    bankingAccountRecordtypeID;

    @wire(getPicklistValues,
        {
            recordTypeId: '$bankingAccountRecordtypeID.data', 
            fieldApiName: FINANCIAL_ACCOUNT_TYPE 
        }
    )
    bankAccountPicklist;

    @wire(getFinancialAccounts, { accountId: '$accountIduser' })
    financialAccountList({ error, data }) {
        if (data) {
            for(const list of data){
                const option = {
                    label: list.Name+'  -****'+ list.Bank_Account_Number__c,
                    value: list.Id
                };
                this.planPaymentsOptions = [ ...this.planPaymentsOptions, option ];
            }

        } else if (error) {
            console.log('error..'+JSON.stringify(error));
        }
    }

    connectedCallback(){
        this.finAcctRecord.Name = this.finAcctRecord.Name != undefined ? this.finAcctRecord.Name : '';
        this.finAcctRecord.FinServ__RoutingNumber__c = this.finAcctRecord.FinServ__RoutingNumber__c != undefined ? this.finAcctRecord.FinServ__RoutingNumber__c : '';
        this.finAcctRecord.FinServ__FinancialAccountNumber__c = this.finAcctRecord.FinServ__FinancialAccountNumber__c != undefined ? this.finAcctRecord.FinServ__FinancialAccountNumber__c : '';
    }


    handlePlanPaymentChange(event){   
       
        this.planPayment = event.target.value;  
        
        if(this.planPayment=='NEW'){
            this.showNewAccountSetup =true;
            this.finAcctRecord.Id=null;
        }else{
            this.finAcctRecord.Id =  this.planPayment;
            this.showNewAccountSetup =false;
        }
        this.sendFinAccountData();
        
    }
    handleFinAcctNameChange(event){
        this.finAcctRecord.Name = event.target.value; 
        this.sendFinAccountData();

    }

    handleAccountTypeChange(event) {
        this.finAcctRecord.FinServ__FinancialAccountType__c = event.target.value; 
        this.sendFinAccountData();
    }   

    handleFinAcctRoutingNbrChange(event){
        this.finAcctRecord.FinServ__RoutingNumber__c = event.target.value; 
        this.sendFinAccountData();
    }

    handleFinAcctNbrChange(event){
        this.finAcctRecord.FinServ__FinancialAccountNumber__c = event.target.value; 
        this.sendFinAccountData();
    }

    sendFinAccountData(){
        const passEvent = new CustomEvent('handlefinaccountinfo', {
            detail:{
                finAcctRecord:this.finAcctRecord
            } 
        });
         this.dispatchEvent(passEvent);
    }

    @api
    validate(){
        var val = true;
        var bankaccountCmp = this.template.querySelector(".bankaccountCmp");
        var bankaccountCmpVal = bankaccountCmp.value;

        bankaccountCmp.setCustomValidity("");
        bankaccountCmp.reportValidity();

        if(this.planPayment==null){
            var val = false;
            bankaccountCmp.setCustomValidity("Select Financial Institution");
            bankaccountCmp.reportValidity();
        }
        else if(this.planPayment=='NEW'){
            var instNameCmp = this.template.querySelector(".instNameCmp");
            var instNameCmpVal = instNameCmp.value;

            var routingNumCmp = this.template.querySelector(".routingNumCmp");
            var routingNumCmpVal = routingNumCmp.value;

            var accountNumCmp = this.template.querySelector(".accountNumCmp");
            var accountNumCmpVal = accountNumCmp.value;

            var bankaccountTypeCmp = this.template.querySelector(".bankaccountTypeCmp");
            var bankaccountTypeCmpVal = bankaccountTypeCmp.value;

            
            instNameCmp.setCustomValidity("");
            instNameCmp.reportValidity();
            routingNumCmp.setCustomValidity("");
            routingNumCmp.reportValidity();
            accountNumCmp.setCustomValidity("");
            accountNumCmp.reportValidity();
            bankaccountTypeCmp.setCustomValidity("");
            bankaccountTypeCmp.reportValidity();

            if(instNameCmpVal==null || instNameCmpVal.length === 0){
                val = false;
                instNameCmp.setCustomValidity("Enter Name");
                instNameCmp.reportValidity();
            }
            if(routingNumCmpVal==null || routingNumCmpVal.length === 0){
                val = false;
                routingNumCmp.setCustomValidity("Enter Routing Number");
                routingNumCmp.reportValidity();
            }else{
                if(isNaN(routingNumCmpVal)){
                    val = false;
                    routingNumCmp.setCustomValidity("Enter only digits");
                    routingNumCmp.reportValidity();
                }
            }
            if(accountNumCmpVal==null || accountNumCmpVal.length === 0){
                val = false;
                accountNumCmp.setCustomValidity("Enter Account Number");
                accountNumCmp.reportValidity();
            }else{
                if(isNaN(accountNumCmpVal)){
                    val = false;
                    accountNumCmp.setCustomValidity("Enter only digits");
                    accountNumCmp.reportValidity();
                }
            }
            if(bankaccountTypeCmpVal==null || bankaccountTypeCmpVal.length === 0){
                val = false;
                bankaccountTypeCmp.setCustomValidity("Select Account Type");
                bankaccountTypeCmp.reportValidity();
            }
        }

        return val;

    }

    OnHelpMouseEnter(event){
        let targetId = event.target.dataset.id;
        if(targetId === 'accNum')
            this.showAccTooltip = true;
        else if(targetId === 'routNum')
            this.showRoutTooltip = true;
    }

    OnHelpMouseLeave(event){
        let targetId = event.target.dataset.id;
        if(targetId === 'accNum')
            this.showAccTooltip = false;
        else if(targetId === 'routNum')
            this.showRoutTooltip = false;
    }
}