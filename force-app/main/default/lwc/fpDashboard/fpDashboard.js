import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import 'c/fpCssLibrary';
import My_Resource from '@salesforce/resourceUrl/FoundationImages';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';

import ACC_NAME from '@salesforce/schema/Account.Name';
import ACC_WEBSITE from '@salesforce/schema/Account.Website';
import ACC_PHONE from '@salesforce/schema/Account.Phone';
import ACC_EMAIL from '@salesforce/schema/Account.Email__c';

import ACC_BILLING_STREET from '@salesforce/schema/Account.BillingStreet';
import ACC_BILLING_CITY from '@salesforce/schema/Account.BillingCity';
import ACC_BILLING_STATE from '@salesforce/schema/Account.BillingState';
import ACC_BILLING_COUNTRY from '@salesforce/schema/Account.BillingCountry';
import ACC_BILLING_POSTALCODE from '@salesforce/schema/Account.BillingPostalCode';
import ACC_BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';
import ACC_BILLING_COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';

import ACC_SHIPPING_STREET from '@salesforce/schema/Account.ShippingStreet';
import ACC_SHIPPING_CITY from '@salesforce/schema/Account.ShippingCity';
import ACC_SHIPPING_STATE from '@salesforce/schema/Account.ShippingState';
import ACC_SHIPPING_COUNTRY from '@salesforce/schema/Account.ShippingCountry';
import ACC_SHIPPING_POSTALCODE from '@salesforce/schema/Account.ShippingPostalCode';
import ACC_SHIPPING_STATE_CODE from '@salesforce/schema/Account.ShippingStateCode';
import ACC_SHIPPING_COUNTRY_CODE from '@salesforce/schema/Account.ShippingCountryCode';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTaskList from '@salesforce/apex/FpDashboardController.getTaskList';
import getPledgeList from '@salesforce/apex/FPPedgeController.getPledgeList';
import getAgreegatedFundDetails from '@salesforce/apex/FPPedgeController.getAgreegatedFundDetails';
import getAccountId from '@salesforce/apex/CreateFinancialAccount.getAccountId';
import saveSROAccount1 from '@salesforce/apex/CreateFinancialAccount.saveSROAccount1';
import saveCashAccount1 from '@salesforce/apex/CreateFinancialAccount.saveCashAccount1';
import getRecordTypeIdbyName from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import getContract from '@salesforce/apex/FPPedgeController.getContractDetail';

const userFileds = [NAME_FIELD, ACCOUNT_ID];
const accountFileds = [ACC_NAME, ACC_WEBSITE, ACC_PHONE, ACC_EMAIL,
    ACC_BILLING_STREET, ACC_BILLING_CITY, ACC_BILLING_STATE, ACC_BILLING_COUNTRY, ACC_BILLING_POSTALCODE, ACC_BILLING_STATE_CODE, ACC_BILLING_COUNTRY_CODE,
    ACC_SHIPPING_STREET, ACC_SHIPPING_CITY, ACC_SHIPPING_STATE, ACC_SHIPPING_COUNTRY, ACC_SHIPPING_POSTALCODE, ACC_SHIPPING_STATE_CODE, ACC_SHIPPING_COUNTRY_CODE];

const content = [
    { id: 1, tag: 'DID YOU KNOW?', class: 'card-cta bg-student', description: 'The Florida Prepaid College Foundation has helped <b>more than 32,000 students</b> attend college over the last 30 years', buttonText: 'Make Your Pledge Today', buttonUrl: 'pledgewizard', imageUrl: My_Resource + '/img/icon-arrow-right.svg' },
    { id: 2, tag: 'NEW! Path to Prosperity Scholarship Program', class: 'card-cta bg-books', description: 'Together we can make a difference for Florida’s children, one college scholarship at a time.', buttonText: 'More About The Program', buttonUrl: 'https://www.floridaprepaidcollegefoundation.com/scholarships/path-to-prosperity', imageUrl: My_Resource + '/img/icon-arrow-right.svg' },
];


export default class FpDashboard extends NavigationMixin(LightningElement) {
    pledgeIcon = My_Resource + "/img/icon-pledges.svg";
    plusIcon = My_Resource + "/img/icon-plus.svg";
    taskIcon = My_Resource + "/img/icon-tasks.svg";
    checkedIcon = FoundationImages + "/img/icon-checked.svg";
    uncheckedIcon = FoundationImages + "/img/icon-unchecked.svg";
    profileImage = [];
    contentData = content;
    taskList; 
    allTaskList;
    hasRendered = false;
    userId = Id;
    userName;
    accountIduser;
    profileVersionId;
    showLogo = false;
    logo;
    accName;
    accWebsite;
    accPhone;
    accEmail;
    accBillingStreet;
    accBillingCity;
    accBillingState;
    accBillingPostalCode;
    accBillingCountry;
    accBillingStateCode;
    accBillingCountryCode;
    accountData = {};
    showDashMyCompany;
    @api recordId;
    selectedScholarship;
    contractId;
    acctId = '001P000001nnauDIAQ';
    pledgeRecords;
    showAccountEditModal;
    selectProgramId;
    fundDetails;
    aggDonationAmount = 0;
    aggPledgeAmount;
    basePath;
    generalRecordTypeId;
    createCashAccount;
    displayTotalAmount = false;
    contractData;
    wiredAccountResults;
    randomNum;
    pledgeList;

