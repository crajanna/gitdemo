import {
    LightningElement,
    api
} from 'lwc';

import {
    NavigationMixin
} from 'lightning/navigation';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import claimRecord from '@salesforce/apex/PrepaidClaimApprovalController.claimRecord';
import recalculateClaim from '@salesforce/apex/PrepaidClaimApprovalController.recalculateClaim';
import approvalProcess from '@salesforce/apex/PrepaidClaimApprovalController.approvalProcess';
import updateClaim from '@salesforce/apex/PrepaidClaimApprovalController.updateClaim';


export default class PrepaidClaimApproval extends NavigationMixin(LightningElement) {

@api recordId;
requestedUnitsValue;
requestedAmountValue;
claimTypeValue;
claimTypeOptions;
paymentMethodValue;
isLoading;
approveClaim;
claimConfirmation;
claimAmountValue;
actualUnitValue;
claimUnits;
approvedAmt;

connectedCallback() {

    this.isLoading = true;
    this.claimConfirmation = false;
    this.approveClaim = false;

    claimRecord({
        recordId: this.recordId
    })
    .then(result => {
        var conts = result;
        console.log('conts' + JSON.stringify(conts));
        this.requestedUnitsValue = result.Estimated_Hours__c;
        this.requestedAmountValue = result.Requested_Amount__c;
        this.paymentMethodValue = result.Payment_Methodology__c;
        this.claimTypeValue = result.ClaimType;
        this.claimAmountValue = result.Claim_Amount__c;

        this.isLoading = false;
        this.approveClaim = true;

    })
    .catch(error => {});
}

handleRequestedUnitValueChange(event) {
    this.requestedUnitsValue = event.detail.value
}

handleRequestedAmountValueChange(event) {
    this.requestedAmountValue = event.detail.value;
}

goToApprove(event) {

    this.isLoading = true;

    recalculateClaim({
            recordId: this.recordId,
            requestedUnitValue: this.requestedUnitsValue,
            requestedAmountValue: this.requestedAmountValue,
            claimTypeValue: this.claimTypeValue,
            paymentType: this.paymentMethodValue
        })
        .then(result => {
            var conts = result;
            let claimUnitsTemp = [];
            for (var key in conts) {
                let temp = {};
                temp.label = key;
                temp.value = conts[key];
                claimUnitsTemp.push(temp);
            }
            console.log('claimUnitsTemp.....'+JSON.stringify(claimUnitsTemp));
            this.ClaimUnits = claimUnitsTemp;
            this.approvedAmt = claimUnitsTemp.ApprovedAmt;
            console.log(' ApprovedAmt' + this.approvedAmt);
            this.claimConfirmation = true;
            this.isLoading = false;
            this.approveClaim = false;
        })

        .catch(error => {});

}

goToConfirm(event) {
    this.isLoading = true;
    console.log('this.ClaimUnits.....'+this.ClaimUnits);
    updateClaim({
            recordId: this.recordId,
            requestedUnitValue: this.requestedUnitsValue,
            requestedAmountVal: this.requestedAmountValue,
            claimType: this.claimTypeValue,
            paymentType: this.paymentMethodValue,
            claimAmountValue: this.claimAmountValue,
            actualUnitValue: this.actualUnitValue,
            claimUnits: JSON.stringify(this.ClaimUnits)

        })
        .then(result => {
            if (result == 'Success') {

                approvalProcess({
                        recordId: this.recordId
                    })
                    .then(result => {
                        const event = new ShowToastEvent({
                            title: 'Claim Approved',
                            message: 'Redirecting to claim record Page.',
                            variant: 'success',
                        });
                        this.isLoading = false;
                        this.claimConfirmation = false;
                        this.dispatchEvent(event);
                        this.navigateToViewPolicy();
                    })
            }
        })
        .catch(error => {});

}



navigateToViewPolicy() {
    console.log('navigateToViewPolicy Called');
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Claim',
            actionName: 'view'
        }
    });

    getRecordNotifyChange([{recordId: this.recordId}]);

}

}