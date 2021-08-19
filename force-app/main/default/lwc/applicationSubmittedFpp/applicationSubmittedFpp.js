import { LightningElement, api } from 'lwc';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import { NavigationMixin } from 'lightning/navigation';

export default class ApplicationSubmittedFpp extends NavigationMixin(LightningElement) {


    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imagePathIconHelp = My_Resource + '/img/icon-help.png'; 
    imageFpo90 =  My_Resource + '/img/img-fpo-alt-90px.png';
    imagesymgray= My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';

    @api contractId;

    handleNewEnrollment() {
        goToNextPage();
    }

    goToNextPage(){
        const passEvent = new CustomEvent('next', {
            detail:{contractId:''} 
        }); 
         this.dispatchEvent(passEvent);
    }  

    handleGoToDashboard(){
              this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                     attributes: {
                       name: 'Home'
                 }
            });
    }

}