import { LightningElement, track,wire,api} from 'lwc';
import fetchPoliciesDetails from '@salesforce/apex/PrepaidBulkPolicyController.fetchPoliciesDetails';
export default class AddPolicyBeneficary extends LightningElement {

    @api recordId;
    records;
    @track data;
    @track columns = [
        {label: 'Name',fieldName: 'Name', type: 'text'},
        {label: 'PEY',fieldName: 'Enrollment__c', type: 'text'},
        {label: 'Policy Premium Amount',fieldName: 'Policy_Premium_Amount__c', type: 'currency'},
        {label: 'Effective Date',fieldName: 'EffectiveDate', type: 'Date/Time'},
        {label: 'Expiration Date',fieldName: 'ExpirationDate', type: 'Date/Time'},   
        {
            label: 'Beneficiary',
            fieldName: 'Beneficiary_Account__c',
            type: 'lookup', 
            typeAttributes: 
            {
                placeholder: 'Choose Account',
                object: 'InsurancePolicy',
                fieldName: 'Beneficiary_Account__c',
                label: 'Account',
                value: { fieldName: 'Beneficiary_Account__c' },
                context: { fieldName: 'Id' },
                variant: 'label-hidden',
                name: 'Account',
                fields: ['Account.Name'],
                target: '_self'
            },
            editable: true,
            cellAttributes: {
            class: { fieldName: 'accountNameClass' }
            }
        },  
    ];

    @wire(fetchPoliciesDetails,{accountId: '$recordId'})
    policyRecords({data, error}) {
        console.log('this record account id: '+ this.recordId);
        console.log('data: ' + JSON.stringify(data));
        console.log('error: ' + JSON.stringify(error));
         if (data) {
            // this.data = JSON.parse(JSON.stringify(data));
            this.records = JSON.parse(JSON.stringify(data));
           
           this.records.forEach(record => {
                record.linkName = '/' + record.Id;
                record.accountNameClass = 'slds-cell-edit';
            });
            
            this.error = undefined;
              //  this.data = data;
        } else if (error) {
            this.records = undefined;
            this.data = undefined;
        }
     }
}