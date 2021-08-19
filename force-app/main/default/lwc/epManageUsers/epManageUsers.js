import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import {getRecord} from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';
import TF_SOURCE_TYPE from '@salesforce/schema/Transfer_Fund__c.Source_Type__c';
import saveTransferFund from '@salesforce/apex/TransferFundController.saveTransferFund';
import getFinancialAccountRolesById from '@salesforce/apex/FinancialAccountController.getFinancialAccountRolesById';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class EpManageUsers extends NavigationMixin(LightningElement) {

  @api finAccountId;//='a0FP0000007zm6iMAA';

  @track userList =[];

    @wire(getRecord, {
        recordId: Id,
        fields: [ACCOUNT_ID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        } else if (data) {
            this.userAccountId = data.fields.AccountId.value;
        }
    }


  connectedCallback(){
    if(localStorage.getItem('cpmanageusers')){
        this.finAccountId = localStorage.getItem('cpmanageusers');
    }
    console.log('this.cpmanageusers....'+this.finAccountId);
}


  @wire(getFinancialAccountRolesById, {finAcctId: '$finAccountId' })
  getFinancialAccountRolesById({ error, data }) {
      if (error) {
        console.log(error);
      } else if (data) {
         console.log('userList1..'+JSON.stringify(data));


      if(data){
          for(const item of data){
              const option = {
                  finAccountId:this.finAccountId,
                  id: item.Id,
                  accountId:item.FinServ__RelatedAccount__r.Id,
                  name:item.FinServ__RelatedAccount__r.Name, 
                  role: item.FinServ__Role__c                  
              };
              this.userList = [ ...this.userList, option ];
          }
      }
        console.log('this.userList..'+JSON.stringify(this.userList));

      }
  }


}