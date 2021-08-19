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

import CLAIM_OBJECT from '@salesforce/schema/Claim';
import PAYMENT_METHODOLOGY from '@salesforce/schema/Claim.Payment_Methodology__c';
import CLAIM_TERM from '@salesforce/schema/Claim.Term__c';
import CLAIM_YEAR from '@salesforce/schema/Claim.Year__c';
import CLAIM_TYPE from '@salesforce/schema/Claim.ClaimType';
import policyCoverages from '@salesforce/apex/ClaimProcessController.getPolicyCoverages';
import getClaimRateCodes from '@salesforce/apex/ClaimProcessController.getClaimRateCodes';
import submitClaim from '@salesforce/apex/ClaimProcessController.submitClaim';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {
    NavigationMixin
} from 'lightning/navigation';

export default class PrepaidClaim extends NavigationMixin(LightningElement) {

    @api recordId;
    @track error; 
    @track selectedCollege;
    coverageTypes = [];
    @track fileName = '';
    @track filesUploaded = [];
    selectedCoveragesValues = '';
    @track _selected = [];
    SelOptionsLabels = [];
    recordValue;
    coverageIdList;
    confirmationScreen;
    termValue = 'Spring';
    claimTypeValue = 'Account Owner Reimbursement';
    claimYearValue = new Date().getFullYear() + '';
    requestedUnitsValue;
    coverageScreen = true;
    coveragesNotSelected = true;
    claimId;
    filesUploaded = [];
    selectedCoverageLabel = [];
    requestedAmountValue;
    policyLabel = '';
    contentDocumentName;
    isLoading = false;
    selectedCoveragesMap = {};
    paymentOptions;
    coverages = true;
    policyId;
    rateCodeValue;
    rateCodes = [];

    get acceptedUploadFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.txt'];
    }

    @wire(policyCoverages, { policyId: '$recordId' })
    policyCoverageList({ error, data }) {
        
        console.log('recordId  >> '+  this.recordId + data);
        if (data) {
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
        console.log('OptiONs  coverageOptions >> '+ JSON.stringify(this.coverageTypes));
        return this.coverageTypes;
    }

    @wire(getObjectInfo, { objectApiName: CLAIM_OBJECT })
    claimInfo;
    
    @wire(getPicklistValues,
        {
            recordTypeId: '$claimInfo.data.defaultRecordTypeId',
            fieldApiName: PAYMENT_METHODOLOGY 
        }
    )
    paymentMethodologyPicklist;

    @wire(getPicklistValues,
        {
            recordTypeId: '$claimInfo.data.defaultRecordTypeId',
            fieldApiName: CLAIM_TYPE 
        }
    )
    claimTypePicklist;

    @wire(getPicklistValues,
        {
            recordTypeId: '$claimInfo.data.defaultRecordTypeId',
            fieldApiName: CLAIM_TERM
        }
    )
    claimTermPicklist;


    @wire(getPicklistValues,
        {
            recordTypeId: '$claimInfo.data.defaultRecordTypeId',
            fieldApiName: CLAIM_YEAR
        }
    )
    claimYearPicklist;

    handleChangeClaimTermOptions(event) {
        this.termValue = event.detail.value;
    }

    handleChangeClaimTypeOptions(event) {
        this.claimTypeValue = event.detail.value;
        this.policyId = this.recordId;
    }

    handleChangeClaimYearOptions(event) {
        this.claimYearValue = event.detail.value;
    }

    handleChangeRateCodeOptions(event) {
        this.rateCodeValue = event.detail.value;
    }

    handleSelected(event) {
        this.selectedCoveragesValues = event.detail.value;
        console.log('selected value', this.selectedCoveragesValues);
        
        this.SelOptionsLabels = [];
        for (let i = 0; i < this.coverageTypes.length; i++) {
            if (this.selectedCoveragesValues.includes(this.coverageTypes[i].value)) {
                this.SelOptionsLabels.push(this.coverageTypes[i].label);
               // this.coverageIdList.push(this.coverageTypes[i].value);
            }
        }

        console.log('SelOptionsLabels value', this.SelOptionsLabels);
       // console.log('coverageIdList', this.coverageIdList);
    }

    handleSelectChange(event) {
        this.selectedCollege = event.detail.recordId;
        this.recordValue = event.detail.fieldValue;
        if(this.selectedCollege)
        {
            getClaimRateCodes({ schoolId: this.selectedCollege })
            .then(result => {
                console.log('result: >>>>> ' +result.length);
               // console.log('result: >>>>> ' +JSON.stringify(result));
                 for(let i=0; i<result.length; i++) {
                    this.rateCodes = [...this.rateCodes ,{value: result[i].Id , label: result[i].Name}];                                   
                }  
            
                this.error = undefined;      
            })
            .catch(error => {
            console.log('error: ' + JSON.stringify(error));
            });
        }
    }

    get rateCodeOptions() {
        return this.rateCodes;
    }

    handleRequestedAmountValueChange(event) {
        this.requestedAmountValue = event.detail.value;

    }

    handleRequestedUnitValueChange(event) {
        this.requestedUnitsValue = event.detail.value;
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert("Contents : " + JSON.stringify(uploadedFiles));        
    }

    goToconfirmationScreen() {

        const allValid = [...this.template.querySelectorAll('lightning-combobox'),...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            this.coverageScreen = false;
            this.confirmationScreen = true;
        }else{
            alert('Please enter/select the required fields.');   
        }
    }

    editClaim(event) {
        this.confirmationScreen = false;
        this.coverageScreen = true;
    }



    CreateClaim() {
       this.confirmationScreen = false;
       this.isLoading = true;
        console.log('selectedCollege', this.selectedCollege);
        console.log('termValue', this.termValue);
        console.log('yearValue', this.claimYearValue);
        console.log('claimTypeValue', this.claimTypeValue);
        console.log('requestedUnitValue', this.requestedUnitsValue);
        console.log('coveragePlanId', this.coverageIdList);

        var claimData = {
            "schoolId": this.selectedCollege,
            "termValue": this.termValue,
            "yearValue" : this.claimYearValue,
            "claimTypeValue" : this.claimTypeValue,
            "requestedUnitValue" : this.requestedUnitsValue,
            "requestedAmountValue" : this.requestedAmountValue,
            "coveragePlanId" : this.coverageIdList,
            "files" : this.filesUploaded,
            "policyId" : this.recordId,
            "isSchoolInvoice" : false,
            "paymentMethodUpdated" : false,
            "rateCodeValue" : this.rateCodeValue
          }
          var strClaimData =   JSON.stringify(claimData);
          console.log('strClaimData >> ' + strClaimData);

          submitClaim({
            strClaimData : strClaimData,
            coveragePlanId : this.coverageIdList,
            coveragesPlans : this.SelOptionsLabels

        })
        .then(result => {
            var conts = result;
            this.claimId = result;
            console.log('Claim Id >> ' + result);
            const event = new ShowToastEvent({
                title: 'Claim Created Successfully.',
                message: 'Redirecting to Claim record Page.',
                variant: 'success',
            });
            this.dispatchEvent(event);
            this.isLoading = false;
            this.navigateToViewClaim();
        })
        .catch(error => {
            this.confirmationScreen = false;
            let errorMessage;
            console.log(JSON.stringify(error));
            if ( error.body.message) {
                errorMessage =error.body.message;
            }
            alert(errorMessage);
            this.navigateToView();
        });
        
    }


    navigateToViewClaim() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.claimId,
                objectApiName: 'Claim',
                actionName: 'view'
            }
        });
    }

    navigateToView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'InsurancePolicy',
                actionName: 'view'
            }
        });
    }
     
}