import {
    track,
    api,
    wire
} from "lwc";
import {
    LightningElement
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';


import cancelUnits from '@salesforce/apex/CancelPrepaidUnitsController.cancelUnits';
import policyCoverages from '@salesforce/apex/CancelPrepaidUnitsController.getPolicyCoverages';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {
    NavigationMixin
} from 'lightning/navigation';

export default class CancelPrepaidUnits extends NavigationMixin(LightningElement)  {

    @api recordId;
    requestedAmountValue;
    requestedUnitsValue;

    
    handleRequestedAmountValueChange(event) {
        this.requestedAmountValue = event.detail.value;

    }

    handleRequestedUnitValueChange(event) {
        this.requestedUnitsValue = event.detail.value;
    }

   

    cancelUnits() {
        this.isLoading = true;
        console.log('requestedUnitsValue', this.requestedUnitsValue);
        console.log('requestedAmountValue', this.requestedAmountValue);
        console.log('coveragePlanId', this.recordId);


        cancelUnits({
            coveragePlanId : this.recordId,
            requestedAmountValue : this.requestedAmountValue,
            requestedUnitsValue : this.requestedUnitsValue

        })
        .then(result => {
            var conts = result;
            this.prepaidFinanceHistoryId = result;
            console.log('prepaidFinanceHistoryId >> ' + JSON.stringify(result));
            const event = new ShowToastEvent({
                title: 'Record Created Successfully.',
                message: 'Redirecting to Prepaid Finance History record Page.',
                variant: 'success',
            });
            this.dispatchEvent(event);
            this.isLoading = false;
            this.navigateToView();
        })
        .catch(error => {
            this.isLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'error while processing request',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });
        
    }

    navigateToView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.policyId,
                objectApiName: 'InsurancePolicyCoverage',
                actionName: 'view'
            }
        });
    }

    
 
}