import { LightningElement, wire, api } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import 'c/fpCssLibrary';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getCashAccountIdByAccount from '@salesforce/apex/CreateFinancialAccount.getCashAccountIdByAccount';
import getCashAccountNumberByAccountId from '@salesforce/apex/CreateFinancialAccount.getCashAccountNumberByAccountId';
const userFileds = [ACCOUNT_ID, USER_CONTACT_ID];
import saveAddFundsDetails from '@salesforce/apex/FoundationContractController.saveAddFundsDetails';
import FINANCIAL_ACCOUNT from '@salesforce/schema/FinServ__FinancialAccount__c';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';


export default class FpAddFundsPayment extends NavigationMixin(LightningElement) {
    isLoading = false;
    currentPageReference = null; 
    urlStateParameters = null;

    userId = Id;
    accountIduser;
    userContactId;

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
    dollarIcon = FoundationImages + "/img/icon-dollar-sign.svg";
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
            
        } else if (data) {
            
            this.accountIduser = data.fields.AccountId.value;
            this.userContactId = data.fields.ContactId.value;

        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }

    setParametersBasedOnUrl() {
        this.tid = this.urlStateParameters.tid || null;
        this.addfunds = this.urlStateParameters.addfunds || null;
        if(this.tid == null){
            this.showCheckoutPaypal = true;
            this.disableAmountField = false;
        }
        else{

            var splitvalues = this.tid.split('#');

            this.showCheckoutPaypal = false;
            this.disableAmountField = true;
            this.pledgeFulfillDurationValue = 'Now';
            this. pledgeFulfillModeOption = 'Paypal';
            this.showdisplay = true;
            this.showPaymentAccounts =false;

            this.vendorfee = parseFloat(splitvalues[2]);	
            this.originalamt =  parseFloat(splitvalues[1]);
            this.total =  parseFloat(this.originalamt)+parseFloat(this.vendorfee);
            this.amount = this.total.toFixed(2);
            this.vendorfee = parseFloat(this.vendorfee).toFixed(2);	

        }
    
    } 

    @wire(getCashAccountNumberByAccountId, { accountId: '$accountIduser' })
    cashAccountNumber;

    @wire(getRecordTypeId, { objectName: 'Transfer_Fund__c',  strRecordTypeName: 'Contribution' })
    transferFundRecordTypeContId;

    @wire(getCashAccountIdByAccount, { accountId: '$accountIduser' })
    cashAccountId;

    get pledgeFulfillDurationOptions() {
        return [
            { label: 'Now', value: 'Now' },           
        ];
    }

    get pledgeFulfillModeOptions() {
        return [
            { label: 'ACH', value: 'ACH', select: true},   
            { label: 'Check', value: 'Check' },
            { label: 'Paypal', value: 'Paypal' },
        ];
    }

    handlePledgeFulfillModeChange(event){
        this.showPaymentAccounts = false;
        this.pledgeFulfillModeOption = event.target.value;
        this.buttonText = 'Add Funds';
        if(this.pledgeFulfillModeOption=='Check'){
            this.showCheckAddress = true;
        } else if(this.pledgeFulfillModeOption=='ACH'){
            this.showPaymentAccounts = true;
            this.showCheckAddress = false;
        }
        else{
  
            if(this.pledgeFulfillModeOption=='Paypal'){
                this.buttonText = 'Check out with Paypal';
            }
            this.showCheckAddress = false;
        }
        if(this.disableAmountField){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'addfundspage'
                },
                state: {
                    addfunds: 'addfunds',
                }
            });
        }

    }

    handleAmountChange(event){
        
        this.amount = event.target.value;
     }

     handleAddFundsPaymentClick(event){
        
        var val = true;
        var amountCmp = this.template.querySelector(".amountCmp");
        var value = amountCmp.value; 
        if (value === "") {
            val = false;
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
            var value = fullFillCmp.value; 
            
            if (value!=null) {
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
        if(!this.template.querySelector('c-bank-accounts-component').validate()) {
            val = false;
          }
     }
     if(val){
        this.handleAddFundsPayment();
     }
       
     }

     handleAddFundsPayment(){
        this.isLoading = true;
        if(this.pledgeFulfillModeOption=='Paypal'){
            this.originalamt = parseFloat(this.amount);
            let flatFee = 0.30;
            let percentageFee = 0.978;
            var payAmount = (parseFloat(this.originalamt)+parseFloat(flatFee))/parseFloat(percentageFee);
            this.vendorfee = parseFloat(payAmount)-parseFloat(this.originalamt);
            this.amount = this.gaussRound(this.payAmount,2);
            
        }else{
            this.vendorfee = 0;
            this.originalamt = parseFloat(this.amount);
        }
        
        var status = 'Complete';
        if(this.pledgeFulfillModeOption=='Paypal'){
           status = 'Pending';
        }
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

         saveAddFundsDetails({
            tranfund: transferFundRecord,
            bankAccount: this.finAcctRecord          
        })
        .then(result => {
            // Clear the user enter values
            transferFundRecord = {};

            if(this.pledgeFulfillModeOption=='Paypal'){
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                    pageName: 'addfundspaypalpage'
                },
                 state: {
                    tid: result+'#'+this.originalamt+'#'+this.vendorfee

                }
            });
            }else{
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                    pageName: 'addfundsfinishpage'
                },
                 state: {
                    xid: result,
                }
            });
            }
            this.isLoading = false;
        })
        .catch(error => {
            ////window.
            this.isLoading = false;
        });
   }


   handleGoToDashboard(){
    this[NavigationMixin.Navigate]({
           type: 'comm__namedPage',
            attributes: {
              pageName: 'mydashboard'
        }
   });
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

}