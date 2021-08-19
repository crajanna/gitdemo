import { LightningElement, track, wire, api } from 'lwc';
import {getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import {  ShowToastEvent } from 'lightning/platformShowToastEvent';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import { NavigationMixin } from 'lightning/navigation';
import CONTRACT_ID from '@salesforce/schema/Contract.Id';
import ENROLLMENT_STATUS_C from '@salesforce/schema/Contract.Enrollment_Status__c';
import PDPA_AGREEMENT from '@salesforce/schema/Contract.PDPA_Agreement__c';
import CONTRACT_STATUS from '@salesforce/schema/Contract.Status';
import CONTRACT_START_DATE from '@salesforce/schema/Contract.StartDate';
import CONTRACT_TERM_MONTHS from '@salesforce/schema/Contract.ContractTerm';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';
import saveAllocations from "@salesforce/apex/FundAllocationController.saveAllocations";
import FIN_ACC_OBJECT from '@salesforce/schema/FinServ__FinancialAccount__c';
import FIN_ACC_PRIMARY_OWNER from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c';
import FIN_ACC_OWNERSHIP from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__Ownership__c';
import FIN_ACC_NAME from '@salesforce/schema/FinServ__FinancialAccount__c.Name';
import FIN_ACC_APPLICATION_DATE from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__ApplicationDate__c';
import FIN_ACC_STATUS from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__Status__c';
import FIN_ACC_ACCOUNTTYPE from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c';
import FIN_ACC_NICKNAME from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__Nickname__c';
import FIN_ACC_OPEN_DATE from '@salesforce/schema/FinServ__FinancialAccount__c.Open_Date__c';
import FIN_ACC_RECORD_TYPE_ID from '@salesforce/schema/FinServ__FinancialAccount__c.RecordTypeId';
import FIN_ACC_INIT_CONTR from  '@salesforce/schema/FinServ__FinancialAccount__c.Plan_Initial_Contribution__c';
import FIN_ACC_RECURRING_CONTR from  '@salesforce/schema/FinServ__FinancialAccount__c.Schedule_Recurring_Contribution__c';
import FIN_ACC_SCH_REC_PLAN_AMOUNT from  '@salesforce/schema/FinServ__FinancialAccount__c.Schedule_Recurring_Plan_Amount__c';
import FIN_ACC_PLAN_PAYMENT_FREQ from  '@salesforce/schema/FinServ__FinancialAccount__c.Plan_Payment_Frequency__c';

import FIN_ACC_ROLE_OBJECT from '@salesforce/schema/FinServ__FinancialAccountRole__c';
import FIN_ACC_ROLE_FIN_ACT_OBJECT from '@salesforce/schema/FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c';
import FIN_ACC_ROLE_ROLE from '@salesforce/schema/FinServ__FinancialAccountRole__c.FinServ__Role__c';
import FIN_ACC_ROLE_BEN_REL from '@salesforce/schema/FinServ__FinancialAccountRole__c.Beneficiary_Relationship__c';
import FIN_ACC_ROLE_RELATEDACCOUNT from '@salesforce/schema/FinServ__FinancialAccountRole__c.FinServ__RelatedAccount__c';
import FIN_ACC_ROLE_STARTDATE from '@salesforce/schema/FinServ__FinancialAccountRole__c.FinServ__StartDate__c';
import FIN_ACC_ROLE_ACTIVE from '@salesforce/schema/FinServ__FinancialAccountRole__c.FinServ__Active__c';
import createPrepaidPolicy from '@salesforce/apex/EpProductController.createPrepaidPolicy';
import createPolicy from '@salesforce/apex/PrepaidPolicyController.createPolicy';


const FIN_ACCOUNT_FIELDS = [
    'FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c',
    'FinServ__FinancialAccount__c.FinServ__Ownership__c',
    'FinServ__FinancialAccount__c.Name',
    'FinServ__Financial Account__c.FinServ__ApplicationDate__c',
    'FinServ__FinancialAccount__c.FinServ__Status__c',
    'FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c',
    'FinServ__FinancialAccount__c.FinServ__Nickname__c',
    'FinServ__FinancialAccount__c.Open_Date__c'
];

const contractFields = [
    'Contract.AccountId',
    'Contract.SP_Selected_Portfolios__c',
    'Contract.Initial_Contribution__c',
    'Contract.SP_Schedule_Recurring_Contribution__c',
    'Contract.SP_Amount__c',
    'Contract.SP_Frequency__c',
    'Contract.Beneficiary_Account__c',
    'Contract.PP_Selected_Plans__c',
    'Contract.Beneficiary_Birthdate__c'
];

export default class AgreementFpp extends NavigationMixin(LightningElement) {

    imageFpo90 =  My_Resource + '/img/img-fpo-alt-90px.png';
    
    // @api contractId = '800P0000000XWzuIAG';
     @api contractId;

    isLoading = false;
    isPdpaSelected;
    beneficiaryBirthDate;
    age;
    pey;

    savingsPlan529finAccountId;

    isSavingsPlanSelected = false;
    isPrepaidPlanSelected = true;

    @wire(getRecordTypeId, { objectName: 'FinServ__FinancialAccount__c',  strRecordTypeName: 'InvestmentAccount' })
    investmentAccountRecordtypeID;

    @wire(getRecord, { recordId: '$contractId', fields: contractFields })
    contract;

    handlePdpaSelection(event){
        window.console.log("this.isPdpaSelected.." + event.target.checked);
        window.console.log("agreement selection contractId..."+this.contractId);
        this.isPdpaSelected = event.target.checked;
      }


    handleAgreementFinishAction(){
        this.isLoading = true;
        window.console.log("this.isPdpaSelected.." + this.isPdpaSelected);
        window.console.log("agreement selection contractId..."+this.contractId);
       // this.createPrepaidPlans();
        this.updateContract();
       // this.create529SavingsPlanAccount();        

    }


    createPrepaidPlans(){

        this.prepaidPlansSelectedInfoList = JSON.parse(this.contract.data.fields.PP_Selected_Plans__c.value);
        // this.beneficiaryBirthDate = this.contract.data.fields.Beneficiary_Birthdate__c.value;

        // this.age = this.getAge(this.beneficiaryBirthDate);
        // this.getPEY();
        
        for (var i = 0; i < this.prepaidPlansSelectedInfoList.length; i++) {

            console.log('this.prepaidPlansSelectedInfoList[i].id: ' + this.prepaidPlansSelectedInfoList[i].id);
            console.log('this.prepaidPlansSelectedInfoList[i].productId: ' + this.prepaidPlansSelectedInfoList[i].productId);
            console.log('this.prepaidPlansSelectedInfoList[i].productFamily: ' + this.prepaidPlansSelectedInfoList[i].productFamily);
            console.log('this.contract.data.fields.Beneficiary_Account__c.value: ' + this.contract.data.fields.Beneficiary_Account__c.value);

            var policyData = {
                "numberofPolicy":1,
                "accId": this.contract.data.fields.AccountId.value,
                "pey": 2038,
                "contractYear" : 2021,
                "numberOfPayments" : 1,
                "productId" : this.prepaidPlansSelectedInfoList[i].productId,
                "family" : this.prepaidPlansSelectedInfoList[i].productFamily,
                "policyPurchaseType": 'Individual',
                "PricebkSubType": 'TypeA',
                "beneficiaryId" : this.contract.data.fields.Beneficiary_Account__c.value
              }


              createPolicy({
                strPolicyData : JSON.stringify(policyData),
                coveragesPlans : null
                })
            .then(result => {
                    console.log('Policy Id >> ' + JSON.stringify(result));
                    this.isLoading = false;
                    this.goToNextPage(); 
                    const evt1 = new ShowToastEvent({
                    title: 'Policies Created',
                    message: 'success',
                    variant: 'success'
                });
                this.dispatchEvent(evt1);
            
            })
            .catch(error => {
                console.log('error: ' + JSON.stringify(error));
                this.isLoading = false;
               const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'error while processing request',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                
            });

          }  
    }

    create529SavingsPlanAccount(){
        window.console.log('create529SavingsPlanAccount:AccountId.value ===> ' + this.contract.data.fields.AccountId.value);
        window.console.log('this.investmentAccountRecordtypeID ===> ' + this.investmentAccountRecordtypeID.data);
        window.console.log('new date ===> ' + new Date().toISOString().split('T')[0]);
        const fields = {};
        fields[FIN_ACC_RECORD_TYPE_ID.fieldApiName] = this.investmentAccountRecordtypeID.data;        
        fields[FIN_ACC_PRIMARY_OWNER.fieldApiName] = this.contract.data.fields.AccountId.value;
        fields[FIN_ACC_OWNERSHIP.fieldApiName] = 'Individual';
        fields[FIN_ACC_NAME.fieldApiName] = 'Florida 529 Savings Plan';
        fields[FIN_ACC_APPLICATION_DATE.fieldApiName] = new Date().toISOString().split('T')[0];
        fields[FIN_ACC_STATUS.fieldApiName] = 'Active';
        fields[FIN_ACC_ACCOUNTTYPE.fieldApiName] = 'Regular';
        fields[FIN_ACC_NICKNAME.fieldApiName] = 'Florida 529 Savings Plan';
        fields[FIN_ACC_OPEN_DATE.fieldApiName] = new Date().toISOString().split('T')[0];
        fields[FIN_ACC_INIT_CONTR.fieldApiName] = this.contract.data.fields.Initial_Contribution__c.value;
        fields[FIN_ACC_RECURRING_CONTR.fieldApiName] = this.contract.data.fields.SP_Schedule_Recurring_Contribution__c.value;
        fields[FIN_ACC_SCH_REC_PLAN_AMOUNT.fieldApiName] = this.contract.data.fields.SP_Amount__c.value;
        fields[FIN_ACC_PLAN_PAYMENT_FREQ.fieldApiName] = this.contract.data.fields.SP_Frequency__c.value;


        const recordInput = { apiName: FIN_ACC_OBJECT.objectApiName, fields };

        createRecord(recordInput)
        .then(finAccount => {
           window.console.log('fin account ===> ' + JSON.stringify(finAccount));
           window.console.log('finAccount.Id ===> ' + finAccount.id);
           this.savingsPlan529finAccountId = finAccount.id;  
           this.saveAllocations();                   
          })
        .catch(error => {
           window.console.log('error---' + JSON.stringify(error.body) )
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    saveAllocations(){
        window.console.log('saveAllocations-allocations ===> ' + this.contract.data.fields.SP_Selected_Portfolios__c.value);
        window.console.log('saveAllocations-savingsPlan529finAccountId ===> ' + this.savingsPlan529finAccountId);
        saveAllocations({'allocations': this.contract.data.fields.SP_Selected_Portfolios__c.value, 'accountId': this.savingsPlan529finAccountId})
        .then(result => {
            if(result){                
                window.console.log('saveAllocations-allocations result ===> ' + result);
                this.createFinancialRoleBeneficiary();           
            } else
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error saving allocations, please contact administrator.',
                        variant: 'error'
                    })
                );

        })
        .catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        });
    }

     createFinancialRoleBeneficiary(){
        const fields = {};
        fields[FIN_ACC_ROLE_FIN_ACT_OBJECT.fieldApiName] = this.savingsPlan529finAccountId;
        fields[FIN_ACC_ROLE_ROLE.fieldApiName] = 'Beneficiary';        
        fields[FIN_ACC_ROLE_RELATEDACCOUNT.fieldApiName] = this.contract.data.fields.Beneficiary_Account__c.value;
        fields[FIN_ACC_ROLE_STARTDATE.fieldApiName] = new Date().toISOString().split('T')[0];
        fields[FIN_ACC_ROLE_ACTIVE.fieldApiName] = true;
        fields[FIN_ACC_ROLE_BEN_REL.fieldApiName] = "Original beneficiary";
        const recordInput = { apiName: FIN_ACC_ROLE_OBJECT.objectApiName, fields };

        createRecord(recordInput)
        .then(finRoleAccount => {
           window.console.log('fin account role ===> ' + JSON.stringify(finRoleAccount));
           window.console.log('finRoleAccount.Id ===> ' + finRoleAccount.id);
           this.updateContract();
          })
        .catch(error => {
           window.console.log('error---' + JSON.stringify(error.body) )
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
     }

    updateContract(){
       // this.contractId = '800P0000000ffU3IAI';
        window.console.log( 'inside ReviewSelectionFpp updateContract ===> '+this.contractId);      
        const fields = {};
        fields[CONTRACT_ID.fieldApiName] = this.contractId;
        fields[ENROLLMENT_STATUS_C.fieldApiName] = "Agreement";
        fields[PDPA_AGREEMENT.fieldApiName] = this.isPdpaSelected;
        fields[CONTRACT_STATUS.fieldApiName] = "In Approval Process";
        fields[CONTRACT_START_DATE.fieldApiName] = new Date().toISOString().split('T')[0];
        fields[CONTRACT_TERM_MONTHS.fieldApiName] = 12;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.isLoading = false;
                this.goToNextPage(); 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Agreement updated successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.isLoading = false;
                console.log(JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });   
            this.isLoading = false;      
    }

    goToNextPage(){
        this.isLoading = false;
        const passEvent = new CustomEvent('next', {
            detail:{contractId:this.contractId} 
        }); 
         this.dispatchEvent(passEvent);
    }  

    getAge(date) {
        var d = new Date(date), now = new Date();
        var eofyear = now.getFullYear();
        if(d.getMonth()< now.getMonth()){
          eofyear =  now.getFullYear()-1;
        }
        var eofy = new Date(eofyear+"-08-31");
        var years = eofy.getFullYear() - d.getFullYear();
        d.setFullYear(d.getFullYear() + years);
        if (d > eofy) {
            years--;
            d.setFullYear(d.getFullYear() - 1);
        }
        var days = (eofy.getTime() - d.getTime()) / (3600 * 24 * 1000);
        return Math.floor(years + days / (this.isLeapYear(eofy.getFullYear()) ? 366 : 365));
     }

     getPEY(){
        var d = new Date(this.beneficiaryBirthDate), now = new Date();
        var eofyear = now.getFullYear();
        if(d.getMonth()< now.getMonth()){
          eofyear =  now.getFullYear()-1;
        }
        var eofy = new Date(eofyear+"-08-31");
        var years = eofy.getFullYear() - d.getFullYear();
        d.setFullYear(d.getFullYear() + years);
        if (d > eofy) {
            years--;
            d.setFullYear(d.getFullYear() - 1);
        }
    
          if(this.age== -1){
            return parseFloat(d.getFullYear() )+ parseFloat(PEY_MAX_NUMBER)+1;
          }else if(this.age==0){
            return parseFloat(d.getFullYear() )+ parseFloat(PEY_MAX_NUMBER);
          }else{
            return parseFloat(d.getFullYear() )+ parseFloat(PEY_MAX_NUMBER) - parseFloat(this.age);
          }

     }
    

}