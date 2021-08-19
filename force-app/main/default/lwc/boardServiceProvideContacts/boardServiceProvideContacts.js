import { LightningElement } from 'lwc';
import getContactsList from '@salesforce/apex/BoardScheduleController.getContactsList';

export default class BoardServiceProvideContacts extends LightningElement {

    accountId;
    contactsData;
    displayData = false;
    dataSize = 0;

    renderedCallback() {

        var strArry = window.location.href.split('/detail/');
        this.accountId = strArry[1];
        console.log('accountId : ' + this.accountId);

        this.accountId.start
        getContactsList({ accountId: this.accountId })
            .then(result => {
                var data = result;
                console.log('the data is', data);
                if (data.length > 0) {
                    this.dataSize = data.length;
                    console.log('length => '+this.dataSize);
                    this.contactsData = result;
                    this.displayData = true;
                    console.log(this.displayData);
                }else{
                    this.displayData = false;
                    console.log(this.displayData);
                    console.log('0 => '+length);
                }

                    
                    
                    
                })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }
}