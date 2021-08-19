import { LightningElement, api } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import bootstrap from '@salesforce/resourceUrl/bootstrap4portal';

import  'c/cssLibrary';
export default class PlanSelectionPage extends LightningElement {
    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imagesymblack= My_Resource + '/img/logo-fl-prepaid-symbol-black-260px.png';
    @api contactId;

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

    handleSuccess(event) {
        const conId = event.detail.id;
        this.dispatchEvent(new CustomEvent('next', {detail: conId}));
    }


}