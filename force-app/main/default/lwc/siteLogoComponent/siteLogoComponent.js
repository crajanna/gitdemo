import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import My_Resource from '@salesforce/resourceUrl/ECImages';

export default class SiteLogoComponent extends NavigationMixin(LightningElement) {

    @api logoName = 'logo-fl-prepaid-black-320px.png';

    // imagePath= My_Resource + '/img/logo-fl-prepaid-black-320px.png';

    get imagePath(){
        return My_Resource +'/img/' + this.logoName;
    }

    handleClick(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

}