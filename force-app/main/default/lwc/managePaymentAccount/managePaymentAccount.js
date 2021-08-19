import { LightningElement, wire, api, track } from 'lwc';
import {NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import 'c/cssLibraryFpp';
import isguest from '@salesforce/user/isGuest';
import Id from '@salesforce/user/Id';
import {getRecord, deleteRecord} from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getRecordTypeId from '@salesforce/apex/CreateFinancialAccount.getRecordTypeIdbyName';
import getFinancialAccounts from '@salesforce/apex/FinancialAccountController.getFinancialAccountsByAccountId';
import FINANCIAL_ACCOUNT from '@salesforce/schema/FinServ__FinancialAccount__c';
import FINANCIAL_ACCOUNT_TYPE from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c';
import saveFinAccount from '@salesforce/apex/FinancialAccountController.saveFinAccount';
import deleteFinAccount from '@salesforce/apex/FinancialAccountController.deleteFinAccount';



import ACCOUNT_ID from '@salesforce/schema/User.AccountId';

const userFileds = [ACCOUNT_ID];

export default class ManagePaymentAccount extends LightningElement(NavigationMixin) {
    // isGuestUser = isguest;
    userId = Id;
    accountIduser;
    isLoading =false;
    finAcctRecord = FINANCIAL_ACCOUNT;
    @track showNewAccount = false;
    @track isDialogVisible = false;
    @track originalMessage;
    @api showAdd;
    @api showEdit;

    hideAccountCombobox = false;
    showNewAccountSetup = false;
    editFinAccountRecord = {
        id : '',
        name : '',
        type : '',
        routingNumber : '',
        accountNumber : ''
    };

    selectedName;
    financialAccountList;

   @track paymentAccountList = [];

    @wire(getRecord, {
        recordId: Id,
        fields: userFileds
    }) wireuser1({
        error,
        data
    }) {
        if (error) {
           this.error = error; 
        } else if (data) {
            console.log( JSON.stringify( data.fields ));
            this.accountIduser = data.fields.AccountId.value;
          }
    }

    @wire(getRecordTypeId, { objectName: 'FinServ__FinancialAccount__c',  strRecordTypeName: 'BankingAccount' })
    bankingAccountRecordtypeID;

    @wire(getPicklistValues,
        {
            recordTypeId: '$bankingAccountRecordtypeID.data', 
            fieldApiName: FINANCIAL_ACCOUNT_TYPE 
        }
    )
    bankAccountPicklist;


    @wire(getFinancialAccounts, { accountId: '$accountIduser' })
    financialAccountList({ error, data }) {
        this.financialAccountList = data;
        if (data) {
            console.log('datab..'+JSON.stringify(data));
            for(const item of data){
                const option = {
                    id: item.Id,
                    name: item.Name,
                    type: item.FinServ__FinancialAccountType__c,
                    routingNumber:item.FinServ__RoutingNumber__c,
                    accountNumber:'****'+ item.Bank_Account_Number__c,
                    isEdit :false
                };
                this.paymentAccountList = [ ...this.paymentAccountList, option ];
            }
            this.sortAccountList();
            console.log('datab..'+JSON.stringify(this.paymentAccountList));
            
        } else if (error) {
            console.log('error..'+JSON.stringify(error));
        }
    }


    handleFinAcctNameChange(event){
        console.log('accname..'+event.target.value);
        this.editFinAccountRecord.name = event.target.value;
    }

    handleAccountTypeChange(event){
        this.editFinAccountRecord.type = event.target.value;
    }

    handleFinAcctRoutingNbrChange(event){
        this.editFinAccountRecord.routingNumber = event.target.value;
    }

    handleFinAcctNbrChange(event){
        this.editFinAccountRecord.accountNumber = event.target.value;
    }

    handleEditFinAccount(event){
        let selectedId = event.target.dataset.id;
        this.editFinAccountRecord = {};

        for (const item of this.paymentAccountList){
            if(item.id == selectedId){               
               this.editFinAccountRecord.id = item.id;
                this.editFinAccountRecord.name = item.name;
                this.editFinAccountRecord.type = item.type;
                this.editFinAccountRecord.routingNumber = item.routingNumber;
                this.editFinAccountRecord.accountNumber = item.accountNumber;
                item.isEdit=true;  
            }
            else{
                item.isEdit=false;
            }
        }
        console.log('save this.editFinAccountRecord id..'+ JSON.stringify('selectedvalues..'+JSON.stringify(this.editFinAccountRecord)));

      }

      async  handleSaveAccount(event){
        try{
            this.isLoading = true;
            let selectedId = event.target.dataset.id;
    
            const bankaccountDetails = {
                Id :this.editFinAccountRecord.id,
                Name : this.editFinAccountRecord.name,
                Bank_Account_Number__c:this.editFinAccountRecord.accountNumber,
                FinServ__RoutingNumber__c: this.editFinAccountRecord.routingNumber,
                FinServ__FinancialAccountType__c:this.editFinAccountRecord.type,
             }        
              const result = await saveFinAccount({ obj: bankaccountDetails });
    
              console.log('result1..'+JSON.stringify(result));
              if(result){
                for (const item of this.paymentAccountList){
                    if(item.id == result.Id){               
                        item.name = result.Name;
                        item.type = result.FinServ__FinancialAccountType__c;
                        item.routingNumber = result.FinServ__RoutingNumber__c;
                        item.accountNumber = '****'+ result.Bank_Account_Number__c;
                        item.isEdit=false;  
                    }
                    else{
                        item.isEdit=false;
                    }
                }
                this.sortAccountList();
                const evt1 = new ShowToastEvent({
                    title: 'Account updated successfully',
                    message: 'success',
                    variant: 'success'
                });
                this.dispatchEvent(evt1);
              }
        }catch(error){
            this.isLoading = false;
        }finally{
            this.isLoading = false;
            this.editFinAccountRecord = {};
        }
      }


    handleCancelAccount(event){
        this.editFinAccountRecord = {};
        this.paymentAccountList.forEach(function(item) {
            item.isEdit=false;
        });
    }

    async handleSaveNewAccount(event){
        
        try{
            this.isLoading = true;
            const bankaccountDetails = {
                Name : this.editFinAccountRecord.name,
                Bank_Account_Number__c:this.editFinAccountRecord.accountNumber,
                FinServ__RoutingNumber__c: this.editFinAccountRecord.routingNumber,
                FinServ__FinancialAccountType__c:this.editFinAccountRecord.type,
                RecordTypeId: this.bankingAccountRecordtypeID.data,
                FinServ__PrimaryOwner__c : this.accountIduser,
                FinServ__Status__c : 'Active'
             }       
        
            const result = await saveFinAccount({ obj: bankaccountDetails });
           
             if(result){              
                const option = {
                    id: result.Id,
                    name: result.Name,
                    type: result.FinServ__FinancialAccountType__c,
                    routingNumber:result.FinServ__RoutingNumber__c,
                    accountNumber:'****'+ result.Bank_Account_Number__c,
                    isEdit :false
                };
                this.paymentAccountList = [ ...this.paymentAccountList, option ];
                this.sortAccountList();
                const evt1 = new ShowToastEvent({
                    title: 'Account added successfully',
                    message: 'success',
                    variant: 'success'
                });
                this.dispatchEvent(evt1);
             }
             this.isLoading = false;
             
        }catch(error){
            this.editFinAccountRecord = {};
            this.showNewAccountSetup  = false;
            this.isLoading = false;
        }finally{
            this.editFinAccountRecord = {};
            this.showNewAccountSetup  = false;
            this.isLoading = false;
        }

       
    }

    handleCancelNewAccount(event){
        this.showNewAccountSetup  =false;
    }

    handleDeleteFinAccount(event){
        let selectedId = event.target.dataset.id;
         this.originalMessage = selectedId;
         this.isDialogVisible = true;
    }

   async handleConfirmationClick(event){
        
            //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
            if(event.detail !== 1){
                //gets the detail message published by the child component
              console.log('Status: ' + event.detail.status + '. Event detail: ' + JSON.stringify(event.detail.originalMessage) + '.');

                //you can do some custom logic here based on your scenario
                if(event.detail.status === 'confirm') {
                    this.isLoading = true;
                    const result = await deleteFinAccount({ recordId: event.detail.originalMessage });
                    console.log(result);
                    if(result){
                        this.paymentAccountList = this.paymentAccountList.filter(value => value.id !== event.detail.originalMessage);
                        this.sortAccountList();
                        const evt1 = new ShowToastEvent({
                            title: 'Account deleted successfully',
                            message: 'success',
                            variant: 'success'
                        });
                        this.dispatchEvent(evt1);
                    }
                    this.isLoading = false;
                }else if(event.detail.status === 'cancel'){
                    this.isDialogVisible = false;
                }
            }

            //hides the component
            this.isDialogVisible = false;
    }

    handleNewAccount(event){
        console.log('dfd');
        this.showNewAccountSetup  =true;
        
    }

    sortAccountList(){
        return  this.paymentAccountList.sort((a, b) => (a.name.toLowerCase() > b.name.toLowerCase()) ? 1 : -1)
      }


}