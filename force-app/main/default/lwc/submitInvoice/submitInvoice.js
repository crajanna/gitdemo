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

import createInvoiceRec from '@salesforce/apex/SubmitInvoiceController.createInvoice';
import CLAIM_OBJECT from '@salesforce/schema/Claim';
import SCHOOL_INVOICE_OBJECT from '@salesforce/schema/School_Invoice__c';
import CLAIM_TERM from '@salesforce/schema/Claim.Term__c';
import CLAIM_YEAR from '@salesforce/schema/Claim.Year__c';
import saveFile from '@salesforce/apex/SubmitInvoiceController.saveFile';
import getClaimRateCodes from '@salesforce/apex/SubmitInvoiceController.getClaimRateCodes';
import INVOICE_TYPE from '@salesforce/schema/School_Invoice__c.Invoice_Type__c';


import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import SystemModstamp from "@salesforce/schema/Account.SystemModstamp";

export default class submitInvoice extends LightningElement {

@track error;

@track customObjArr;
isSaved= true;
@api recordId;
termValue;
claimYearValue;
isLoading=false;
@track fileName = '';
filesUploaded = [];
file;
MAX_FILE_SIZE = 1500000;
fileReader;
fileContents;
@track data;
@track isTrue = true;
rateCodes = [];
invoiceTypeValue;
selectedCollege;
recordValue;
valueChange;
confirmationScreen=false;
schoolInvoiceScreen = true;
totalCreditHrs = 0;
totalAmount = 0.0;
totalEstimatedHours;
totalEstimatedAmount;
totalRecords;
totalEstimatedRecords;



@track obj = {
    "studentId":"",
    "ssn":"",
    "birthDate":"",
    "rateCode":"",
   // "rateDesc":"",
    "creditHrBilled":"",
    "amtBilled":"",
    "referenceNbr":""
}
@track arr= [] ;   


    get rateOptions() {
        return this.rateCodes;
    }

