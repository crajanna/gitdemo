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
import getRateCodes from '@salesforce/apex/SchoolInvoiceController.getRateCodes';
import createInvoice from '@salesforce/apex/SchoolInvoiceController.createInvoice';
import {
    NavigationMixin
} from 'lightning/navigation';

export default class SchoolInvoice extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track error; 
    rateCodeList;
    requestedAmountValue;
    requestedUnitsValue;
    ssn;
    birthDate;
    studentId;
    rateCodes = [];
    referenceNbr;
    rateCodeValue;
    saveAndNew = false;
    isLoading = false;
    redirect = true;
    resetpage = false;

    @wire(getRateCodes, { schoolInvoiceHeaderId: '$recordId' })
    getRateCodes({ error, data }) {
        
        console.log('recordId  >> '+  this.recordId + data);
        if (data) {
            let coverageIdList = [];
            for(let i=0; i<data.length; i++) {
                this.rateCodes = [...this.rateCodes ,{label: data[i].Name,value: data[i].Id}];                                    
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
     }

     get rateCodesOptions() {
        console.log('OptiONs  rateCodes >> '+ JSON.stringify(this.rateCodes));
        return this.rateCodes;
    }

    handleRequestedAmountValueChange(event) {
        this.requestedAmountValue = event.detail.value;

    }

    handleRequestedUnitValueChange(event) {
        this.requestedUnitsValue = event.detail.value;
    }

    handleSSNChange(event) {
        this.ssn = event.detail.value;

    }

    handleBirthDateChange(event) {
        this.birthDate = event.detail.value;
    }

    handleStudentIdChange(event) {
        this.studentId = event.detail.value;

    }

    handleReferenceNbrChange(event) {
        this.referenceNbr = event.detail.value;
    }

    handleChangeRateCodeOptions(event) {
        this.rateCodeValue = event.detail.value;
    }

    handleSave() {
        this.isLoading = true;
        var schoolInvoiceData = {
            "schoolHeaderId": this.recordId,
            "ssn" : this.ssn,
            "studentId" : this.studentId,
            "birthDate" : this.birthDate,
            "requestedUnitValue" : this.requestedUnitsValue,
            "requestedAmountValue" : this.requestedAmountValue,
            "referenceNbr" : this.referenceNbr,
            "rateCodeValue" : this.rateCodeValue
          }
          var strSchoolInvoiceData =   JSON.stringify(schoolInvoiceData);
          console.log('strSchoolInvoiceData >> ' + strSchoolInvoiceData);

        createInvoice({
            strSchoolInvoiceData : strSchoolInvoiceData
        })
        .then(result => {
            const event = new ShowToastEvent({
                title: 'School Invoice created Successfully.',
                message: 'Redirecting to School Invoice record Page.',
                variant: 'success',
            });
            this.dispatchEvent(event);
            this.isLoading = false;
            if(this.redirect == true){
                this.navigateToView();
            }
            if(this.resetpage== true){
                this.handleReset();
            }
        })
        .catch(error => {
            console.log(JSON.stringify(error));
            this.isLoading = false;
            this.navigateToView();
        });
    }

    navigateToView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'School_Invoice_Header__c',
                actionName: 'view'
            }
        });
    }

    handleSaveAndNew() {
        this.redirect = false;
        this.resetpage = true;
        this.handleSave();
    }

    handleReset() {
        this.template.querySelectorAll('lightning-input').forEach(element => {     
            element.value = null;          
          });
          this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = null;
        });
     }
     
     handleCancel(event){
         var url = window.location.href; 
         var value = url.substr(0,url.lastIndexOf('/') + 1);
         window.history.back();
         return false;
     }

}