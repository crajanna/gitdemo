import { LightningElement, track, api } from 'lwc';
import TRAILHEAD_LOGO from '@salesforce/resourceUrl/BgContact';

export default class ContractPOC extends LightningElement {

    @api bannerImage;
    @api bannerContent;
    
    get logo(){
        console.log('TrailHead Logo: '+TRAILHEAD_LOGO);
        
        
        return TRAILHEAD_LOGO;
    }
     
    get image(){
        return `background-image: url(${this.bannerImage});`
 
    }

    get text(){
        return `${this.bannerContent}`;
    }
   
}