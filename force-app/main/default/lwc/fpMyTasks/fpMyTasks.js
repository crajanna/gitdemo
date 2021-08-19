import { LightningElement, wire, api, track } from 'lwc';
import getTaskList from '@salesforce/apex/FpDashboardController.getTaskList';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

export default class FpMyTasks extends NavigationMixin(LightningElement) {

    categories = ['Invoice','Receipt'];
    @track receipts = [];
    @track invoices = [];
    showSpinner = true;
    pageReference;
    accountIduser;
    taskListData;
    checkedIcon = FoundationImages + "/img/icon-checked.svg";
    uncheckedIcon = FoundationImages + "/img/icon-unchecked.svg";

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.currentPageReference) {
            this.accountIduser = this.currentPageReference.state.accountId;
        }
    }

    @wire(getTaskList, { recordId: '$accountIduser' }) setTaskListData
    ({ error, data }) {
        if (data) {
            let taskList = [];
            data.map(element => {
                let eachTask = {
                    ...element,
                    icon: element.Status === 'Completed' ? this.checkedIcon : this.uncheckedIcon,
                    CreatedDate: (new Date(element.CreatedDate)).toLocaleDateString()
                }
                taskList.push(eachTask);
            });
            this.taskListData = taskList;
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            console.error(JSON.stringify(error));
        }
    }

    handleNavigte(event){
        const result = this.taskListData.filter(task => task.Id === event.target.name);

        if(result[0].Description.split(':')[0] === 'event'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: result[0].Description.split(':')[1]
                }, state: {
                    accountId: result[0].WhatId
                }
            });
        }else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: result[0].Description
                }
            });
        }
    }
}