import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages'

export default class EnrollmentFooter extends NavigationMixin(LightningElement) {

    imagePathIconHelp = My_Resource + '/img/icon-help.png'; 
    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';

    handleTitleClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

        
    handleLogout(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
        });
    }

}