    connectedCallback() {
        this.randomNum = Math.random();
    }

    handleRefresh() {
        console.log('inside handleRefresh');
        this.randomNum = Math.random();
    }

    @wire(getTaskList, { recordId: '$accountIduser', randomNum: '$randomNum' }) taskListData
        ({ error, data }) {
        if (data) {
            let taskList = [];
            data.map(element => {
                let isCompleted = element.Status == 'Completed' ? true : false;
                let sortBy = isCompleted ? "true" : "false"; 
                let icon = isCompleted ? this.checkedIcon : this.uncheckedIcon;
                let eachTask = {
                    Id: element.Id,
                    Subject: element.Subject,
                    description: element.Description,
                    isCompleted: isCompleted,
                    sort: sortBy,
                    icon: icon
                }
                taskList.push(eachTask);
            });
            var taskWithoutDes = taskList.filter(task => !task.description);
            taskList = taskList.filter(val => !taskWithoutDes.includes(val)).concat(taskWithoutDes).sort((a,b) => (a.sortBy < b.sortBy) ? 1 : -1).slice(0,3);
            this.taskList = taskList.sort((a,b) => (a.sortBy > b.sortBy) ? 1 : -1);
            console.log('sort this.taskList:: '+JSON.stringify(this.taskList));
        }
    }

    @wire(getPledgeList, { accountId: '$accountIduser', flag: true, randomNum: '$randomNum' }) //pledgeList;    //@wire(getPledgeList, { accountId: '$accountIduser', flag: true })pledgeList;
    pledges({ data, error }) {
        if (data) {
            let tempData = [];
            
            let pledgeClass = 'card-pledge';
            console.log('getPledge data refreshed...' + JSON.stringify(data));
            let tempList = data; 
            tempList.forEach(element => {
                let eachRec = {};
                    console.log('pledgecolor:: '+this.pledgeColour(element.name));
                    eachRec = {
                        donationAmount: element.donationAmount,
                        id: element.id,
                        imgUrl: element.imgUrl,
                        name: element.name,
                        pledgeAmount: element.pledgeAmount,
                        class: pledgeClass + this.pledgeColour(element.name)
                    }
                tempData.push(eachRec);
            });
            this.pledgeList = tempData;
            console.log('$$$$ after pledgelist = >' + JSON.stringify(this.pledgeList));
            console.log('$$$$ length = >' + this.pledgeList.length);
        } else if (error) {
            this.error = error;
            console.log('Error in getPledgeList : ' + JSON.stringify(error));
        }
    }

