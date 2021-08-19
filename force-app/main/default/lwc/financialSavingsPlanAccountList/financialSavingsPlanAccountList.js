import { LightningElement ,api, wire, track} from 'lwc';
import getSavingsPlanData from '@salesforce/apex/FinancialAccountListController.getSavingsPlanData';
export default class FinancialSavingsPlanAccountList extends LightningElement {

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
            label: 'Beneficiary',
            fieldName: 'beneficiary',
            type: 'text',
            sortable: true
        },
        {
            label: 'Market Value',
            fieldName: 'marketValue',
            type: 'currency',
            sortable: true
        }
    ];
 
    @track error;
    @track savingsPlanList ;

    @wire(getSavingsPlanData, { accId: '$recordId' })
    getSavingsPlanData({ error, data }) {
        console.log('recordId'+this.recordId);  
        var savingsPlanData ;
        let savingsPlans = [];
        if (data) {
            for(let i=0; i<data.length; i++) {
                savingsPlanData = {
                    "financialAccountNo": data[i].FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
                    "financialAccountName": data[i].FinServ__FinancialAccount__r.Name,
                    "primaryOwner": data[i].FinServ__FinancialAccount__r.FinServ__PrimaryOwner__r.Name,
                    "beneficiary":data[i].FinServ__RelatedAccount__r.Name ,
                    "marketValue": data[i].FinServ__FinancialAccount__r.Total_Market_Value__c,
                    "finName" : '/' + data[i].FinServ__FinancialAccount__r.Id
                };   
                savingsPlans.push(savingsPlanData);                             
            }  
            this.savingsPlanList = savingsPlans;
        } else if (error) {
            this.error = error;
        }
     }
}