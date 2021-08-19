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


export default class EpSetupPayment extends NavigationMixin(LightningElement) {
    
    @api beneficiaryAccountId;

    isLoading = false;
    userId = Id;
    accountIduser;
    userContactId;
    finAcctRecord = FINANCIAL_ACCOUNT;
    originalamt;
    amount;
    total;
    vendorfee;

    showCheckAddress;
    showPaymentAccounts =true;
    showNewAccountSetup;
    showCheckoutPaypal;
    disableAmountField= false; 
    achCheckboxSelected =false;
    buttonText = 'Add Funds';
    showdisplay;
    paypalAmountVal;

    finAcctRecord = FINANCIAL_ACCOUNT;

    pledgeFulfillDurationValue = 'Now';
    pledgeFulfillModeOption = 'ACH';



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


    @wire(getCashAccountNumberByAccountId, { accountId: '$accountIduser' })
    cashAccountNumber;



    @wire(getRecordTypeId, { objectName: 'Transfer_Fund__c',  strRecordTypeName: 'Contribution' })
    transferFundRecordTypeContId;

    @wire(getRecordTypeId, { objectName: 'Transfer_Fund__c',  strRecordTypeName: 'Transfer' })
    transferFundRecordTypeTransferId;

    @wire(getRecordTypeId, { objectName: 'FinServ__FinancialAccount__c',  strRecordTypeName: 'BankingAccount' })
    bankingAccountRecordTypeId;

    @wire(getCashAccountIdByAccount, { accountId: '$accountIduser' })
    cashAccountId;

    @wire(getCashAccountIdByAccount, { accountId: '$beneficiaryAccountId' })
    beneficiaryCashAccountId;
    
    get pledgeFulfillModeOptions() {
        return [
            { label: 'ACH', value: 'ACH' },   
            { label: 'Check', value: 'Check' }
        ];
    }

    handlePledgeFulfillModeChange(event){
        this.showPaymentAccounts = false;
        this.pledgeFulfillModeOption = event.detail.value;
        this.buttonText = 'Add Funds';
        if(this.pledgeFulfillModeOption=='Check'){
            this.showCheckAddress = true;
        } else if(this.pledgeFulfillModeOption=='ACH'){
            this.showPaymentAccounts = true;
            this.showCheckAddress = false;
        }
    }

    handleAmountChange(event){
        //
        this.amount = event.detail.value;
     }

     handleAddFundsPaymentClick(event){
       
        var val = true;
        var amountCmp = this.template.querySelector(".amountCmp");
        var value = amountCmp.value; //assigning value to variable
        if (value === "") {
            val = false;
            //adding custom validation
           amountCmp.setCustomValidity("Please select Payment Amount");
           amountCmp.reportValidity();
       }else{
 
        if (value.indexOf('-') !== -1)
        {
            val = false;
            amountCmp.setCustomValidity("You must enter a positive amount.");
            amountCmp.reportValidity();
        }else{
            amountCmp.setCustomValidity("");
            amountCmp.reportValidity();

            var fullFillCmp = this.template.querySelector(".fullFillCmp");
            var value = fullFillCmp.value; //assigning value to variable
            //
            if (value!=null) {
                    //adding custom validation
                    fullFillCmp.setCustomValidity("");
                    fullFillCmp.reportValidity();
                   
                }else{
                    val = false;
                    fullFillCmp.setCustomValidity("Pelase select Payment Method");
                    fullFillCmp.reportValidity();
                }  
        } 

       }
       if(this.pledgeFulfillModeOption == 'ACH' ){
        if(!this.achCheckboxSelected){
            val = false;
            var acceptachcmp = this.template.querySelector(".acceptach");
            acceptachcmp.setCustomValidity("Please authorize the Florida Prepaid College Board to initiate a one-time ACH transaction");
            acceptachcmp.reportValidity();
        }
        // if(!this.template.querySelector('c-bank-accounts-component').validate()) {
        //     val = false;
        //   }
     }
     if(val){
        this.handleAddFundsPayment();
     }
       
     }

