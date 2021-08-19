import { LightningElement,  api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';

export default class EpChangePlans extends NavigationMixin(LightningElement) {

    imagecirclefpo30= My_Resource + '/img/circle-fpo-30px.png';
}