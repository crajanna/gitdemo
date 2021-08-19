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

import INSURANCE_POLICY_OBJECT from '@salesforce/schema/InsurancePolicy';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import lumpsumPayments from '@salesforce/apex/LumsumPolicyPaymentController.lumpsumPayments';

import {
    NavigationMixin
} from 'lightning/navigation';



export default class LumsumPolicyPayment extends NavigationMixin(LightningElement) {

    @api recordId;
   // coverageTypes = [];
    lumSumAmount = 0;
    //coverageScreen = false;
   // lumsumScreen = true;
    isLoading = false;
    dueDate;
    prepaidFinanceHistoryId;

   /* @track columns = [{
        label: 'Coverage Name',
        fieldName: 'coverageName',
        type: 'text',
        sortable: true
    },
    {
        label: 'Remaining Balance',
        fieldName: 'remainingBalance',
        type: 'currency',
        sortable: true
    },
    {
        label: 'Lumsum Amount',
        fieldName: 'lumsumAmount',
        type: 'currency',
        sortable: true,
        editable: true
    }
];

    @track error;
    @track coveragePlanList ;

    goToCoverages(event) {
        this.lumsumScreen = false;
        this.isLoading = true;
            policyCoverages({
                    policyId: this.recordId
                })
                .then(result => {
                    console.log('recordId'+this.recordId);  
                    console.log('lumSumAmount>>>>'+ this.lumSumAmount)
                    var coveragePlanData ;
                    let coveragePlans = [];
                    let avgBalance = 0;
                    let policyPrice;
                    if (result) {
                        console.log("Coverage Plan : >>>" + JSON.stringify(result));
                        for(let i=0; i<result.length; i++) {  
                            policyPrice = result[i].InsurancePolicy.Price__c ;  
                            if(policyPrice > 0){
                                avgBalance = Math.round((result[i].Remaining_Balance__c / policyPrice ) * this.lumSumAmount);   
                            }
                            coveragePlanData = {
                                "Id": result[i].Id,
                                "coverageName":result[i].CoverageName ,
                                "remainingBalance":result[i].Remaining_Balance__c,
                                "lumsumAmount" : avgBalance
                            };   
                            coveragePlans.push(coveragePlanData);                             
                        }  
                        this.coveragePlanList = coveragePlans;
                    }
                    console.log('coveragePlanList'+JSON.stringify(this.coveragePlanList));
                    this.coverageScreen = true;
                    this.isLoading = false;
                })
                .catch(error => {
                    this.coveragePlanList = undefined;
                });
        

    }

    edit(event) {
        this.isLoading = true;
        this.coverageScreen = false;
        this.lumsumScreen = true;
        this.isLoading = false;
    }*/
    
    handleLumSumAmountValueChange(event) {
        this.lumSumAmount = event.detail.value;
    }

    handleDueDateChange(event) {
        this.dueDate = event.detail.value;
    }

    createLumsumPayment() {
        this.isLoading = true;
        console.log('lumSumAmount', this.lumSumAmount);
        console.log('date', this.dueDate);
        console.log('coveragePlanId', this.recordId);


        lumpsumPayments({
            coveragePlanId : this.recordId,
            dueDate : this.dueDate,
            lumSumAmount : this.lumSumAmount,
            type : 'Lumpsum'

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

    postReversal() {
        this.isLoading = true;
        console.log('lumSumAmount', this.lumSumAmount);
        console.log('date', this.dueDate);
        console.log('coveragePlanId', this.recordId);


        lumpsumPayments({
            coveragePlanId : this.recordId,
            dueDate : this.dueDate,
            lumSumAmount : this.lumSumAmount,
            type : 'Reversal'

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
                objectApiName: 'Prepaid_Finance_History__c',
                actionName: 'view'
            }
        });
    }
}