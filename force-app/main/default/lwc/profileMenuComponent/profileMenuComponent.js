import { LightningElement, wire, api } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

const userFileds = [NAME_FIELD]
export default class ProfileMenuComponent extends NavigationMixin(LightningElement) {

    userName;

    @api menuType;

    @wire(getRecord, {
        recordId: Id,
        fields: userFileds
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            console.log(error);
        } else if (data) {
            this.userName = data.fields.Name.value;
          }
    }

    handleMenuItem(event){
        console.log("selected menu => " + event.detail.value);
        switch (event.detail.value) {
          case "logout":
            this.handleLogout();
            break;         
        }
    }

    handleLogout() {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
        });
    }

}