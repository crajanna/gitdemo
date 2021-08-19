import { LightningElement, wire, api } from 'lwc';
import { getRecord, createRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';
import FINANCIAL_ACCOUNT from '@salesforce/schema/FinServ__FinancialAccount__c';
import FINANCIAL_ACCOUNT_TYPE from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import 'c/fpCssLibrary';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import savePledgeDetails from '@salesforce/apex/FoundationContractController.savePledgeDetails';
import getCashAccountIdByAccount from '@salesforce/apex/CreateFinancialAccount.getCashAccountIdByAccount';
import getCashAccountNumberByAccountId from '@salesforce/apex/CreateFinancialAccount.getCashAccountNumberByAccountId';
import getProduct from '@salesforce/apex/FPPedgeController.getProduct';
import getPledgeData from '@salesforce/apex/FoundationContractController.getPledgeData';
import getContract from '@salesforce/apex/FPPedgeController.getContract';
import getScholarshipFinAccount from '@salesforce/apex/CreateFinancialAccount.getScholarshipFinAccount';
import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import TRANSFER_FUND_OBJECT from '@salesforce/schema/Transfer_Fund__c';
const userFileds = [ACCOUNT_ID, USER_CONTACT_ID];

export default class FpPledgeSpecifyPayment extends NavigationMixin(LightningElement) {
    currentPageReference = null;
    urlStateParameters = null;
    contractId = null;

    userId = Id;
    accountIduser;
    userContactId;
    isLoading = false;

    @api selectProgramId;
    @api county;
    @api zip;
    @api pledge;

    amount;
    originalamt;
    total;
    vendorfee;

    accountType;
    selectedRecordTypeId;

    finAcctRecord = FINANCIAL_ACCOUNT;

    cid = null;

    contractRecord = CONTRACT_OBJECT;
    achtransferFundRecord = TRANSFER_FUND_OBJECT;

    logoURL2 = FoundationImages + '/img/spledge1.jpeg';
    logoURL1 = FoundationImages + '/img/icon-heart.svg';
    pledgeIcon = FoundationImages + "/img/icon-pledges.svg";
    externalLinkIcon = FoundationImages + "/img/icon-link-external.svg";
    dollarIcon = FoundationImages + "/img/icon-dollar-sign.svg";

    get heartLogo() {
        return this.logoURL1;
    }

    get programLogo() {
        return this.logoURL2;
    }

    pledgeFulfillDurationOption;
    pledgeFulfillModeOption;
    showCheckAddress;
    showPaymentAccounts;
    showNewAccountSetup;
    showCheckoutPaypal;
    disableAmountField = false;
    achCheckboxSelected = false;
    hidePayment = false;
    buttonText = 'Next';
    acceptTerms;
    showdisplay;
    paypalAmountVal;
    pledgeFulfillDurationValue;

    planPaymentsOptions = [
        { label: "Setup New Financial Institution", value: "NEW" }
    ];


    //col-2 Choose program information 
    donationAmount = 0.00;
    pledgeAmout = 0.00;
    contractData;

    productImgURL;
    productName2;
    priductDescription;
    productDidYouKnow;
    productLearnMoreURL;
    productData;
    //End	
    @wire(getContract, { contractId: '$contractId' })
    getContract({ error, data }) {
        
        if (error) {
            this.error = error;
            this.donationAmount = 0.00;
            this.pledgeAmout = 0.00;
        } else if (data) {
            this.contractData = data;
            this.donationAmount = this.contractData.Donation_Amount__c;
            this.pledgeAmout = this.contractData.Pledge__c;
            if (this.donationAmount == undefined) {
                this.donationAmount = 0.00;
            }
            if (this.pledgeAmout == undefined) {
                this.pledgeAmout = 0.00;
            }
        }
    }

    @wire(getProduct, { productId: '$selectProgramId' })
    getProduct({ error, data }) {
        if (error) {
            this.error = error;

        } else if (data) {

            this.productData = data;
            this.productName = this.productData.Name;
            this.productImgURL = FoundationImages + '/img/' + this.productData.Pledge_Image__c;
            this.priductDescription = this.productData.Description;
            this.productDidYouKnow = this.productData.Did_You_Know__c;
            this.productLearnMoreURL = this.productData.Learn_More_URL__c;
        }
    }

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
        this.contractId = this.urlStateParameters.contractId || null;
        if (this.urlStateParameters.selectProgramId != null && !this.selectProgramId) {
            this.selectProgramId = this.urlStateParameters.selectProgramId || null;
        }
        this.cid = this.urlStateParameters.cid || null;
        this.hidePayment = this.urlStateParameters.hip;
        if (this.cid == null) {
            this.showCheckoutPaypal = true;
            this.disableAmountField = false;
        }
        else {

            var splitvalues = this.cid.split('#');

            getPledgeData({ 'contractId': splitvalues[0] }).then(result => {

                this.productName = result.Product__r.Name;
                this.productImgURL = FoundationImages + '/img/' + result.Product__r.Pledge_Image__c;
                this.priductDescription = result.Product__r.Description;
                this.productDidYouKnow = result.Product__r.Did_You_Know__c;
                this.productLearnMoreURL = result.Product__r.Learn_More_URL__c;
                this.vendorfee = parseFloat(splitvalues[2]);
                this.originalamt = parseFloat(splitvalues[1]);
                this.total = parseFloat(this.originalamt) + parseFloat(this.vendorfee);
                this.amount = this.total.toFixed(2);
                this.vendorfee = parseFloat(this.vendorfee).toFixed(2);


            }).catch(error => {
                	
            });

            this.showCheckoutPaypal = false;
            this.disableAmountField = true;
            this.pledgeFulfillDurationValue = 'Now';
            this.pledgeFulfillModeOption = 'Paypal';
            this.showPaymentAccounts = false;
            this.showdisplay = true;

        }

    }

    @wire(getCashAccountNumberByAccountId, { accountId: '$accountIduser' })
    cashAccountNumber;


    @wire(getRecordTypeId, { objectName: 'FinServ__FinancialAccount__c', strRecordTypeName: 'BankingAccount' })
    bankingAccountRecordtypeID;

    @wire(getRecordTypeId, { objectName: 'Contract', strRecordTypeName: 'Pledge' })
    contractRecordTypeID;

    @wire(getRecordTypeId, { objectName: 'Transfer_Fund__c', strRecordTypeName: 'Pledge' })
    transferFundRecordTypeID;

    @wire(getRecordTypeId, { objectName: 'Transfer_Fund__c', strRecordTypeName: 'Contribution' })
    transferFundRecordTypeContId;

    @wire(getCashAccountIdByAccount, { accountId: '$accountIduser' })
    cashAccountId;

    recordPageUrl;

    @wire(getScholarshipFinAccount)
    scholarshipFinAccountId;

    @wire(getPicklistValues,
        {
            recordTypeId: '$bankingAccountRecordtypeID.data',
            fieldApiName: FINANCIAL_ACCOUNT_TYPE
        }
    )
    bankAccountPicklist;


    get pledgeFulfillDurationOptions() {
        if (this.contractId) {
            return [
                { label: 'I will fulfill payment later', value: 'I will fulfill payment later' },
                { label: 'Now', value: 'Now' },
                { label: 'Remove this Pledge', value: 'Remove this Pledge' },
            ];
        } else {
            return [
                { label: 'I will fulfill payment later', value: 'I will fulfill payment later' },
                { label: 'Now', value: 'Now' },
            ];
        }

    }

    get pledgeFulfillModeOptions() {
        return [
            { label: 'ACH', value: 'ACH' },
            { label: 'Cash Account', value: 'Cash Account' },
            { label: 'Check', value: 'Check' },
            { label: 'Paypal', value: 'Paypal' },
        ];
    }


    handlePledgeFulfillModeChange(event) {
        this.showPaymentAccounts = false;
        this.pledgeFulfillModeOption = event.target.value;
        this.buttonText = 'Submit';
        if (this.pledgeFulfillModeOption == 'Check') {
            this.showCheckAddress = true;
        } else if (this.pledgeFulfillModeOption == 'ACH') {
            this.showPaymentAccounts = true;
            this.showCheckAddress = false;
        }
        else {

            if (this.pledgeFulfillModeOption == 'Paypal') {
                this.buttonText = 'Check out with Paypal';
            }
            this.showCheckAddress = false;
        }
        if (this.disableAmountField) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'pledgewizard'
                },
                state: {
                    contractId: this.contractId,
                    selectProgramId: this.selectProgramId,
                    currentPage: '3'
                }
            });
        }

    }

    handlePledgeFulfillDurationChange(event) {
        this.buttonText = 'Next';
        
        this.pledgeFulfillDurationOption = event.target.value;
        
        if (event.target.value == 'I will fulfill payment later') {
            this.buttonText = 'Next';
            this.showdisplay = this.showPaymentAccounts = false;
        } if (event.target.value == 'Now') {
            
            this.buttonText = 'Submit';
            this.pledgeFulfillModeOption = 'ACH';
            this.showPaymentAccounts = true;
            this.showdisplay = true;
        } if (event.target.value == 'Remove this Pledge') {
            
            this.showdisplay = this.showPaymentAccounts = false;
        }
        if (this.disableAmountField) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'pledgewizard'
                },
                state: {
                    contractId: this.contractId,
                    selectProgramId: this.selectProgramId,
                    currentPage: '3'
                }
            });
        }

    }

    handleAcceptTermsSelection(event) {
        this.acceptTerms = event.target.checked;
    }

    handleAmountChange(event) {
        this.amount = event.target.value;
    }


    isValid() {
        var val = true;
        if (this.pledgeFulfillDurationOption == null) {
            val = false;
            this.showToast('Error', 'Please Select an Option', 'error');
        } else {
            if (this.pledgeFulfillDurationOption == 'Now') {

                if (this.pledgeFulfillModeOption == null) {
                    val = false;
                    this.showToast('Error', 'Please Select an Option', 'error');
                } else {
                    if (this.pledgeFulfillModeOption == 'Check' ||
                        this.pledgeFulfillModeOption == 'Paypal' ||
                        this.pledgeFulfillModeOption == 'Cash Account' ||
                        this.pledgeFulfillModeOption == 'ACH'
                    ) {
                        if (this.amount == null || this.amount.length === 0) {
                            val = false;
                            this.showToast('Error', 'Please enter donation amount', 'error');
                        } else {
                            if (this.amount.indexOf('-') !== -1) {
                                val = false;
                                this.showToast('Error', 'You must enter a positive amount', 'error');
                            }
                        }
                    }
                    if (this.pledgeFulfillModeOption == 'ACH') {
                        if (!this.achCheckboxSelected) {
                            val = false;
                            this.showToast('Error', 'Please authorize the Florida Prepaid College Board to initiate a one-time ACH transaction', 'error');
                        }

                        if (!this.template.querySelector('c-bank-accounts-component').validate()) {
                            val = false;
                        }
                    }
                }

            }
            if (this.pledgeFulfillDurationOption == 'I will fulfill payment later') {
                val = true;
            }
            if (this.pledgeFulfillDurationOption == 'Remove this Pledge') {
                val = true;
                this.contractRecord.Status = 'Inactive';
            }

        }

        return val;
    }


    handleSpecifyPayment1(event) {

        if (this.isValid()) {
            this.createContractRecord();
        }
    }




    createContractRecord() {
        this.isLoading = true;
        if (this.pledgeFulfillModeOption == 'Paypal') {

            this.originalamt = parseFloat(this.amount);
            let flatFee = 0.30;
            let percentageFee = 0.978;
            var payAmount = (parseFloat(this.originalamt) + parseFloat(flatFee)) / parseFloat(percentageFee);
            this.vendorfee = parseFloat(payAmount) - parseFloat(this.originalamt);
            this.amount = this.gaussRound(this.payAmount, 2);

            
        } else {
            this.vendorfee = 0;
            this.originalamt = parseFloat(this.amount);
        }

        
        
         
        

        this.contractRecord.Id = this.contractId;
        this.contractRecord.RecordTypeId = this.contractRecordTypeID.data;
        this.contractRecord.AccountId = this.accountIduser;
        this.contractRecord.Contact__c = this.userContactId;
        this.contractRecord.Product__c = this.selectProgramId;
        if (this.pledge) {
            this.contractRecord.Pledge__c = this.pledge;
        }
        if (this.county) {
            this.contractRecord.County__c = this.county;
        }
        if (this.zip) {
            this.contractRecord.Zip_Code__c = this.zip;
        }



        var cashAccountId = null;
        var status = 'Complete';
        if (this.pledgeFulfillModeOption == 'Paypal') {
            status = 'Pending';
        }
        if (this.pledgeFulfillModeOption == 'ACH') {
            cashAccountId = this.cashAccountId.data;
            status = 'Queued';
        }
        if (this.pledgeFulfillModeOption == 'Check') {
            cashAccountId = this.cashAccountId.data;
            status = 'Queued';
        }
        if (this.pledgeFulfillModeOption == 'Cash Account') {
            cashAccountId = this.cashAccountId.data;
        }

        var transferFundRecord = {
            RecordTypeId: this.transferFundRecordTypeID.data,
            Financial_Account_Cash__c: cashAccountId,
            Financial_Account_Investment__c: this.scholarshipFinAccountId.data,
            Source_Type__c: this.pledgeFulfillModeOption,
            Transfer_Amount__c: this.originalamt,
            Fee__c: this.vendorfee,
            Status__c: status,
            Frequency__c: 'One-Time',
            Contact__c: this.userContactId,
            Account__c: this.accountIduser
        }



        savePledgeDetails({
            contract: this.contractRecord,
            tranfund: transferFundRecord,
            mode: this.pledgeFulfillDurationOption,
            bankAccount: this.finAcctRecord
        })
            .then(result => {
                //window.
                // Clear the user enter values
                this.contractRecord = {};
                transferFundRecord = {};
                if (this.pledgeFulfillDurationOption == 'I will fulfill payment later') {
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            pageName: 'pledgefinishpage'
                        },
                        state: {
                            cid: result
                        }
                    });
                } else if(this.pledgeFulfillDurationOption == 'Remove this Pledge'){
                    this.showToast('Success!', 'Your pledge has been removed.', 'success');
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            pageName: 'mydashboard'
                        }
                    });
                } else {
                    if (this.pledgeFulfillModeOption == 'Paypal') {
                        this.template.querySelectorAll('select[id=pledgeFulfillModeOption]').value = this.pledgeFulfillModeOption;
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                pageName: 'paypalpaymentpage'
                            },
                            state: {
                                cid: result + '#' + this.originalamt + '#' + this.vendorfee,
                                hip: true
                            }
                        });
                    } else {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                pageName: 'pledgefinishpage'
                            },
                            state: {
                                xid: result
                            }
                        });
                    }
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            });
    }




    handleGoBack(event) {
        const passEvent = new CustomEvent('previous', {
            detail: {
                contractId: this.contractId,
                selectProgramId: this.selectProgramId,
                county: this.county,
                zip: this.zip,
                pledge: this.howMuch
            }
        });
        this.dispatchEvent(passEvent);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            type: variant
        });
        this.dispatchEvent(evt);
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

    handleFinAccountInfo(event) {
        this.finAcctRecord = event.detail.finAcctRecord;
    }

    handleACHCheckboxSelection(event) {
        this.achCheckboxSelected = event.target.checked;
    }

}