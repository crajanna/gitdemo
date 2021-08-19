import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class HomePageFpp extends NavigationMixin(LightningElement) {

    handleBeneficiaryInfoPage(event) {
         this[NavigationMixin.Navigate]({
             type: 'comm__namedPage',
             attributes: {
                 pageName: 'beneficiaryinfoenrollment'
             }
         });
     }
}