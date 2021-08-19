import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';

import getBeneficiaryList from '@salesforce/apex/FinancialAccountController.getBeneficiaryList';
import getAccountRelationShipDetails from '@salesforce/apex/AccountController.getAccountRelationShipDetails';


export default class BeneficiaryListComponent extends NavigationMixin(LightningElement) {

    imagefpostudent30 =  My_Resource + '/img/img-fpo-student-30px.png';
    imageiconarrowright = My_Resource + '/img/icon-arrow-right.png';
    imagecirclefpo14= My_Resource + '/img/circle-fpo-14px.png';
    imagerightcircle = My_Resource + '/img/icon-arrow-right-circle.png';
    imageplus = My_Resource + '/img/icon-plus.png';
    

    @api recordId;
    beneficiaryList =[];

    @wire(getBeneficiaryList, {accountId: '$recordId' })
    getBeneficiaryList({ error, data }) {
        if (error) {
          console.log(error);
        } else if (data) {
           console.log('Savingsplan..'+JSON.stringify(data));


        if(data){
            for(const item of data){
                var cssActive= 'box-dash box-dash-gray pb-10 pt-15';
                console.log('benid..'+localStorage.getItem('cpSelectedBeneficiaryId'));
                console.log('item.id..'+item.id);

                if(item.id == localStorage.getItem('cpSelectedBeneficiaryId')){
                    cssActive = 'box-dash box-dash-gray pb-10 pt-15 box-active';
                }
                const option = {
                    id: item.id,
                    name:item.name,
                    dob:item.dob,
                    savingsamount:item.savingsamount,
                    isSavingsplan:true,
                    isPrepaidPlan:false,
                    cssClass:cssActive
                };
                this.beneficiaryList = [ ...this.beneficiaryList, option ];
            }
        }
          console.log('this.beneficiaryList..'+JSON.stringify(this.beneficiaryList));

        }
    }


    @wire(getAccountRelationShipDetails, {
        relatedAccountId:  '$recordId',
        reciprocalRole : 'Parent/Guardian'
    })
    getAccountRelationShipDetails({ error, data }) {
        if(error){
        }else if(data){
            console.log('this.getAccountRelationShipDetails..'+JSON.stringify(data));

            for(const item of data){
                const option = {
                    id: item.relationshipAccountId,
                    name:item.relationshipAccountName,
                    dob:item.dob,
                    savingsamount:'0.00',
                    isSavingsplan:false,
                    isPrepaidPlan:false,
                    cssClass:'box-dash box-dash-gray pb-10 pt-15'
                };
                this.beneficiaryList = [ ...this.beneficiaryList, option ];
            }
            
        }
    }

    addNewPlanHandler(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'enrollmentpage'
            }
        });
    }

    showBeneficiaryOverview(event){
        event.preventDefault();
        event.stopPropagation();
       var value =  event.currentTarget.dataset.value;
       console.log('va;;'+value);
       localStorage.setItem('cpSelectedBeneficiaryId',value);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'beneficiaryoverview'
            }, state: {
                id: value
            }
        });
    }

    handleViewAllPlans(event){
        localStorage.setItem('cpSelectedBeneficiaryId', 'allplans');
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'allplans'
            }
        });  
    }

    hanldeDummyPage(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'dummypage'
            }
        });  
    }

    get beneficiaryItemList(){
      return  this.beneficiaryList.sort((a, b) => (a.name > b.name) ? 1 : -1)
    }

    get isAllPlansActive(){
        return localStorage.getItem('cpSelectedBeneficiaryId')=='allplans';
    }

}