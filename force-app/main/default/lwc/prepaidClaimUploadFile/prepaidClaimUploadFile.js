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
import policyCoverages from '@salesforce/apex/ClaimProcessControllerUploadFile.getPolicyCoverages';
import createClaim from '@salesforce/apex/ClaimProcessControllerUploadFile.createClaim';
import { refreshApex } from '@salesforce/apex';
import getRelatedFiles from '@salesforce/apex/ClaimProcessControllerUploadFile.getRelatedFiles';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {
    NavigationMixin
} from 'lightning/navigation';

export default class PrepaidClaimUploadFile extends NavigationMixin(LightningElement) {

    @api recordId;
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
    termValue;
    claimTypeValue;
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
    @track filePresent = false;
    lstAllFiles= [];
    
    @track uploadedFiles = [];
    handleActionFinished(event) {
        // Get the list of uploaded files
        var filesTemp = event.detail.files;
        //alert("Contents : " + JSON.stringify(filesTemp)); 
        //alert("No. of files uploaded : " + filesTemp.length);
        console.log(filesTemp.length);
        var addIndex = this.lstAllFiles.length;

        for(let i=0; i<filesTemp.length; i++){
            console.log(filesTemp[i].contentVersionId);
            //this.lstAllFiles.push(filesTemp.data[i].Id);
            var newIndex = i + addIndex;
            this.lstAllFiles[newIndex] = filesTemp[i].contentVersionId;
        }  
        //alert("Contents : " + JSON.stringify(this.lstAllFiles)); 
        //refreshApex(this.lstAllFiles); 
        getRelatedFiles({recordId: '$recordId'  ,
                            claimFileIds : this.lstAllFiles})
        .then(result => {
            var conts = result;
            this.uploadedFiles = result;
            console.log('uploadedFiles >> ' + result);
            if(this.uploadedFiles.length > 0){
                this.filePresent = true;
                const uploadedFiles = event.detail.files;
            }else{
                this.filePresent = false;
            }
            
            
        })
        .catch(error => {
            
        });    
    }
    

    handleDeleteAction(event) {
        // Get the list of uploaded files
        //var filesTemp = event.detail.files;
        //alert("Contents : " + JSON.stringify(filesTemp)); 
        //alert("No. of files uploaded : " + filesTemp.length);
        //console.log(filesTemp.length);
        //var addIndex = this.lstAllFiles.length;
        var deletedFileId = event.detail;
        console.log('deletedFileId-->'+deletedFileId);
        console.log('this.lstAllFiles-->'+this.lstAllFiles);

        for(let i=0; i<this.uploadedFiles.length; i++){
            if(deletedFileId === this.uploadedFiles[i].Id){
                var deletedIndex = this.lstAllFiles.indexOf(this.uploadedFiles[i].recordId);
                this.lstAllFiles.splice(deletedIndex, 1);
                break;
            }
        }  
        
        console.log('deletedIndex-->'+deletedIndex);
        console.log('this.lstAllFiles-->'+this.lstAllFiles); 
        //for(let i=0; i<filesTemp.length; i++){
            //console.log(filesTemp[i].contentVersionId);
            //this.lstAllFiles.push(filesTemp.data[i].Id);
            //var newIndex = i + addIndex;
            //this.lstAllFiles[i] = filesTemp[i].contentVersionId;
        //}  
        //alert("Contents : " + JSON.stringify(this.lstAllFiles)); 
        //refreshApex(this.lstAllFiles); 
        
        getRelatedFiles({recordId: '$recordId'  ,
                            claimFileIds : this.lstAllFiles})
        .then(result => {
            this.uploadedFiles = [];
            var conts = result;
            this.uploadedFiles = result;
            console.log('uploadedFiles >> ' + result);
            if(this.uploadedFiles.length > 0){
                this.filePresent = true;
                const uploadedFiles = event.detail.files;
            }else{
                this.filePresent = false;
            }
            
            
        })
        .catch(error => {
            
        });    
    }

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

    handleSelected(event) {
        this.selectedCoveragesValues = event.detail.value;
        console.log('selected value', this.selectedCoveragesValues);
        console.log('coverageTypes value', JSON.stringify(this.coverageTypes));
        this.SelOptionsLabels = [];
        for (let i = 0; i < this.coverageTypes.length; i++) {
            if (this.selectedCoveragesValues.includes(this.coverageTypes[i].value)) {
                this.SelOptionsLabels.push(this.coverageTypes[i].label);
               // this.coverageIdList.push(this.coverageTypes[i].value);
            }
        }
       // console.log('coverageIdList', this.coverageIdList);
    }

    handleSelectChange(event) {
        this.selectedCollege = event.detail.recordId;
        this.recordValue = event.detail.fieldValue;
    }

    handleRequestedAmountValueChange(event) {
        this.requestedAmountValue = event.detail.value;

    }

    handleRequestedUnitValueChange(event) {
        this.requestedUnitsValue = event.detail.value;
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
        //this.uploadedFiles.forEach(fileIterator => this.lstAllFiles.push(fileIterator.name));
        //console.log('JSON.stringify(this.uploadedFiles)', JSON.stringify(this.uploadedFiles));

        for(let i=0; i<this.uploadedFiles.length; i++){
            console.log(this.uploadedFiles[i].recordId);
            //this.lstAllFiles.push(this.uploadedFiles.data[i].Id);
            this.lstAllFiles[i] = this.uploadedFiles[i].recordId;

        }
        console.log('this.lstAllFiles=>' + this.lstAllFiles);
        //alert(JSON.stringify(this.uploadedFiles));
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
            "paymentMethodUpdated" : false
          }
          var strClaimData =   JSON.stringify(claimData);
          console.log('strClaimData >> ' + strClaimData);

        createClaim({
            strClaimData : strClaimData,
            coveragePlanId : this.coverageIdList,
            coveragesPlans : this.SelOptionsLabels,
            claimFileIds : this.lstAllFiles

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
            this.isLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'error while processing request',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });
        
    }


    navigateToViewClaim() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.policyId,
                objectApiName: 'Claim',
                actionName: 'view'
            }
        });
    }
     
}