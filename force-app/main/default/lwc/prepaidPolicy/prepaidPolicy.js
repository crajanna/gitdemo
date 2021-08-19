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
import productList from '@salesforce/apex/policyProcessApex.productList';
import prepaidPlans from '@salesforce/apex/PrepaidPolicyController.prepaidPlans';
import getBeneficiaries from '@salesforce/apex/PrepaidPolicyController.getBeneficiaries';
import policyCoverages from '@salesforce/apex/PrepaidPolicyController.getProductCoverages';
import createPolicy from '@salesforce/apex/PrepaidPolicyController.createPolicy';
import PAYMENT_METHODOLOGY from '@salesforce/schema/InsurancePolicy.Payment_Methodology__c';
import PRODUCT2_OBJECT from '@salesforce/schema/Product2';
import POLICY_PURCHASE_TYPE from '@salesforce/schema/InsurancePolicy.Policy_Purchase_Type__c';
import Contract_Year__c from '@salesforce/schema/Product2.Contract_Year__c';
import PRICEBOOK_OBJECT from '@salesforce/schema/Prepaid_Pricebook_Entry__c';
import PEY from '@salesforce/schema/Prepaid_Pricebook_Entry__c.PEY__c';
import SUB_TYPES from '@salesforce/schema/Prepaid_Pricebook_Entry__c.Sub_Type__c';




import {
    NavigationMixin
} from 'lightning/navigation';

const PEY_MAX_NUMBER = 19;

export default class PrepaidPolicy extends NavigationMixin(LightningElement) {

    @track error; 
    @track items = [];
    coverageTypes = [];
    beneficiaries = [];
    @track policyValue = '';
    selectedCoveragesValues = [];
    @track contractYearValue ;
    val = 1;
    numberOfPayments = 1;
    //dat = System.today();
    contractYear ;
    @track PEYvalue;
     PEY;
     policyId;
    //contractYear =  2021;
    policyScreen = true;
    policyPurchaseTypeValue = '';
    confirmationScreen = false;
    beneficiaryInfoSection = false;
    productScreen;
    @track paymentmethodValue = 'Calculate Based on Units Requested';
    @api recordId;
    isLoading = false;
    planId;
    coverages = false;
    beneficiaryValue = '';
    beneficiaryBirthDateList = [];
    personBirthDate = '';
    policyLabel;
    beneficiaryLabel;
    productFamilyList = [];
    productFamily = '';
    quantityValue = 1;
    priceListSubTypeValue = '';
    @track policyPurchaseTypeOptions;
    @track priceSubTypesOptions;
    priceSubTypesData;

    

   

    