    @wire(getAgreegatedFundDetails, { accountId: '$accountIduser', randomNum: '$randomNum' })
    agreegatedFundDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log('data of aggDonationAmount :: '+JSON.stringify(data));
            this.aggDonationAmount = data[0];
            this.aggPledgeAmount = data[1];
            if (this.aggDonationAmount > 0 && this.aggPledgeAmount > 0) {
                this.displayTotalAmount = true;
            } else {
                this.aggDonationAmount = 0.00;
                this.aggPledgeAmount = 0.00;
            }
        }
    }

    @wire(getRecord, { recordId: Id, fields: userFileds }) wireuser1({ error, data }) {
        if (error) {
            this.error = error;
            console.log('getrecord error:' + JSON.stringify(this.error));

        } else if (data) {
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;
        }
    }

    renderedCallback() {
        if (this.hasRendered) {
            return;
        }
        this.hasRendered = true;


        getRecordTypeIdbyName({ objectName: 'FinServ__FinancialAccount__c', strRecordTypeName: 'General' })
            .then(data => {
                this.generalRecordTypeId = data;
            })
            .catch(error => {
            });


        getAccountId({ userID: this.userId })
            .then(data => {
                this.accountIduser = data;
                var cashAccountRecord = {
                    Name: 'Cash Account',
                    FinServ__FinancialAccountType__c: 'Cash Account',
                    RecordTypeId: this.generalRecordTypeId,
                    FinServ__PrimaryOwner__c: this.accountIduser,
                    FinServ__Status__c: 'Active',
                }

                saveCashAccount1({
                    cashAccount: cashAccountRecord, accountId: this.accountIduser
                })
                    .then(result => {
                        var sroAccountRecord = {
                            Name: 'SRO Account',
                            FinServ__FinancialAccountType__c: 'SRO',
                            RecordTypeId: this.generalRecordTypeId,
                            FinServ__PrimaryOwner__c: this.accountIduser,
                            FinServ__Status__c: 'Active',
                        }

                        saveSROAccount1({
                            sroaccount: sroAccountRecord, accountId: this.accountIduser
                        }).then(result => {
                            //window.console.log('SRO account..' + JSON.stringify(result));

                        }).catch(error => {
                            //window.console.log(JSON.stringify(error));
                        });
                    }).catch(error => {
                        //window.console.log(JSON.stringify(error));
                    });



            }).catch(error => {
                //console.log('getProduct..' + error);
            });

        this.template.querySelector('c-fp-account-cash-balance').getCashBalance();
    }

    @wire(getRecord, { recordId: '$accountIduser', fields: accountFileds }) wireContact({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.accName = data.fields.Name.value;
            this.accWebsite = data.fields.Website.value;
            this.accPhone = data.fields.Phone.value;
            this.accEmail = data.fields.Email__c.value;
            this.accBillingStreet = data.fields.BillingStreet.value;
            this.accBillingCity = data.fields.BillingCity.value;
            this.accBillingState = data.fields.BillingState.value;
            this.accBillingPostalCode = data.fields.BillingPostalCode.value;
            this.accBillingCountry = data.fields.BillingCountry.value;
            this.accBillingStateCode = data.fields.BillingStateCode.value;
            this.accBillingCountryCode = data.fields.BillingCountryCode.value;
            let tempData = {
                accName: this.accName,
                accWebsite: this.accWebsite,
                accPhone: this.accPhone,
                accEmail: this.accEmail,
                accShippingStreet: data.fields.ShippingStreet.value,
                accShippingCity: data.fields.ShippingCity.value,
                accShippingState: data.fields.ShippingState.value,
                accShippingPostalCode: data.fields.ShippingPostalCode.value,
                accShippingCountry: data.fields.ShippingCountry.value,
                accShippingStateCode: data.fields.ShippingStateCode.value,
                accShippingCountryCode: data.fields.ShippingCountryCode.value
            }
            if(tempData.accWebsite){
                var prefix = 'http://';
                var websiteUrl = tempData.accWebsite;
                if (websiteUrl.substr(0, prefix.length) !== prefix)
                {
                    tempData.accWebsite = prefix + websiteUrl;
                }
            }
            this.accountData = tempData;
            this.showDashMyCompany = this.accountData != {} ? true : false;
        }
    }

    pledgeColour(name) {
        var color;
        if (name == "Path to Prosperity" || name == "Academic A+" || name == "Hispanic Heritage Month") {
            color = " burgundy";
        }
        else if (name == "Project STARS" || name == "Legacy"){
            color = " yellow";
        }else if (name == "First Generation" || name == "Private"){
            color = " orange";
        }else if (name == "In-Demand Career"){
            color = " blue";
        }else if (name == "Black History Month"){
            color = " azure";
        }

        return color;
    }

    readFile(fileSource) {
        return new Promise((resolve, reject) => {
            const fileReader = new FileReader();
            const fileName = fileSource.name;
            fileReader.onerror = () => reject(fileReader.error);
            fileReader.onload = () => resolve({ fileName, base64: fileReader.result.split(',')[1] });
            fileReader.readAsDataURL(fileSource);
        });
    }

    async handleFileChange(event) {
        if (event.target.files.length != 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: "test",
                    variant: 'error'
                })
            );
        } else {
            this.profileImage = await Promise.all(
                [...event.target.files].map(file => this.readFile(file))
            );

        }
    }


    handleSelectedPledge(event) {
        event.preventDefault();
        let contractIdStr = event.currentTarget.id;
        this.contractId = contractIdStr.substring(0, 18);

        getContract({ contractId: this.contractId })
            .then(result => {
                this.selectProgramId = result.Product__c
                this.contractData = result;
                console.log('result.Product '+result.Product__c);
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        pageName: 'pledgewizard'
                    },
                    state: {
                        contractId: this.contractId,
                        selectProgramId: this.selectProgramId,
                        currentPage: '3'
                    }
                });
            })
            .catch(error => {
                this.error = error;
            });


    }


    handleNewPledge(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'pledgewizard'
            }
        });
    }

    handleAccountEditModal(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'editaccount'
            }, state: {
                accountId: this.accountIduser
            }
        });
    }

    closeAccountEditModal(event) {
        this.showAccountEditModal = event.detail;
    }

    handleNavEditAcc(event) {
        console.log('inside dashboard event method')
        this.template.querySelector('c-fp-dashboard-my-company').handleAccountEditModal(event);
    }

    handleAllTask(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'my-tasks'
            }, state: {
                accountId: this.accountIduser
            }
        });
    }

}