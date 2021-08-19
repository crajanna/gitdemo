import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import {getRecord} from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';import getFinancialAccounts from '@salesforce/apex/CreateFinancialAccount.getFinancialAccountsById';
import getBeneficiaryList from '@salesforce/apex/FinancialAccountController.getBeneficiaryList';
import TF_SOURCE_TYPE from '@salesforce/schema/Transfer_Fund__c.Source_Type__c';
import saveTransferFund from '@salesforce/apex/TransferFundController.saveTransferFund';
import getCashAccountIdByAccount from '@salesforce/apex/CreateFinancialAccount.getCashAccountIdByAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class EpWithdrawal extends NavigationMixin(LightningElement) {

    beneficiaryList = [];
    fromAccount = [];
    bankAccounts = [];
    showBankAccount = false;
    showPayee = false;
    sourceType ='';
    selectedBankAccountId;
    selected529SavingsPlan;
    amount;
    isLoading =false;

    userAccountId;
    @api beneficiaryAccountId;
    fullAmount;
    availableFunds=0;

    mapCashBalance;

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

    @wire(getRecordTypeId, { objectName: 'Transfer_Fund__c',  strRecordTypeName: 'Withdrawal' })
    transferFundRecordTypeWithdrawId;

    @wire(getCashAccountIdByAccount, { accountId: '$userAccountId' })
    cashAccountId;

    @wire(getPicklistValues,
        {
            recordTypeId: '$transferFundRecordTypeWithdrawId.data', 
            fieldApiName: TF_SOURCE_TYPE 
        }
    )
    tfSourceTypeList;

    @wire(getBeneficiaryList, {accountId: '$userAccountId' })
    getBeneficiaryList({ error, data }) {
        if (error) {
          console.log(error);
        } else if (data) {
           console.log('Savingsplan..'+JSON.stringify(data));


        if(data){
             this.mapCashBalance = new Map();
            for(const item of data){
                this.mapCashBalance.set(item.finAccountId, item.savingsamount);
                const option = {
                    value: item.finAccountId,
                    label:item.finAccountName+'-'+item.name,                   
                };
                this.fromAccount = [ ...this.fromAccount, option ];
            }
        }
          console.log('this.beneficiaryList..'+JSON.stringify(this.beneficiaryList));

        }
    }

    @wire(getFinancialAccounts, { accountId: '$userAccountId' })
    financialAccountList({ error, data }) {
        if (data) {
            for(const list of data){
                const option = {
                    label: list.Name+'  -****'+ list.Bank_Account_Number__c,
                    value: list.Id
                };
                this.bankAccounts = [ ...this.bankAccounts, option ];
            }

        } else if (error) {
            console.log('error..'+JSON.stringify(error));
        }
    }

    connectedCallback(){
        if(localStorage.getItem('cpBeneficiaryId')){
            this.beneficiaryAccountId = localStorage.getItem('cpBeneficiaryId');
        }
    }

    get fromAccountList(){
        return this.fromAccount;
    }

    get fullWithdrawal() {
        return [
            { label: 'Yes', value: 'Yes' },   
            { label: 'No', value: 'No' }
        ];
    }

   async handleWithdraw(event){
       try{
        this.isLoading = true;
        var transferFundRecord = {
            RecordTypeId : this.transferFundRecordTypeWithdrawId.data,
            Source_Type__c: this.sourceType,
            Withdrawal_Source__c: this.selected529SavingsPlan,
            Status__c: 'Queued',
            Frequency__c : 'One-Time',
            Financial_Institution__c : this.selectedBankAccountId,
            Financial_Account_Cash__c : this.cashAccountId.data,
            Transfer_Amount__c : this.amount,
            Account__c:this.userAccountId
         }
         console.log('tf...'+JSON.stringify(transferFundRecord));
         const result3 = await saveTransferFund({
            obj: transferFundRecord
        }); 
        const evt1 = new ShowToastEvent({
            title: 'Withdrawal request was successful',
            message: 'success',
            variant: 'success'
        });
        this.dispatchEvent(evt1);
        this.isLoading = false;
       }catch(error){
           console.error(error);
           this.isLoading = false;
       }finally{
        this.isLoading = false;
       }
    }

    handleCancel(event){

    }

    handlePaymentMethodChange(event){
        this.sourceType = event.detail.value;
        this.showBankAccount = false;
        this.showPayee = false;
        if(this.sourceType == 'ACH'){
            this.showBankAccount = true;
        }else if(this.sourceType == 'Check'){
            this.showPayee = true;
            this.template.querySelector('c-address-component').fetchAddressInfo(this.userAccountId);  

        }
    }

    handleFinAccountInfo(event){
        this.selectedBankAccountId =  event.detail.value;
    }

    handleAccountTypeChange(event){
        this.selected529SavingsPlan = event.detail.value;
        this.availableFunds = this.mapCashBalance.get(this.selected529SavingsPlan);

    }

    handleAmountChange(event){
        this.amount = event.detail.value;
    }

    handleFullWithDrawOption(event){
        this.fullAmount = 0;
        if(event.detail.value == 'Yes'){
            this.fullAmount = this.availableFunds;
        }
    }
}