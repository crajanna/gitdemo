import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {  ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getRecord, updateRecord } from 'lightning/uiRecordApi';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import CONTRACT_ID from '@salesforce/schema/Contract.Id';
import ENROLLMENT_STATUS_C from '@salesforce/schema/Contract.Enrollment_Status__c';
import getProductsByPEY from '@salesforce/apex/EpProductController.getProductsByPEY';
import getAccountInfo from '@salesforce/apex/AccountController.getAccountInfo';

const contractFields = [
    'Contract.AccountId',
    'Contract.X529_Savings_Plan_Option__c',
    'Contract.Initial_Contribution__c',
    'Contract.SP_Schedule_Recurring_Contribution__c',
    'Contract.SP_Amount__c',
    'Contract.SP_Frequency__c',
    'Contract.Beneficiary_Account__c',
    'Contract.X529_Savings_Plan__c',
    'Contract.PP_Selected_Plans__c'
];
const accountFields = ['Account.Name'];

export default class ReviewSelectionFpp extends LightningElement {

    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imagePathIconHelp = My_Resource + '/img/icon-help.png'; 
    imageFpo90 =  My_Resource + '/img/img-fpo-alt-90px.png';
    imagesymgray= My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';

    @api contractId='800P0000000XWzuIAG';

     contract;
     X529_Savings_Plan_Option__c;
     Initial_Contribution__c;
     SP_Schedule_Recurring_Contribution__c;
     SP_Amount__c;
     SP_Frequency__c;
     beneficiaryAccoutId;
     beneficiaryAccountName;
     firstPaymentAmount=0;
     applicationProcessingFee=50.00;
     prepaidPlansSelectedInfoList =[];
     prepaidPlansSummaryList =[];
     productList = [];
     productIdList = [];

     displaySavingsPlanInfo = false;
    @wire(getRecord, { recordId: '$contractId', fields: contractFields })
    getContractData({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading data',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
                this.firstPaymentAmount = 0;
                this.contract = data;
                window.console.log(JSON.stringify(this.contract));
                this.X529_Savings_Plan__c = this.contract.fields.X529_Savings_Plan__c.value;
                this.X529_Savings_Plan_Option__c = this.contract.fields.X529_Savings_Plan_Option__c.value;


          
                    if(this.X529_Savings_Plan_Option__c =="EXPERT"){
                        this.X529_Savings_Plan_Option__c = "Custom";
                    }else{
                        this.X529_Savings_Plan_Option__c = "Age-Based";
                    }
                    this.Initial_Contribution__c = this.contract.fields.Initial_Contribution__c.value;
                    this.SP_Schedule_Recurring_Contribution__c = this.contract.fields.SP_Schedule_Recurring_Contribution__c.value;
                    this.SP_Amount__c = this.contract.fields.SP_Amount__c.value;
                    this.SP_Frequency__c = this.contract.fields.SP_Frequency__c.value;
                    this.firstPaymentAmount = parseFloat(this.Initial_Contribution__c)+parseFloat(this.applicationProcessingFee);               
    
                    
          
                this.beneficiaryAccoutId = this.contract.fields.Beneficiary_Account__c.value;
                //this.firstPaymentAmount = parseFloat(this.applicationProcessingFee);        
                
                this.prepaidPlansSelectedInfoList = JSON.parse(this.contract.fields.PP_Selected_Plans__c.value);

                for (var i = 0; i < this.prepaidPlansSelectedInfoList.length; i++) {

                    this.productIdList.push(this.prepaidPlansSelectedInfoList[i].id);                    
                                    
                  }  

                  var prepaidTotal = 0;
                  
                  if(this.productList !=null){
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




    handleFinalizeSelection(){

        window.console.log("review selection contractId..."+this.contractId);
        this.updateContract();
        this.goToNextPage()
    }


    updateContract(){
        window.console.log( 'inside ReviewSelectionFpp updateContract ===> ');      
        const fields = {};
        fields[CONTRACT_ID.fieldApiName] = this.contractId;
        fields[ENROLLMENT_STATUS_C.fieldApiName] = "Review Selection";

         const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Profile updated successfully',
                        variant: 'success'
                    })
                );

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });         
    }

    goToNextPage(){
        const passEvent = new CustomEvent('next', {
            detail:{contractId:this.contractId} 
        }); 
         this.dispatchEvent(passEvent);
    }
}