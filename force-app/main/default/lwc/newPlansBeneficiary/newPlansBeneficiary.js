import { LightningElement, api, track, wire} from 'lwc';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages'
import { getRecord } from 'lightning/uiRecordApi';
import getProductsByPEY from '@salesforce/apex/EpProductController.getProductsByPEY';

const contractFields = [
    'Contract.AccountId',
    'Contract.SP_Frequency__c',
    'Contract.Beneficiary_Account__c',
    'Contract.X529_Savings_Plan__c',
    'Contract.Initial_Contribution__c',
    'Contract.PP_Selected_Plans__c'
];
const accountFields = ['Account.Name'];
export default class NewPlansBeneficiary extends LightningElement {
    imageFpo90 =  My_Resource + '/img/img-fpo-alt-90px.png';
    
    @api contractId;
    contract;
    beneficiaryAccoutId;
    beneficiaryAccountName;
    SP_Frequency__c;
    X529_Savings_Plan__c;
    applicationProcessingFee=50.00;
    Initial_Contribution__c; 
    firstPaymentAmount;
    productList = [];
    productIdList = [];
    displaySavingsPlanInfo = false;


    @wire(getRecord, { recordId: '$contractId', fields: contractFields })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.contract = data;
            this.beneficiaryAccoutId = this.contract.fields.Beneficiary_Account__c.value;
            this.SP_Frequency__c = this.contract.fields.SP_Frequency__c.value;
            this.X529_Savings_Plan__c = this.contract.fields.X529_Savings_Plan__c.value;
            this.Initial_Contribution__c = this.contract.fields.Initial_Contribution__c.value;
           
            if(this.X529_Savings_Plan_c){
            
                displaySavingsPlanInfo = true;
                this.firstPaymentAmount = parseFloat(this.Initial_Contribution__c)+parseFloat(this.applicationProcessingFee);

            
            }
            this.firstPaymentAmount = parseFloat(this.applicationProcessingFee);          

            this.prepaidPlansSelectedInfoList = JSON.parse(this.contract.fields.PP_Selected_Plans__c.value);
            for (var i = 0; i < this.prepaidPlansSelectedInfoList.length; i++) {

                this.productIdList.push(this.prepaidPlansSelectedInfoList[i].id);                    
                                
              }  

              var prepaidTotal = 0;
              
              getProductsByPEY({pey:null, prepaidPricebookIds: this.productIdList}).then(data =>{
                this.productList = data;
                for (var i = 0; i < this.productList.length; i++) {

                    prepaidTotal = parseFloat(prepaidTotal) + parseFloat(this.productList[i].lumpSumPrice);
                                    
                  }
                this.firstPaymentAmount = parseFloat(this.firstPaymentAmount) + prepaidTotal;
                console.log( JSON.stringify( this.firstPaymentAmount ) );
           }).catch(error =>{	
           });


        }
    }

    @wire(getRecord, {
        recordId:'$beneficiaryAccoutId',
        fields: accountFields
    }) wireContact({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            console.log( JSON.stringify( data.fields ) );
            this.beneficiaryAccountName = data.fields.Name.value;
            
          }
    }

}