    @wire(policyCoverages, { planId: '$planId' })
    policyCoverageList({ error, data }) {
        if (data) {
            this.coverageTypes = [];
            this.SelOptionsLabels = [];
            this.selectedCoveragesValues = [];
            for(let i=0; i<data.length; i++) {
                this.coverageTypes = [...this.coverageTypes ,{label: data[i].CoverageType.Name,value: data[i].CoverageType.Id}]; 
                this.selectedCoveragesValues.push(data[i].CoverageType.Id); 
                this.SelOptionsLabels.push(data[i].CoverageType.Name);                                  
            } 
            console.log('selectedCoveragesValues ><><><>' + JSON.stringify(this.SelOptionsLabels));                  
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
     }

     get coverageOptions() {
        return this.coverageTypes;
    }

    @wire(getBeneficiaries, { accId: '$recordId' })
    beneficiariesList({ error, data }) {
        
        if (data) {
            
            for(let i=0; i<data.length; i++) {
                this.beneficiaries = [...this.beneficiaries ,{label: data[i].FinServ__RelatedAccount__r.Name,value: data[i].FinServ__RelatedAccount__c}];  
                this.beneficiaryBirthDateList  = [...this.beneficiaryBirthDateList ,{label: data[i].FinServ__RelatedAccount__r.PersonBirthdate,value: data[i].FinServ__RelatedAccount__c}];                                   
            }                
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
     }

     get beneficiariesOptions() {
        return this.beneficiaries;
    }

    

    @wire(getObjectInfo, { objectApiName: INSURANCE_POLICY_OBJECT })
    insurancePolicyInfo;
    
    @wire(getPicklistValues,
        {
            recordTypeId: '$insurancePolicyInfo.data.defaultRecordTypeId',
            fieldApiName: PAYMENT_METHODOLOGY 
        }
    )
    paymentMethodologyPicklist;

    @wire(getObjectInfo, { objectApiName: PRODUCT2_OBJECT })
    Product2Info;
    
    @wire(getPicklistValues,
        {
            recordTypeId: '$Product2Info.data.defaultRecordTypeId',
            fieldApiName: Contract_Year__c 
        }
    )
    ContractYearPicklist;
   
    @wire(getObjectInfo, { objectApiName: PRICEBOOK_OBJECT })
    PrepaidPricebookEntryInfo;

    @wire(getPicklistValues,
    {
        recordTypeId: '$PrepaidPricebookEntryInfo.data.defaultRecordTypeId',
        fieldApiName: PEY 
    }
    )
    PEYPicklist;
    

    @wire(getPicklistValues, { recordTypeId: '$PrepaidPricebookEntryInfo.data.defaultRecordTypeId', fieldApiName: SUB_TYPES })
    priceSubTypesInfo({ data, error }) {
        if (data) this.priceSubTypesData = data;
    }

    @wire(getPicklistValues, { recordTypeId: '$insurancePolicyInfo.data.defaultRecordTypeId', fieldApiName: POLICY_PURCHASE_TYPE })
    policyPurchaseTypeInfo({ data, error }) {
        if (data) this.policyPurchaseTypeOptions = data.values;
    }


   
    handlePolicyValueChange(event) {
        this.policyValue = event.detail.value;
        this.planId = event.detail.value;
        this.coverages = true;
        this.SelOptionsLabels = [];
        this.selectedCoveragesValues = [];
        for (let i = 0; i < this.productFamilyList.length; i++) {
            if (this.policyValue.includes(this.productFamilyList[i].value)) {
                this.productFamily = this.productFamilyList[i].label;
            }
        }
        this.policyLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    
    handleNoOfPaymentChange(event) {
        this.numberOfPayments = event.detail.value;
    }

    handleNoOfPayments(event) {
        this.numberOfPayments = event.detail.value;
    }

    handlePaymentOptions(event) {
        this.paymentmethodValue = event.detail.value;
    } 

    handlePEYValueChange(event)
    {
        this.PEYvalue = event.detail.value;
    }

    handleQuantityValueChange(event)
    {
        this.quantityValue = event.detail.value;
    }

    handlePolicyPurchaseType(event) {
        this.policyPurchaseTypeValue = event.detail.value;
        let key = this.priceSubTypesData.controllerValues[event.target.value];
        this.priceSubTypesOptions = this.priceSubTypesData.values.filter(opt => opt.validFor.includes(key));
     
    }

  

    handlePriceListSubType(event) {
        this.priceListSubTypeValue = event.detail.value;
    }

    handleContractYearChange(event) {
        this.contractYearValue = event.detail.value;
        if(this.contractYearValue)
        {
            prepaidPlans({ contractyear: this.contractYearValue })
            .then(result => {
                 for(let i=0; i<result.length; i++) {
                    this.items = [...this.items ,{value: result[i].Id , label: result[i].Name}];   
                    this.productFamilyList = [...this.productFamilyList ,{value: result[i].Id , label: result[i].Family}];                                 
                }  
                this.error = undefined;
        
            })
            .catch(error => {
            console.log('error: ' + JSON.stringify(error));
            });
        }
    }

    get policyOptions() {
        return this.items;
    }

    handleBeneficiaryChange(event) {
        this.beneficiaryInfoSection = true;
        this.beneficiaryValue = event.detail.value;
        this.beneficiaryLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        for (let i = 0; i < this.beneficiaryBirthDateList.length; i++) {
            if (this.beneficiaryValue.includes(this.beneficiaryBirthDateList[i].value)) {
                this.personBirthDate = this.beneficiaryBirthDateList[i].label;
            }
        }
        console.log('personBirthDate >> ' + this.personBirthDate);

        var d = new Date(this.personBirthDate), now = new Date();
        var currentYear = now.getFullYear();
        if(d.getMonth()< now.getMonth()){
            currentYear =  now.getFullYear()-1;
        }
        var eofy = new Date(currentYear+"-08-31");
        var years = eofy.getFullYear() - d.getFullYear();
        d.setFullYear(d.getFullYear() + years);
        if (d > eofy) {
            years--;
            d.setFullYear(d.getFullYear() - 1);
        }
        var x = 0;
        if(years== -1){
            this.PEY = parseFloat(d.getFullYear() )+ 20;
          }else if(years==0){
            this.PEY = parseFloat(d.getFullYear() )+ 19;
          }else{
            this.PEY = parseFloat(d.getFullYear() )+ 19 - parseFloat(years);
          }
    }


    handleSelected(event) {
        this.selectedCoveragesValues = event.detail.value;
        console.log(this.selectedCoveragesValues);
        this.SelOptionsLabels = [];
        for (let i = 0; i < this.coverageTypes.length; i++) {
            if (this.selectedCoveragesValues.includes(this.coverageTypes[i].value)) {
                this.SelOptionsLabels.push(this.coverageTypes[i].label);
            }
        }
    }

    handleClickConfrimation(event) {

       
        const allValid = [...this.template.querySelectorAll('lightning-combobox'),...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            this.policyScreen = false;
            this.confirmationScreen = true;
            this.beneficiaryInfoSection = false;
        }else{
            alert('Please enter/select the required fields.');   
        }
    }

    editPolicy(event) {
        this.isLoading = true;
        this.confirmationScreen = false;
        this.beneficiaryInfoSection = true;
        this.policyScreen = true;
        this.isLoading = false;
    }

    createPolicy(event) {
        this.isLoading = true;
        this.confirmationScreen = false;
        
        var policyData = {
            "numberofPolicy":this.quantityValue,
            "accId": this.recordId,
            "pey": this.PEYvalue,
            "contractYear" : this.contractYearValue,
            "numberOfPayments" : this.numberOfPayments,
            "productId" : this.policyValue,
            "family" : this.productFamily,
            "policyPurchaseType": this.policyPurchaseTypeValue,
            "PricebkSubType": this.priceListSubTypeValue,
            "beneficiaryId" : this.beneficiaryValue
          }
          console.log('policyData >> ' + policyData);
          var strPolicyData =   JSON.stringify(policyData);
          console.log('strPolicyData >> ' + strPolicyData);

          createPolicy({
                strPolicyData : strPolicyData,
                coveragesPlans : this.SelOptionsLabels
				})
                .then(result => {
                    var conts = result;
                   // this.policyId = result;
                    console.log('Policy Id >> ' + result);
                    const event = new ShowToastEvent({
                        title: 'Policy(s) Created Successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    this.isLoading = false;
                    this.navigateToView();
    
    
                })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'error while processing request',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                
                this.confirmationScreen = false;
                this.policyScreen = true;
                
            });
            
    }

    navigateToView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }


}