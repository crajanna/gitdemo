import { LightningElement, api, wire} from 'lwc';
import getMeetingMaterials from '@salesforce/apex/BoardDocsController.getMeetingMaterials';

export default class Demo extends LightningElement {
    
    handleChange(){
        console.log('XXXXXXXXXXXXXXXXX');
    }
  
}