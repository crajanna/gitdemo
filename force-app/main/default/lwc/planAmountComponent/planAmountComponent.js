import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPlanBalanceByAccountId from '@salesforce/apex/FinancialAccountController.getPlanBalanceByAccountId';

import 'c/cssLibraryFpp';

export default class PlanAmountComponent extends NavigationMixin(LightningElement) {

    @api recordId;
    @api image;
    @api displayText;
    @api planType; 
        amount=0;

    @wire(getPlanBalanceByAccountId, { recordId: '$recordId', planType: '$planType' })
    getPlanBalanceByAccountId({ error, data }) {
        if (error) {
          console.log(error);
        } else if (data) {
           this.amount = data;
        }
    }


    get isPrepaidPlan(){
       return (this.planType=='Prepaid'); 
    }

    get isSavingsPlan(){
        return (this.planType=='Savings'); 
     }
}