import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import bootstrap from '@salesforce/resourceUrl/bootstrap4portal';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import  'c/cssLibrary';
export default class NewRegistrationPage extends LightningElement {
    imagePath = My_Resource + '/img/img-fpo-alt-90px.png';
    renderedCallback() {
        Promise.all([
            loadScript(this, bootstrap + '/bootstrap-4.6.0-dist/js/bootstrap.js'),          
            loadStyle(this, bootstrap + '/bootstrap-4.6.0-dist/css/bootstrap.css')
        ])
            .then(() => {
                console.log("All scripts and CSS are loaded. perform any initialization function.")
            })
            .catch(error => {
                console.log("failed to load the scripts");
            });
    }

}