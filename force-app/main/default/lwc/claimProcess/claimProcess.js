import {
    LightningElement,
    api,
    track
} from 'lwc';
import coverageTypes from '@salesforce/apex/ClaimProcessApex.coveragesTypes';
import claimTerms from '@salesforce/apex/ClaimProcessApex.claimTerm';
import claimTypes from '@salesforce/apex/ClaimProcessApex.claimTypes';
import claimYears from '@salesforce/apex/ClaimProcessApex.claimYears';
import createClaim from '@salesforce/apex/ClaimProcessApex.processClaim';
import paymentMethodology from '@salesforce/apex/ClaimProcessApex.paymentMethodology';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'


export default class ClaimProcess extends NavigationMixin(LightningElement) {

    @api recordId;
    @track selectedCollege;
    @track fileName = '';
    @track filesUploaded = [];
    selectedCoverages = [];
    @track _selected = [];
    coverageOptions;
    SelOptionsLabels = [];
    recordValue;
    coverageIdList;
    confirmationScreen;
    claimTermOptions;
    claimTypeOptions;
    claimYearOptions
    termValue;
    claimTypeValue;
    claimYearValue = new Date().getFullYear() + '';
    requestedUnitsValue;
    coverageScreen = false;
    coveragesNotSelected = true;
    newPolicyScreen = false;
    documentScreen = false;
    claimId;
    filesUploaded = [];
    selectedCoverageLabel = [];
    requestedAmountValue;
    policyLabel = '';
    contentDocumentName;
    isLoading = false;
    selectedCoveragesMap = {};
    paymentOptions;


