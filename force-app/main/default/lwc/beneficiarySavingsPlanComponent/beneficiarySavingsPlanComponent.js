import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getSavingsPlanDetails from '@salesforce/apex/FinancialAccountController.getSavingsPlanDetails';
import My_Resource from '@salesforce/resourceUrl/ECImages';

export default class BeneficiarySavingsPlanComponent extends NavigationMixin(LightningElement) {


    imagecirclefpo30= My_Resource + '/img/circle-fpo-30px.png';


    @api userAccountId;
    @api beneficiaryAccountId;

    savingsPlanDetail = {
        accountOwner: "",
        accountOwnerName: "",
        currentBalance:"",
        faNumber: "",
        faId:"",
        nextPayment: "",
        survivorName:"",
        survivorId: "",
    };


    @wire(getSavingsPlanDetails, {accountId: '$userAccountId' ,  beneficiaryId: '$beneficiaryAccountId'})
    getSavingsPlanDetails({ error, data }) {
        if (error) {
          console.log(error);
        } else if (data) {
           console.log('Savingsplan..'+JSON.stringify(data));
           this.savingsPlanDetail = {
            accountOwner: data.accountOwner ? data.accountOwner : null,
            accountOwnerName: data.accountOwnerName? data.accountOwnerName : null,
            currentBalance: data.currentBalance ? data.currentBalance : null,
            faNumber: data.faNumber ? data.faNumber : null,
            faId:data.faId?data.faId :null,
            nextPayment: data.nextPayment ? data.nextPayment : null,
            survivorName: data.survivor ? data.survivor.Name : null,
            survivorId:  data.survivor ? data.survivor.Id : null
        
        };

        }
    }
    
    onViewDetailsHandler(event){
        event.preventDefault();
        event.stopPropagation();
        const value =  event.currentTarget.dataset.value;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'savingsplanoverview'
            }, state: {
                id: value
            }
        });
    }


    handleManageUsers(event){
        event.preventDefault();
        event.stopPropagation();
        const value =  event.currentTarget.dataset.value;
        localStorage.setItem('cpmanageusers',value);

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'manageusers'
            }
        })
    }

}