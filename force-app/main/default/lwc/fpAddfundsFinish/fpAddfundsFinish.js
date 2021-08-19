import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getTransferFundsData from '@salesforce/apex/FoundationContractController.getTransferFundsData';
import removeSessionCache from '@salesforce/apex/FoundationContractController.removeSessionCache';
import createTransferFundsData from '@salesforce/apex/FoundationContractController.createTransferFundsData';	

import 'c/fpCssLibrary';

export default class FpAddfundsFinish extends NavigationMixin(LightningElement) {

  currentPageReference = null; 
  urlStateParameters = null;
   /* Params from Url */
   amt = null;
   txid = null;
   ptxid = null;
   cid = null;
   fee = null;
   totalAmount = null;
   transferFund;
   showAmountText = false;

   @wire(CurrentPageReference)
   getStateParameters(currentPageReference) {
      if (currentPageReference) {
         this.urlStateParameters = currentPageReference.state;
         this.setParametersBasedOnUrl();
      }
   }

   setParametersBasedOnUrl() {
      this.txid = this.urlStateParameters.xid || null;
      this.ptxid = this.urlStateParameters.pxid || null;
      this.cid = this.urlStateParameters.cid || null;

      if(this.txid != null) {	
        getTransferFundsData({'transferFundId':this.txid}).then(result =>{	
           this.fee = result.Fee__c;	
           this.amt = result.Transfer_Amount__c;	
           this.totalAmount = parseFloat(this.fee)+parseFloat(this.amt);

           removeSessionCache({'accId':result.Account__c}).then(result =>{
            	

           }).catch(error=>{
            	

             });

        }).catch(error =>{	
          	
        });	
      }

        if(this.ptxid != null){
            this.showAmountText = true;

            createTransferFundsData({'extId':this.ptxid, 'type':'Contribution'}).then(result =>{

              if(result){
                getTransferFundsData({'transferFundId':result}).then(result =>{	
                  this.fee = result.Fee__c;	
                  this.amt = result.Transfer_Amount__c;	
                  this.totalAmount = parseFloat(this.fee)+parseFloat(this.amt);
       
      
               }).catch(error =>{	
                 	
               });
              }
  
             }).catch(error =>{	
            });

        }
      }
  handleGoToDashboard(){
      
   this[NavigationMixin.Navigate]({
          type: 'comm__namedPage',
           attributes: {
             pageName: 'mydashboard'
       }
  });
}

}