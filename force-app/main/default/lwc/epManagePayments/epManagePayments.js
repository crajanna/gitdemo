import { LightningElement,  api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';


export default class EpManagePayments extends NavigationMixin(LightningElement) {

    @api recordId;
    @api beneficiaryAccountId;
    showManagePayments = true;
    showSetupPayment = false;
    showFinancialInstitution = false;
    showEditFinInt = true;
    showAddFinInt = true;
    showWithdrawal = false;
    showTransferFund = false;

    handleSetupPayment(event){
        console.log('clicked..'+event.target.value);
        this.hideScreens();
        this.showSetupPayment = true;
    }


    handleFinancialInstitution(event){
        console.log('clicked..'+event.target.value);
        this.hideScreens();
        this.showFinancialInstitution = true;
        this.showEditFinInt = true;
        this.showAddFinInt = true;
    }

    hadleBackToManagePayments(event){
        event.preventDefault();
        event.stopPropagation();
        this.hideScreens();
        this.showManagePayments = true;
   
    }

    handleWithdrawFunds(event){
        console.log('clicked..'+event.target.value);
        this.hideScreens();
        this.showWithdrawal = true;
        
    }

    handleTransferFund(event){
        this.hideScreens();
        this.showTransferFund = true;
    }

    handleRecurringPayment(event){
        this.hideScreens();
        this.showRecurringPayment = true;
    }

    hideScreens(){
        this.showManagePayments = false;
        this.showSetupPayment = false;
        this.showFinancialInstitution = false;
        this.showEditFinInt = false;
        this.showAddFinInt = false;
        this.showWithdrawal = false;
        this.showTransferFund = false;
        this.showRecurringPayment = false;
    }
   
}