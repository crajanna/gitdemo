import { LightningElement, api,track,wire } from 'lwc';
import getPrepaidPolicy from '@salesforce/apex/FinHistoryController.getPrepaidPolicyById';
import {getRecord} from 'lightning/uiRecordApi';
import INSURANCE_POLICY__OBJECT from '@salesforce/schema/InsurancePolicy';
import Id from '@salesforce/schema/InsurancePolicy.Id';
import PremiumAmount from '@salesforce/schema/InsurancePolicy.PremiumAmount';
import GrossWrittenPremium from '@salesforce/schema/InsurancePolicy.GrossWrittenPremium';
import FUTURE_PAYMENTS from '@salesforce/schema/Prepaid_Finance_History__c.Future_Payments__c';

const policyFields = [Id, PremiumAmount, GrossWrittenPremium];

export default class Finhistorylwc extends LightningElement {
    @api recordId;
    @track date1;
    @track date2;
    @track result;
    

    handleSelectChange(event) {
        //this.recordId = event.detail.value;
        alert(this.recordId);
        this.fetchPolicyDetails();
        
    }

    startDateHandler(event) {
        this.date1 = new Date(event.target.value);
    }
    endDateHandler(event) {
        this.date2 = new Date(event.target.value);
        this.result = this.date2.getMonth() - this.date1.getMonth() + (12 * (this.date2.getFullYear() - this.date1.getFullYear()))
        alert(this.result);
        document.getElementById("noOfPayments").value = this.result;
        //alert(this.recordId);
    }





    fetchPolicyDetails() {
        alert(this.recordId);
        getPrepaidPolicy({'policyId': this.recordId})
            .then(result => {
                if (result) {
                    alert(JSON.stringify(result));
                }
            })
            .catch(error => {
                console.error("Error in fetching records" , error);
            });
       
    }

    

    
}