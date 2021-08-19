import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getFinAccTransations from '@salesforce/apex/FinancialAccountController.getFinAccTransations';
import 'c/cssLibraryFpp';

const columns = [
    { label: 'Date', fieldName: 'tdate', type: 'date', wrapText: 'true', sortable: true, editable: false, typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"
    } },
    { label: 'Method', fieldName: 'sourceType',  wrapText: 'true', sortable: true, editable: false },
    { label: 'Amount', fieldName: 'amount',  wrapText: 'true', sortable: true, editable: false, type: 'currency', typeAttributes: { currencyCode: 'USD'} },
    { label: 'Balance', fieldName: 'amount',  wrapText: 'true', sortable: true, editable: false, type: 'currency', typeAttributes: { currencyCode: 'USD'} },
    { label: 'Status', fieldName: 'status',  wrapText: 'true', sortable: true, editable: false }
  
];


export default class FinAccTransactionTable extends NavigationMixin(LightningElement) {

    @api recordId;
    columns = columns;
    records;


    @wire(getFinAccTransations, { financialAccountId: '$recordId' })
    getFinAccTransations({ error, data }) {
        if (data) {
            this.records = data;
        } else if (error) {
            this.finAccTransactionDetail = undefined;
        }
    }

}