import { LightningElement } from 'lwc';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';

export default class ProfileNewPlansSummary extends LightningElement {
    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imagePathIconHelp = My_Resource + '/img/icon-help.png'; 
    imagesymgray= My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';
    imageFpo90 =  My_Resource + '/img/img-fpo-alt-90px.png';
    
}