    get acceptedUploadFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.txt'];
    }

    connectedCallback() {
        var currentTime = new Date();
        var currentYear = currentTime.getFullYear();
        console.log('current year value', currentYear);
        //this.claimYearValue = currentYear;

        coverageTypes({
                recordIdValue: this.recordId
            })
            .then(result => {
                var conts = result;
                let coverageList = [];
                let coverageIdList = [];
                for (var key in conts) {
                    let temp = {};
                    temp.label = key;
                    temp.value = conts[key];
                    coverageList.push(temp);
                    coverageIdList.push(conts[key]);
                }

                var fields = {};
                fields = Object.keys(conts).map(key => ({
                    key: conts[key],
                    value: key
                }));

                this.selectedCoveragesMap = fields;
                this.coverageOptions = coverageList;
                this.coverageScreen = true;
                this.coverageIdList = coverageIdList;
            })
            .catch(error => {
                this.resultsum = undefined;
            });

        //get claim terms
        claimTerms()
            .then(result => {
                let claimTermList = [];

                for (var i = 0; i < result.length; i++) {

                    let temp = {};
                    temp.label = result[i];
                    temp.value = result[i];
                    claimTermList.push(temp);
                }
                this.claimTermOptions = claimTermList;
            })

        //get claim types
        claimTypes()
            .then(result => {
                let claimTypeList = [];
                for (var i = 0; i < result.length; i++) {
                    let temp = {};
                    temp.label = result[i];
                    temp.value = result[i];
                    claimTypeList.push(temp);
                }
                this.claimTypeOptions = claimTypeList;
            })

        //get Payment Methodology
        paymentMethodology()
        .then(result => {
            var conts = result;
            let paymentMethod = [];
            for (var key in conts) {
                let temp = {};
                temp.label = key;
                temp.value = conts[key];
                paymentMethod.push(temp);
            }
            this.paymentOptions = paymentMethod;
        })

        //get claim years
        claimYears()
            .then(result => {

                let claimYearList = [];
                for (var i = 0; i < result.length; i++) {

                    let temp = {};
                    temp.label = result[i];
                    temp.value = result[i];
                    claimYearList.push(temp);
                }
                this.claimYearOptions = claimYearList;
            })
    }

    handleFileUploaded(event) {
        if (event.target.files.length > 0) {
            let files = [];
            for (var i = 0; i < event.target.files.length; i++) {
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    this.filesUploaded.push({
                        PathOnClient: file.name,
                        Title: file.name,
                        VersionData: fileContents
                    });
                };
                reader.readAsDataURL(file);
            }
        }
    }

    handleChangeSelectedCoverages(event) {
        this.selectedCoverages = event.detail.value;
        this.selectedCoveragesValues = event.detail.value;
/*
        var conts = event.detail.value;

        var fields = {};

        fields = Object.keys(conts).map(key => ({
            key: key,
            value: conts[key]
        }));

        let selectedCoverageList = [];

        for (var key in fields) {
            selectedCoverageList.push(conts[key]);

        }


        var tempMap = this.selectedCoveragesMap;

        for(var key in tempMap){
               console.log('key',key);
               console.log('value',tempMap[key]);
        }

        
*/
        /*var str = JSON.stringify(this.selectedCoverages);
        var strNew = str.replace("]",str.replace("[",""));
        console.log('in before handle');
        console.log('Selected Values are',str);
        console.log('Selected Values are',strNew);
        console.log('in after handle');*/
        this.SelOptionsLabels = [];
        console.log('this.coverageOptions.length > '+this.coverageOptions.length);
        console.log('this.coverageOptions > '+JSON.stringify(this.coverageOptions));
        console.log('this.selectedCoverages > '+JSON.stringify(this.selectedCoverages));
        for (let i = 0; i < this.coverageOptions.length; i++) {
            if(this.selectedCoverages.includes(this.coverageOptions[i].value)){
                this.SelOptionsLabels.push(this.coverageOptions[i].label);
            }
        }
        


        if (event.detail.value.length > 0) {
            this.coveragesNotSelected = false;
        }

    }

    editClaim(event) {
        this.confirmationScreen = false;
        this.coverageScreen = true;
    }

    handlePolicyScreenNext(event) {
        console.log('OptiONs >> '+ JSON.stringify(this.selectedCoveragesValues));
        console.log('OptiONs  coverageOptions >> '+ JSON.stringify(this.coverageOptions));
        console.log('OptiONs  SelOptionsLabels >> '+ JSON.stringify(this.SelOptionsLabels));
        this.coverageScreen = false;
        this.newPolicyScreen = true;
    }




    goToCoverageScreen() {
        this.newPolicyScreen = false;
        this.coverageScreen = true;
    }

    /* handleUploadFinished(event) {

         const uploadedFiles = event.detail.files;
         alert('uploadfiles',uploadedFiles);
         var uploadedFileNamesTemp = '';
         var documentidSet = '';

         for (let i = 0; i < uploadedFiles.length; i++) {
             uploadedFileNamesTemp += uploadedFiles[i].name + ', ';
             documentidSet += uploadedFiles[i].documentId + ', ';
         }

         alert("No. of files uploaded : " + uploadedFiles.length);
         alert("Uploaded files" + uploadedFileNamesTemp);
         alert("content document ids" + documentidSet);
         this.fileName = uploadedFileNamesTemp;
     }*/

    goToFileUploadScreen(event) {
        this.newPolicyScreen = false;
        this.documentScreen = true;
    }

    handleChangeClaimTermOptions(event) {
        this.termValue = event.detail.value;
    }

    handleChangeClaimTypeOptions(event) {
        this.claimTypeValue = event.detail.value;
    }

    handleChangeClaimYearOptions(event) {
        this.claimYearValue = event.detail.value;
    }

    handleSelectChange(event) {
        this.selectedCollege = event.detail.recordId;
        this.recordValue = event.detail.fieldValue;
        console.log('change', this.selectedCollege);
    }

    handleRequestedAmountValueChange(event) {
        this.requestedAmountValue = event.detail.value;

    }

    goBackToClaimPage() {
        this.documentScreen = false;
        this.newPolicyScreen = true;
    }




    handleRequestedUnitValueChange(event) {
        this.requestedUnitsValue = event.detail.value;
        console.log('requested unit value', this.requestedUnitsValue);
    }

    handlepaymentOptions(event) {
        this.paymentValue = event.detail.value;
    }

    

    CreateClaim() {
        this.confirmationScreen = false;
        this.isLoading = true;
        console.log('selectedCollege', this.selectedCollege);
        console.log('termValue', this.termValue);
        console.log('yearValue', this.claimYearValue);
        console.log('claimTypeValue', this.claimTypeValue);
        console.log('requestedUnitValue', this.requestedUnitsValue);
        console.log('coveragePlanId', this.selectedCoverages);

        createClaim({
                schoolId: this.selectedCollege,
                termValue: this.termValue,
                yearValue: this.claimYearValue,
                claimTypeValue: this.claimTypeValue,
                requestedUnitValue: this.requestedUnitsValue,
                coveragePlanId: this.coverageIdList,
                files: this.filesUploaded,
                requestedAmountValue: this.requestedAmountValue,
                policyId: this.recordId,
                isSchoolInvoice: false,
                paymentMethodUpdated: false

            })
            .then(result => {
                var conts = result;
                this.claimId = result;
                console.log('claimId Id >> ' + result);
                const event = new ShowToastEvent({
                    title: 'Claim Created',
                    message: 'Redirecting to claim record Page.',
                    variant: 'success',
                });
                this.dispatchEvent(event);
                this.newPolicyScreen = false;
                this.navigateToViewPolicy();
            })
            .catch(error => {

            });
    }

    navigateToViewPolicy() {
        console.log('navigateToViewPolicy Called');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.claimId,
                objectApiName: 'Claim',
                actionName: 'view'
            }
        });
    }

    goToconfirmationScreen() {
        this.documentScreen = false;
        this.confirmationScreen = true;
    }









}