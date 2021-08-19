import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import account_id from '@salesforce/schema/User.AccountId';
import user_id from '@salesforce/user/Id';
//import getDocuments2 from '@salesforce/apex/FpDashboardController.getDocumentsOnRecord';
import getDocuments from '@salesforce/apex/FpDashboardController.getDocumentsOnRecord';


export default class fpDashboardMyDocuments extends LightningElement {

    categories = ['Invoice','Receipt'];
    @track receipts = [];
    @track invoices = [];
    showSpinner = true;


    @wire(getRecord, { recordId: user_id, fields: [account_id] })
    user(data, error) {
        if (data) {
            var result = data;
            if (result.data && result.data.fields && result.data.fields.AccountId) {
                this.currentAccountId = result.data.fields ? result.data.fields.AccountId.value : null;

                //getDocuments({recordId: '$currentAccountId', lstCategory: '$categories'})
                getDocuments({recordId: this.currentAccountId, lstCategory: null})
                .then((result) => {

                    //apply datetime sort
                    result = result.sort(function (a, b) {
                        if(a.docModifiedDate < b.docModifiedDate){
                            return 1;
                        } else {
                            return -1;
                        }
                    });
                
                    result.forEach(element => {
                        var date = new Date(element.docModifiedDate);
                        var updatedDate = ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) + '/' + ((date.getDate() > 9) ? date.getDate() : ('0' + date.getDate())) + '/' + date.getFullYear();

                        let doc = {
                            id : element.docId,
                            filename : element.docTitle,
                            lastUpdated : updatedDate,
                            displayUrl : element.publicUrl,
                            downloadUrl : element.downloadUrl
                        }
        
                        if(element.docTitle.includes('Receipt')){
                            this.receipts.push(doc);
                        }
                        else if (element.docTitle.includes('Invoice')) {
                            this.invoices.push(doc);
                        }
                    });
                    this.showSpinner = false;
                    //this.handleSuccess();
                })
                .catch((error) => {
                    this.showSpinner = false;
                    //this.handleNav();
                })
            }
        } else {
            this.showSpinner = false;
        }
    }

    // sort by value
    // items.sort(function (a, b) {
    //     return a.value - b.value;
    // });

}