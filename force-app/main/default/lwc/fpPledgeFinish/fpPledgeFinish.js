import { LightningElement, wire } from 'lwc';	
import { NavigationMixin } from 'lightning/navigation';	
import { CurrentPageReference } from 'lightning/navigation';
import getPledgeData from '@salesforce/apex/FoundationContractController.getPledgeData';	
import getContractData from '@salesforce/apex/FoundationContractController.getContractData';	
import My_Resourcepfinish from '@salesforce/resourceUrl/FoundationImages';	
import removeSessionCache from '@salesforce/apex/FoundationContractController.removeSessionCache';
import createTransferFundsData from '@salesforce/apex/FoundationContractController.createTransferFundsData';	

import 'c/fpCssLibrary';	
export default class FpPledgeFinish extends NavigationMixin(LightningElement) {	
  currentPageReference = null; 	
  urlStateParameters = null;	
  // imgCelebration = My_Resourcepfinish + '/img/img-celebration.jpg';	
  imgCelebration = My_Resourcepfinish + '/img/img-celebration.png';	
   /* Params from Url */
   amt = null;	
   txid = null;	
   ptxid = null;	
   cid = null;	
   afid = null;	
   transferFund;	
   pledgeAmount;	
   pledgeName;	
   productId;	
   productCode;
   showAmountText;	
   showFullAmountText;
   fee = null;
   totalAmount;
   recordType;
   isLoading = false;
   isP2P=false;

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
      this.afid = this.urlStateParameters.afid || null;	
      if(this.cid != null) {	
        getPledgeData({'contractId':this.cid}).then(result =>{	
          this.pledgeName = result.Product__r.Name;	
          this.pledgeAmount = result.Pledge__c;	
          this.showAmountText =false;
        }).catch(error =>{	
          console.error("getPledgeData.." , error);	
        });	
      }	
      if(this.txid != null) {	
        getContractData({'transferFundId':this.txid}).then(result =>{
          this.showAmountText =true;	
           this.pledgeName = result.Contract__r.Product__r.Name;	
           this.productCode = result.Contract__r.Product__r.ProductCode;	
           this.pledgeAmount = result.Contract__r.Pledge__c;	
           this.fee = result.Fee__c;	
           this.amt = result.Transfer_Amount__c;	
           this.totalAmount = parseFloat(this.fee)+parseFloat(this.amt);

           if(this.productCode == 'SP7'){
            this.isP2P = true;
           }

           removeSessionCache({'accId':result.Account__c}).then(result =>{
           }).catch(error=>{
             });

        }).catch(error =>{	
        });	
      }	
      if(this.ptxid != null){	
        this.isLoading = true;
          this.showFullAmountText = true;
          this.showAmountText =true;	

          createTransferFundsData({'extId':this.ptxid, 'type':'Pledge'}).then(result =>{

            if(result){
              getContractData({'transferFundId':result}).then(result =>{
                this.showAmountText =true;	
                 this.pledgeName = result.Contract__r.Product__r.Name;
                 this.productCode = result.Contract__r.Product__r.ProductCode;		
                 this.pledgeAmount = result.Contract__r.Pledge__c;	
                 this.fee = result.Fee__c;	
                 this.amt = result.Transfer_Amount__c;	
                 this.totalAmount = parseFloat(this.fee)+parseFloat(this.amt);
                 if(this.productCode == 'SP7'){
                  this.isP2P = true;
                 }
                 this.isLoading = false;
                
              }).catch(error =>{	
                this.isLoading = false;
              });	
            }

           }).catch(error =>{	
            this.isLoading = false;
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
handleAnotherPledge(event) {	
  this[NavigationMixin.Navigate]({	
      type: 'comm__namedPage',	
      attributes: {	
          pageName: 'pledgewizard'	
      }	
  });	
}	
}