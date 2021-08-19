import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {getRecord} from 'lightning/uiRecordApi';
import 'c/fpCssLibrary';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import cashBalanceByAccountId from '@salesforce/apex/CreateFinancialAccount.getCashBalanceByAccountId';
import getAccountId from '@salesforce/apex/CreateFinancialAccount.getAccountId';

import {refreshApex} from '@salesforce/apex';
const userFileds = [NAME_FIELD, ACCOUNT_ID];

export default class FpAccountCashBalance extends NavigationMixin(LightningElement) {

    userId = Id;
    userName;
    accountIduser;
    cashBalance=0;

    @wire(getRecord, {
        recordId: Id, 
        fields: userFileds
    }) wireuser1({
        error,
        data
    }) {
        if (error) {
            this.cashBalance=0.00;
           this.error = error ; 
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;            
          
          }
    }
        
    @wire(cashBalanceByAccountId, { accountId: '$accountIduser' })
    cashbalance({
        error,
        result
    }) {
        if (error) {
           this.error = error ; 
           this.cashBalance=0.00;
        } else if (result) {
            if(result){
                this.cashBalance = result.data;  
            }else{
                this.cashBalance=0.00;
            }
                   
        }
    }

    connectedCallback(){
        getAccountId({ userID: this.userId})
        .then(data => { 

                  this.accountIduser = data;     
                  cashBalanceByAccountId({ accountId: this.accountIduser})
                  .then(result => { 
                      if(result){
                        this.cashBalance = result;        
                    }else{
                        this.cashBalance=0.00;
                    }
                  })
                  .catch(error => {
                       //console.log('cashBalanceByAccountId..123'+JSON.stringify(error));
                  });

      }) .catch(error => {
          //console.log('..'+error);
     });
   } 

    handleAddFunds(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'addfundspage'
            },
            state: {
                addfunds: 'addfunds'
            }
        });
    }

@api
   getCashBalance() {
          getAccountId({ userID: this.userId})
          .then(data => {   

                    this.accountIduser = data;      
                    cashBalanceByAccountId({ accountId: this.accountIduser})
                    .then(result => {
                        if(result){
                            this.cashBalance = result;        
                        }else{
                            this.cashBalance=0.00;
                        } 
                    })
                    .catch(error => {
                         //console.log('cashBalanceByAccountId..123'+JSON.stringify(error));
                    });

        }) .catch(error => {
            //console.log('..'+error);
       });

   }

}