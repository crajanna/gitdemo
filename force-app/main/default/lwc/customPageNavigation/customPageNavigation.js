import { LightningElement, api} from 'lwc';

import {  ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CustomPageNavigation extends LightningElement {
    @api recordId;


    str1 = ['a','b','c'];
    str2 = ['1','2']; 
    str3 = '';

    // Navigation to standard home page
    navigateToHomePage() {
        console.log('testing started.....');
        console.log('str1 : '+this.str1);
        str3 = [...this.str1, ...this.str2];    
        console.log('str3 : '+this.str3.length);
        //console.log('arry1 : '+this.avingPlanBillingOptions);
        //var str = 'Dan Farm';
        /*this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Organization '+ str +' Created.',
                variant: 'success',
                mode:'sticky'
            })
        );*/


    }


    avingPlanBillingOptions() {
        window.console.log('savingPlanBillingOptions ==> ' );

        return [
            { label: 'Set Up Investment', value: 'Set Up Investment' },
            { label: 'Mail in Payment', value: 'Mail in Payment' },           
        ];
    }

     saving1PlanBillingOptions() {
        window.console.log('saving1PlanBillingOptions ==> ' );

        return [
            { label: 'Set Up Investment1', value: 'Set Up Investment1' },
            { label: 'Mail in Payment1', value: 'Mail in Payment1' },           
        ];
    }



}