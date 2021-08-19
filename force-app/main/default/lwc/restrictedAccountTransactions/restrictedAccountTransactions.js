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

import RESTRICTED_ACCOUNT_TRANSACTION_OBJECT from '@salesforce/schema/Restricted_Account_Transaction__c';
import SOURCE_CATEGORY from '@salesforce/schema/Restricted_Account_Transaction__c.Source_Category__c';
import SOURCE_SUB_CATEGORY from '@salesforce/schema/Restricted_Account_Transaction__c.Source_Sub_Category__c';
import TRANSACTION_TYPE from '@salesforce/schema/Restricted_Account_Transaction__c.Transaction_Type__c';
import TRANS_MONTH from '@salesforce/schema/Restricted_Account_Transaction__c.Month__c';
import TRANS_YEAR from '@salesforce/schema/Restricted_Account_Transaction__c.Year__c';


import createRestrictedAccountTransactions from '@salesforce/apex/RestrictedAccountTransController.createRestrictedAccountTransactions';
import policyCoverages from '@salesforce/apex/RestrictedAccountTransController.getPolicyCoverages';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';


import {
    NavigationMixin
} from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class RestrictedAccountTransactions extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    @track sourceCategoryOptions;
    @track sourceSubCategoryOptions;
    subTypesData;
    sourceCategoryValue='';
    sourceSubCategoryValue='';
    transactionTypeValue = '';
    amount;
    transactionId;
    @track policyScreen = false;
    contractId;
    budgetScenario = false;
    transactionMonthValue;
    transactionYearValue;

    coverageTypes = [];
    selectedCoveragesValues = '';

    @wire(CurrentPageReference)
    pageRef;

    get pageRefString() {
        
        return JSON.stringify(this.pageRef);
        
    }

    @wire(getObjectInfo, { objectApiName: RESTRICTED_ACCOUNT_TRANSACTION_OBJECT })
    restrictedAccountTransactionInfo;
    
    @wire(getPicklistValues, { recordTypeId: '$restrictedAccountTransactionInfo.data.defaultRecordTypeId', fieldApiName: SOURCE_CATEGORY })
    sourceCategoryInfo({ data, error }) {
        if (data) this.sourceCategoryOptions = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: '$restrictedAccountTransactionInfo.data.defaultRecordTypeId', fieldApiName: SOURCE_SUB_CATEGORY })
    sourceSubTypesInfo({ data, error }) {
        if (data) {
            this.subTypesData = data;
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$restrictedAccountTransactionInfo.data.defaultRecordTypeId',
            fieldApiName: TRANSACTION_TYPE 
        }
        )
        transactionTypelist;

    @wire(getPicklistValues,
        {
            recordTypeId: '$restrictedAccountTransactionInfo.data.defaultRecordTypeId',
            fieldApiName: TRANS_MONTH 
        }
        )
        transMonthlist;

    @wire(getPicklistValues,
        {
            recordTypeId: '$restrictedAccountTransactionInfo.data.defaultRecordTypeId',
            fieldApiName: TRANS_YEAR 
        }
        )
        transYearlist;

           

    handleSourceCategory(event) {
        this.budgetScenario = false;
        this.sourceCategoryValue = event.detail.value;
        if(this.sourceCategoryValue == 'Budget'){
            console.log(this.sourceCategoryValue);
            this.budgetScenario = true;
        }else{
            console.log(this.sourceCategoryValue);
            this.budgetScenario = false;
        }
        let key = this.subTypesData.controllerValues[event.target.value];
        this.sourceSubCategoryOptions = this.subTypesData.values.filter(opt => opt.validFor.includes(key));
    }

    handleSourceSubCategory(event) {
        this.sourceSubCategoryValue = event.detail.value;
    }

    handleAmount(event) {
        this.amount = event.detail.value;
    }

    handleTransactionType(event) {
        this.transactionTypeValue = event.detail.value;
    }

    handleTransactionMonth(event) {
        this.transactionMonthValue = event.detail.value;
    }

    handleTransactionYear(event) {
        this.transactionYearValue = event.detail.value;
    }

    createRecord(event) {
        
        var data = {
            "amount":this.amount,
            "recordId": this.recordId,
            "transactionTypeValue": this.transactionTypeValue,
            "sourceCategoryValue": this.sourceCategoryValue,
            "sourceSubCategoryValue" : this.sourceSubCategoryValue,
            "selectedCoveragesValues" : this.selectedCoveragesValues,
            "contractId" : this.contractId,
            "transactionMonthValue":this.transactionMonthValue,
            "transactionYearValue":this.transactionYearValue
          }
          console.log('data >> ' + data);
          var strData =   JSON.stringify(data);
          console.log('strData >> ' + strData);
          var strPageRef = JSON.stringify(this.pageRef);
          this.policyScreen = false;
          createRestrictedAccountTransactions({
                strData : strData,
                strPageRef : strPageRef
				})
                .then(result => {
                    var conts = result;
                    this.transactionId = result;
                    console.log('transaction Id >> ' + result);
                    const event = new ShowToastEvent({
                        title: 'Transaction Created Successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    this.navigateToView();
    
    
                })
            .catch(error => {
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
                recordId: this.recordId,
                objectApiName: 'Restricted_Account_Transaction__c',
                actionName: 'view'
            }
        });
    }

    @wire(policyCoverages, { policyId: '$recordId' })
    policyCoverageList({ error, data }) {
        this.policyScreen = false;
        console.log('recordId>>>' + this.recordId + ' '+ this.policyScreen);
        console.log('policyCoverages  >> ' + JSON.stringify(data));
        if (data && data.length > 0) {
            this.policyScreen = true;
            let coverageIdList = [];
            for(let i=0; i<data.length; i++) {
                this.coverageTypes = [...this.coverageTypes ,{label: data[i].CoverageName,value: data[i].Id}];                                   
                coverageIdList.push(data[i].Id);
            }
            this.coverageIdList = coverageIdList;                
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
     }

     
     get coverageOptions() {
        return this.coverageTypes;
    }

    handleSelectChange(event) {
        this.contractId = event.detail.recordId;
        this.recordValue = event.detail.fieldValue;
    }

    handleSelected(event) {
        this.selectedCoveragesValues = event.detail.value;
        console.log('selected value', this.selectedCoveragesValues);
        
    }
    
}