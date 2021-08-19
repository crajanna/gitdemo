import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import {createRecord, getRecord} from 'lightning/uiRecordApi';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';
import getBeneficiaryList from '@salesforce/apex/FinancialAccountController.getBeneficiaryList';
import saveTransferFund from '@salesforce/apex/TransferFundController.saveTransferFund';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCashAccountIdByFinAccountId from '@salesforce/apex/FinancialAccountController.getCashAccountIdByFinAccountId';


export default class EpTransferFunds extends NavigationMixin(LightningElement) {
    
    beneficiaryList = [];
    @track fromAccount = [];
    @track toAccount = [];

    selected529SavingsPlanFromAccount;
    selected529SavingsPlanToAccount;

    amount;
    isLoading =false;

    userAccountId;
    mapCashBalance;
    fullAmount;
    availableFunds=0;

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

    @wire(getRecordTypeId, { objectName: 'Transfer_Fund__c',  strRecordTypeName: 'Transfer' })
    transferFundRecordTypeTransferId;

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
                this.toAccount = [ ...this.toAccount, option ];
            }
        }
          console.log('this.beneficiaryList..'+JSON.stringify(this.beneficiaryList));

        }
    }



 handleCancel(event){

 }


 handleFromAccountTypeChange(event){
    console.log('handleFromAccountTypeChange...'+event.detail.value);
    this.selected529SavingsPlanFromAccount = event.detail.value;
    this.availableFunds = this.mapCashBalance.get(this.selected529SavingsPlanFromAccount);

    console.log('JSON.stringify(this.toAccount)...'+JSON.stringify(this.toAccount));
    this.toAccount = [...this.fromAccount];
    this.toAccount = this.toAccount.filter(item => item.value !== event.detail.value);
    console.log('JSON.stringify(this.toAccount)...'+JSON.stringify(this.toAccount));

 }

 handleToAccountTypeChange(event){
    this.selected529SavingsPlanToAccount = event.detail.value;
 }
 
 async handleTransferFunds(event){

    try{
        this.isLoading = true;


        const cashAccountIdTo = await getCashAccountIdByFinAccountId({ finAcctId: this.selected529SavingsPlanToAccount });
        console.log('cashAccountIdTo ', cashAccountIdTo);
        const transferFundRecord = {
                                        RecordTypeId : this.transferFundRecordTypeTransferId.data,
                                        Status__c: 'Queued',
                                        Frequency__c : 'One-Time',
                                        Financial_Account_Cash__c : this.selected529SavingsPlanFromAccount,
                                        Financial_Account_Investment__c : cashAccountIdTo,            
                                        Transfer_Amount__c : this.amount,
                                   }
  
        const result3 = await saveTransferFund({ obj: transferFundRecord }); 


        const transferFundRecord1 = {
                                        RecordTypeId : this.transferFundRecordTypeTransferId.data,
                                        Status__c: 'Queued',
                                        Frequency__c : 'One-Time',
                                        Financial_Account_Cash__c : cashAccountIdTo,
                                        Financial_Account_Investment__c : this.selected529SavingsPlanToAccount,            
                                        Transfer_Amount__c : this.amount,
                                    }

        const result4 = await saveTransferFund({
                                                    obj: transferFundRecord1
                                                }); 


         this.isLoading = false;
         const evt1 = new ShowToastEvent({
            title: 'Transfer fund request was successful',
            message: 'success',
            variant: 'success'
        });
        this.dispatchEvent(evt1);

    }catch(error){

    }finally{

    }


 }


 handleAmountChange(event){
     this.amount = event.detail.value;
 }


}