import { LightningElement, wire, api } from 'lwc';
import {NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import getBeneficiaryList from '@salesforce/apex/FinancialAccountController.getBeneficiaryList';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import {getRecord} from 'lightning/uiRecordApi';
import My_Resource from '@salesforce/resourceUrl/ECImages';


export default class EpManageAccount extends NavigationMixin(LightningElement) {

    imagecirclefpo30= My_Resource + '/img/circle-fpo-30px.png';

    userAccountId;
    @api beneficiaryAccountId;

    showManagePayments =false;
    showChangePlans =false;
    showManageAccount = true;

    @wire(getRecord, {
        recordId: Id,
        fields: [ACCOUNT_ID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        } else if (data) {
            this.userAccountId = data.fields.AccountId.value;
        }
    }

    connectedCallback(){
        if(localStorage.getItem('cpBeneficiaryId')){
            this.beneficiaryAccountId = localStorage.getItem('cpBeneficiaryId');
        }
        console.log('this.beneficiaryAccountId....'+this.beneficiaryAccountId);
    }

    manangePayments(event){
        this.showManagePayments = true;
        this.showChangePlans =false;
        this.showManageAccount =false;
    }

    handleChangePlans(event){
        this.showChangePlans =true;
        this.showManagePayments =false;
        this.showManageAccount =false;
    }
}