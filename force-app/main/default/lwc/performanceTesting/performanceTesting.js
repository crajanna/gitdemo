import { LightningElement, api, track } from 'lwc';
import getSecurityPerformance from "@salesforce/apex/PerformanceTestingController.getSecurityPerformance";
import getAccountPerformance from "@salesforce/apex/PerformanceTestingController.getAccountPerformance";
import getMonthlyDatesForAccount from "@salesforce/apex/PerformanceTestingController.getMonthlyDatesForAccount";
import getAccountPerformanceMonthly from "@salesforce/apex/PerformanceTestingController.getAccountPerformanceMonthly";

export default class PerformanceTesting extends LightningElement {
    @api recordId = 'a0FP0000007mwVpMAI';

    @track symbolName = '';
    @track secFromDt = '';
    @track secToDt = '';

    @track accFromDt = '';
    @track accToDt = '';
    @track accAsOfDt = '';
    @track accAsOfDtMnth = '';

    @track secResult = '';
    @track accResult = '';
    @track monResult = '';

    options = [];
    get optionsRange() {
        return [
            { label: 'Monthly', value: 'Monthly' },
            { label: 'Quarterly', value: 'Quarterly' },
            { label: 'Yearly', value: 'Yearly' },
        ];
    }

    selectedOption;
    selectedRageOption;

    connectedCallback() {
        this.fetchMonthlyDates();
    }

    fetchMonthlyDates() {
        console.log("************************************" + this.recordId);
        getMonthlyDatesForAccount({'accountId': this.recordId})
            .then(result => {
                if (result) {
                    for (var key in result) {
                        console.log(result[key]);
                        this.options.push( { label: result[key], value: result[key] });
                    }
                }
            })
            .catch(error => {
                console.error("Error in getMonthlyDatesForAccount" , error);
            });
            console.log("************************************" + this.options);
    }

    handleSelectionChange(event) {
        this.selectedOption = event.detail.value;
    }
    handleSelectionRangeChange(event) {
        this.selectedRageOption = event.detail.value;
    }
    

    updateFieldData(){
        var inputParams=this.template.querySelectorAll("lightning-input");
        inputParams.forEach(function(element){
            var field = element.name;
            if(field == 'symbolName') this.symbolName = element.value;
            if(field == 'secFromDt') this.secFromDt = element.value;
            if(field == 'secToDt') this.secToDt = element.value;
            if(field == 'accAsOfDt') this.accAsOfDt = element.value;
            if(field == 'accFromDt') this.accFromDt = element.value;
            if(field == 'accToDt') this.accToDt = element.value;
        },this);
    }


    handleSecuritiesPerformance(event) {
        this.updateFieldData();
        getSecurityPerformance({'secName': this.symbolName, 'fromDate': this.secFromDt, 'toDate':this.secToDt})
            .then(result => {
                if (result) {
                    console.log(result);
                    let details = '';
                    for (var key in result) {
                        if (result.hasOwnProperty(key)) {
                            //console.log(key + " -> " + p[key]);
                            details += key + ' : ' + result[key] + '\n';
                        }
                    }

                    this.secResult=details;
                }
            })
            .catch(error => {
                console.error("Error in handleSecuritiesPerformance" , error);
            });
    }

    handleAccountPerformance(event) {
        this.updateFieldData();
        getAccountPerformance({'accountId': this.recordId, 'fromDate': this.accFromDt, 'toDate': this.accToDt })
            .then(result => {
                if (result) {
                    console.log(result);
                    let details = '';
                    for (var key in result) {
                        if (result.hasOwnProperty(key)) {
                            //console.log(key + " -> " + p[key]);
                            details += key + ' : ' + result[key] + '\n';
                        }
                    }

                    this.accResult=details;
                }
            })
            .catch(error => {
                console.error("Error in handleAccountPerformance" , error);
            });
    }


    handleAccountOnMBPerformance(event) {
        getAccountPerformanceMonthly({'accountId': this.recordId, 'accAsOfDt': this.selectedOption, 'rangeType' : this.selectedRageOption})
            .then(result => {
                if (result) {
                    console.log(result);
                    let details = '';
                    for (var key in result) {
                        if (result.hasOwnProperty(key)) {
                            //console.log(key + " -> " + p[key]);
                            details += key + ' : ' + result[key] + '\n';
                        }
                    }

                    this.monResult=details;
                }
            })
            .catch(error => {
                console.error("Error in handleAccountOnMBPerformance" , error);
            });
    }

}