     handleAddFundsPayment(){
        console.log('inside handleAddFundsPayment.. ');
        this.isLoading = true;
        this.vendorfee = 0;
        this.originalamt = parseFloat(this.amount);
        //
        
        var status = 'Complete';

        if(this.pledgeFulfillModeOption=='ACH'){
            status = 'Queued';
         }
         if(this.pledgeFulfillModeOption=='Check'){
            status = 'Queued';
         }



        var transferFundRecord = {
            RecordTypeId : this.transferFundRecordTypeContId.data,
            Source_Type__c:this.pledgeFulfillModeOption,
            Transfer_Amount__c: this.originalamt,
            Fee__c:this.vendorfee,
            Status__c: status,
            Frequency__c : 'One-Time',
            Contact__c : this.userContactId,
            Financial_Account_Investment__c : this.cashAccountId.data,
            Account__c : this.accountIduser
         }


        console.log('inside handleAddFundsPayment.11. '+ JSON.stringify(transferFundRecord));
         console.log('inside handleAddFundsPayment.12. '+ JSON.stringify(this.finAcctRecord  ));

         saveAddFunds({
            tranfund: transferFundRecord,
            bankAccount: this.finAcctRecord          
        })
        .then(result => {
            // Clear the user enter values
            console.log('result.. '+ result);

               // Creating mapping of fields of Account with values
                    const fields = {
                                    RecordTypeId : this.transferFundRecordTypeTransferId.data,
                                    Source_Type__c:'Cash Account',
                                    Transfer_Amount__c: this.originalamt,
                                    Fee__c:this.vendorfee,
                                    Status__c: status,
                                    Frequency__c : 'One-Time',
                                    Financial_Account_Cash__c:this.cashAccountId.data,
                                    Financial_Account_Investment__c : this.beneficiaryCashAccountId.data,
                        };

               console.log('transfer fund fields...'+ JSON.stringify(fields));

                // Record details to pass to create method with api name of Object.
                var objRecordInput = {'apiName' : 'Transfer_Fund__c', fields};

                    // LDS method to create record.
                    createRecord(objRecordInput).then(response => {
                        alert('Transfer_Fund__c created with Id: ' +response.id);
                    }).catch(error => {
                        alert('Error: ' +JSON.stringify(error));
                    });

            transferFundRecord = {};

            this.isLoading = false;
            this.handleManageAccount();
        })
        .catch(error => {
            ////window.
            this.isLoading = false;
        });
   }


   async handleSetupPayment() {
    try {

        this.isLoading = true;
        this.vendorfee = 0;
        this.originalamt = parseFloat(this.amount);
       
        var status = 'Complete';

        if(this.pledgeFulfillModeOption=='ACH'){
            status = 'Queued';
         }
         if(this.pledgeFulfillModeOption=='Check'){
            status = 'Queued';
         }


         var transferFundRecord = {
            RecordTypeId : this.transferFundRecordTypeContId.data,
            Source_Type__c:this.pledgeFulfillModeOption,
            Transfer_Amount__c: this.originalamt,
            Fee__c:this.vendorfee,
            Status__c: status,
            Frequency__c : 'One-Time',
            Contact__c : this.userContactId,
            Financial_Account_Investment__c : this.cashAccountId.data
         }

         if(this.pledgeFulfillModeOption=='ACH'){
             if(this.finAcctRecord.Id==null){
                const bankaccountDetails = {
                    Name : this.finAcctRecord.Name,
                    Bank_Account_Number__c:this.finAcctRecord.FinServ__FinancialAccountNumber__c,
                    FinServ__RoutingNumber__c: this.finAcctRecord.FinServ__RoutingNumber__c,
                    FinServ__FinancialAccountType__c:this.finAcctRecord.FinServ__FinancialAccountType__c,
                    RecordTypeId: this.bankingAccountRecordTypeId.data,
                    FinServ__PrimaryOwner__c : this.accountIduser,
                    OwnerId : this.userId,
                    FinServ__Status__c : 'Active'
                 }        
                const result1 = await saveFinAccount({
                    obj: bankaccountDetails
                  });
                  console.log('bankaccountid..'+JSON.stringify(result1));
               transferFundRecord.Financial_Account_Cash__c = result1.Id;  
             }else{
                transferFundRecord.Financial_Account_Cash__c = this.finAcctRecord.Id; 
             }               
         }
         
         const result2 =  await saveTransferFund({
                obj: transferFundRecord
         });
       
         if(this.beneficiaryAccountId !=null){
            const bTransferFundObj = {
                RecordTypeId : this.transferFundRecordTypeTransferId.data,
                Source_Type__c:'Cash Account',
                Transfer_Amount__c: this.originalamt,
                Fee__c:this.vendorfee,
                Status__c: status,
                Frequency__c : 'One-Time',
                Financial_Account_Cash__c:this.cashAccountId.data,
                Financial_Account_Investment__c : this.beneficiaryCashAccountId.data,
               };

            const result3 = await saveTransferFund({
                    obj: bTransferFundObj
                });
            }        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Setup payment was successful',
                    variant: 'success'
                })
            );
        this.isLoading = false;
    } catch(error) {
        console.log(error);
    } finally {
        this.isLoading = false;
        this.handleManageAccount();
        console.log('Finally Block');
    }
}




 gaussRound(num, decimalPlaces) {
    var d = decimalPlaces || 0,
    m = Math.pow(10, d),
    n = +(d ? num * m : num).toFixed(8),
    i = Math.floor(n), f = n - i,
    e = 1e-8,
    r = (f > 0.5 - e && f < 0.5 + e) ?
		((i % 2 == 0) ? i : i + 1) : Math.round(n);
    return d ? r / m : r;
}

handleFinAccountInfo(event){
    this.finAcctRecord =  event.detail.finAcctRecord;
}

handleACHCheckboxSelection(event){
    this.achCheckboxSelected = event.target.checked;
}


handleManageAccount(event){
    this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            pageName: 'manageaccount'
        }
    });
}

}