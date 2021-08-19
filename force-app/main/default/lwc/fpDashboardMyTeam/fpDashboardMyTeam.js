import { LightningElement, wire, track, api } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import getAccountContactData from '@salesforce/apex/FpDashboardController.getAccountContactData';
import 'c/fpCssLibrary';
import My_Resource from '@salesforce/resourceUrl/FoundationImages';
const userFileds = [NAME_FIELD, ACCOUNT_ID];

export default class FpDashboardMyTeam extends NavigationMixin(LightningElement) {
    taskIcon = My_Resource + "/img/icon-edit.svg";
    profilePic = My_Resource + "/img/icon-profile-placeholder.svg";
    userId = Id;
    userName;
    showToolTip = false;
    accountIduser;
    @track contactsData;
    showDashboardContact;
    @track className="card-team";
    randomNum;

    connectedCallback(){
        this.randomNum = Math.random();
    }

    @wire(getRecord, {
        recordId: Id,
        fields: userFileds
    }) wireuser1({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;            
          
          }
    }

    @wire(getAccountContactData, { accountId: '$accountIduser', randomNum: '$randomNum' })
    contactsDatawireuser1({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {              
            this.contactsData = data;
          }
    }

    handleDashboardContact(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'editcontact'
            }
        });
    }

    handleDashboardEditContact(event){
        
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'editcontact'
            }, state: {
                contactId: event.currentTarget.dataset.id
            }
        });
    }

    get OnMouseIn () {
        this.className =  "card-team active";
    }
    get OnMouseOut () {
        this.className =  "card-team";
    }

    OnHelpMouseEnter () {
        this.showToolTip =  true;
    }
    OnHelpMouseLeave () {
        this.showToolTip =  false;
    }

}