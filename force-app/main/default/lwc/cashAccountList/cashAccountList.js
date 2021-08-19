import { LightningElement ,api, wire, track} from 'lwc';
import getCashAccount from '@salesforce/apex/CashAccountListController.getCashAccount';

export default class CashAccountList extends LightningElement {

    @api recordId;
    
    @track columns = [{
            label: 'Financial Account No',
            fieldName: 'financialAccountNo',
            type: 'text',
            sortable: true
        },
        {
            label: 'Financial Account Name',
            fieldName: 'finName',
            type: 'url',
            typeAttributes: {label: { fieldName: 'financialAccountName' }, target: '_blank'}
        },
        {
            label: 'Primary Owner',
            fieldName: 'primaryOwner',
            type: 'text',
            sortable: true
        },
        {
            label: 'Cash Balance',
            fieldName: 'balance',
            type: 'currency',
            sortable: true
        }
    ];
 
    @track error;
    @track cashAccountList ;

    @wire(getCashAccount, { accId: '$recordId' })
    getCashAccount({ error, data }) {
        console.log('recordId'+this.recordId);  
        var cashPlanData ;
        let cashPlans = [];
        if (data) {
            for(let i=0; i<data.length; i++) {
                cashPlanData = {
                    "financialAccountNo": data[i].FinServ__FinancialAccountNumber__c,
                    "financialAccountName": data[i].Name,
                    "primaryOwner": data[i].FinServ__PrimaryOwner__r.Name,
                    "balance": data[i].FinServ__CashBalance__c,
                    "finName" : '/' + data[i].Id
                };   
                cashPlans.push(cashPlanData);                             
            }  
            this.cashAccountList = cashPlans;
        } else if (error) {
            this.error = error;
        }
     }

}