import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class NewOpportunityLwc extends NavigationMixin(LightningElement) {

    @track selectedRecord;
    @track pageNumber = 1;
    @track value = 'New Beneficiary';
    get isExiting() {
        return this.value === 'Existing Beneficiary' ? true : false;
    }
    get page1() {
        return this.pageNumber === 1 ? true : false;
    }
    get page2() {
        return this.pageNumber === 2 ? true : false;
    }
    get options() {
        return [{
            label: 'New Beneficiary',
            value: 'New Beneficiary'
        }, {
            label: 'Existing Beneficiary',
            value: 'Existing Beneficiary'
        }];
    }
    @api recordId;
    @track recid;
    url = window.location.href;

    renderedCallback() {
        var res = this.url.split("/");
        var accId;
        res.forEach(function (number) {
            if (number.startsWith("001")) {
                accId = number;
            }
        });
        this.recid = accId;
    }


    handleOnChange(event) {
        this.value = event.target.value;
    }
    handlePage1Next(event) {

        // alert(accId);
        var closeDate;
        var d = new Date();
//d.setDate(d.getDate() + 150);
        var day = d.getDate();
        var month = d.getMonth() + 1;
        var year = d.getFullYear();

        var Date1 = year+"-04-30";
        var Date2 = (year+1)+"-04-30";
        console.log('Date1 >> '+Date1);
        console.log('Date2 >> '+Date2);
        if (month < 4) {
            closeDate = Date1;
        } else if (month === 4) {
            if (day < 30) {
                closeDate = Date1;
            } else {
                closeDate = Date2;
            }
        } else {
            closeDate = Date2;
        }



        if (this.value == 'Existing Beneficiary') {
            if (this.selectedRecord != null && this.selectedRecord.record != null) {
                // this.pageNumber = 2;


                let defaultValues = "Name=" + this.selectedRecord.record.FirstName + ",AccountId=" + this.recid + ",StageName= Qualification,Beneficiary_Last_Name__c=" + this.selectedRecord.record.LastName + ",Beneficiary_Id__c=" + this.selectedRecord.record.PersonContactId + ",CloseDate="+closeDate;
                if (this.selectedRecord.record.PersonBirthdate != null) {
                    defaultValues += ",Beneficiary_DOB__c=" + this.selectedRecord.record.PersonBirthdate;
                }
                console.log('defaultValues >> ' + defaultValues);
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Opportunity',
                        actionName: 'new',
                    },
                    state: {
                        nooverride: '1',
                        defaultFieldValues: defaultValues
                    }
                });
            } else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Select Existing Beneficiary Account',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
        } else {
            // this.pageNumber = 2;
            let defaultValues = "AccountId=" + this.recid + ",StageName= Qualification,CloseDate="+closeDate ;
            let temp = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Opportunity',
                    actionName: 'new'
                },
                state: {
                    nooverride: '1',
                    defaultFieldValues: defaultValues
                }
            };
            this[NavigationMixin.Navigate](temp);
        }

    }
    hanldeSelectedrec(event) {
        this.selectedRecord = event.detail;
        console.log('Selected Account >> ' + JSON.stringify(this.selectedRecord));
    }
}