    goToconfirmationScreen() {

        const isInputsCorrect = [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        //alert(isInputsCorrect);
        //var totalCnt;
        if(isInputsCorrect)    
        {
            console.log('isInputsCorrect >>> '+isInputsCorrect);
            var isDataPresent = false;
            
            for(var i=0; i<this.arr.length;i++)
            {        
                var comp = this.arr[i];
                if((comp.studentId != '' || comp.ssn != '' || comp.birthDate != '') && (comp.creditHrBilled != '' || comp.amtBilled != ''))
                {   
                   // totalCnt = parseInt(totalCnt) + 1;
                    if(!!comp.creditHrBilled){
                        this.totalCreditHrs = parseInt(this.totalCreditHrs) + parseInt(comp.creditHrBilled);
                    }  
                    if(!!comp.amtBilled){     
                        this.totalAmount = parseInt(this.totalAmount) + parseInt(comp.amtBilled);
                    }
                    isDataPresent = true;
                }
            }

            //this.totalRecords = totalCnt;
            console.log('totalHrs >>> '+this.totalCreditHrs);
            console.log('totalAmount >>> '+this.totalAmount);
            if(!isDataPresent)
            {
                alert('Please fill in the data for at least one record.');
                return;
            }
                this.schoolInvoiceScreen = false;
                this.confirmationScreen = true;
               
        }
    }

    editDetails(event) {
        this.confirmationScreen = false;
        this.schoolInvoiceScreen = true;
    }


    createRecords()
    {
            this.confirmationScreen = false;
            this.isLoading = true;   
            createInvoiceRec({
            
                invRecords : JSON.stringify(this.arr),
                recId : this.recordId,
                selectedCollege : this.selectedCollege,
                term : this.termValue,
                year : this.claimYearValue,
                invoiceType : this.invoiceTypeValue
            })
            .then(result => {
                console.log('result...'+result);
                if(result == 'success')  
                {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'School Invoice record is created',
                        variant: 'success'
                    });
                    this.isLoading = false;
                    this.dispatchEvent(event);
                    this.closeQuickAction();
                } else
                {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something went wrong. Please contact System Administrator.',
                        variant: 'error'
                    });
                    this.isLoading = false;
                    this.dispatchEvent(event);
                    
                }
            })
            .catch(error => {
                this.error=error
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong. Please contact System Administrator.',
                    variant: 'error'
                });
                this.isLoading = false;
            })
        
    }

    @wire(getObjectInfo, { objectApiName: CLAIM_OBJECT })
    claimInfo;

    @wire(getObjectInfo, { objectApiName: SCHOOL_INVOICE_OBJECT })
    schoolInvoiceInfo;


    @wire(getPicklistValues,
        {
            recordTypeId: '$claimInfo.data.defaultRecordTypeId',
            fieldApiName: CLAIM_TERM
        }
    )
    claimTermPicklist;

    @wire(getPicklistValues,
        {
            recordTypeId: '$schoolInvoiceInfo.data.defaultRecordTypeId',
            fieldApiName: INVOICE_TYPE
        }
    )
    invoiceTypePicklist;


    @wire(getPicklistValues,
        {
            recordTypeId: '$claimInfo.data.defaultRecordTypeId',
            fieldApiName: CLAIM_YEAR
        }
    )
    claimYearPicklist;

    handleChangeClaimTermOptions(event) {
        this.termValue = event.detail.value;
        console.log('Term: >>>>> ' +this.termValue + 'Year : ' +this.claimYearValue);
        if(this.termValue)
        {
            this.rateCodes = [];
            getClaimRateCodes({ schoolId: this.valueChange , termValue : this.termValue , yearValue : this.claimYearValue,invoiceType : this.invoiceTypeValue })
            .then(result => {
                console.log('result: >>>>> ' +result.length);
                console.log('valueChange: >>>>> ' +this.valueChange);
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



    handleChangeClaimYearOptions(event) {
        this.claimYearValue = event.detail.value;
        console.log('Term: >>>>> ' +this.termValue + 'Year : ' +this.claimYearValue);
        if(this.claimYearValue)
        {
            this.rateCodes = [];
            getClaimRateCodes({ schoolId: this.valueChange , termValue : this.termValue , yearValue : this.claimYearValue,invoiceType : this.invoiceTypeValue })
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


    handleChangeInvoiceType(event) {
        this.invoiceTypeValue = event.detail.value;
        console.log('Term: >>>>> ' +this.termValue + 'Year : ' +this.claimYearValue + 'invoiceTypeValue' + this.invoiceTypeValue);
        if(this.invoiceTypeValue)
        {
            this.rateCodes = [];
            getClaimRateCodes({ schoolId: this.valueChange , termValue : this.termValue , yearValue : this.claimYearValue,invoiceType : this.invoiceTypeValue })
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

    handleSelectChange(event) {
        this.selectedCollege = event.detail.recordId;
        this.recordValue = event.detail.fieldValue;
        if(this.selectedCollege != '' && this.selectedCollege != this.recordId){
            this.valueChange = this.selectedCollege; 
        }else{
            this.valueChange = this.recordId; 
        }
        console.log('valueChange >>>' + this.valueChange);
        if(this.selectedCollege)
        {
            this.rateCodes = [];
            getClaimRateCodes({ schoolId: this.valueChange , termValue : this.termValue , yearValue : this.claimYearValue,invoiceType : this.invoiceTypeValue })
            .then(result => {
                console.log('schoolId: >>>>> ' +this.valueChange);
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

    handleTotalEstimatedHoursChange(event) {
        this.totalEstimatedHours = event.detail.value;

    }

    handleTotalEstimatedAmountChange(event) {
        this.totalEstimatedAmount = event.detail.value;
    }

    handleTotalRecordsChange(event) {
        this.totalRecords = event.detail.value;
    }

    handleTotalEstimatedRecordsChange(event) {
        this.totalEstimatedRecords = event.detail.value;
    }

    connectedCallback() 
    {
        this.arr.push(this.obj);
        this.arr.push(this.obj);
        this.arr.push(this.obj);
        this.arr.push(this.obj);
        this.arr.push(this.obj);

        this.claimYearValue = new Date().getFullYear() + '';
        this.valueChange = this.recordId;
        console.log('connectedCallback >>>>>' +this.valueChange);
 
    } 

    handleOnchangeStudName(event)
    {
        var stringArr = JSON.stringify(this.arr);
        var studNameIndx = parseInt(event.target.accessKey);
        var studNameVal = event.target.value;
        var StudName= event.target.name;
        var localArr = JSON.parse(stringArr);
        localArr[studNameIndx][StudName] = studNameVal;
        this.arr = localArr;
    }

   
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    doCancel()
    {
        this.isSaved = false;
        this.closeQuickAction();
    }
    
    handleFilesChange(event) 
    {
        if(event.target.files.length > 0) 
        {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.isTrue = false;
        }
    }
            
    handleSave() {
        if(this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else {
            this.fileName = 'Please select a CSV file to upload!!';
        }
    }

    uploadHelper() 
    {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) 
        {
            window.console.log('File Size is to long');
            return ;
        }
        this.isLoading = true;
        this.fileReader= new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            this.saveToFile();
        });
        this.fileReader.readAsText(this.file);
    }
    
    saveToFile() 
    {
        this.isLoading = true;
        saveFile({ 
            base64Data: JSON.stringify(this.fileContents), 
            recID: this.recordId,
            fileName : this.file.name,
            term : this.termValue,
            year : this.claimYearValue,
            invoiceType : this.invoiceTypeValue

        })

        .then(result => {
                this.data = result;
                this.fileName = this.fileName + ' - Uploaded Successfully';
                //this.isTrue = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.file.name + ' - Upload is Uploaded Successfully!!.',
                        message: 'You will recieve an email once all records are inserted.',
                        variant: 'info'
                    })
                );
                this.isLoading = false;
                this.closeQuickAction();
            
        })
        .catch(error => {
            window.console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading File. Either file format or data is incorrect.',
                    message: error.message,
                    variant: 'error'
                }),
            );
            this.isLoading = false;
        });
    }
}