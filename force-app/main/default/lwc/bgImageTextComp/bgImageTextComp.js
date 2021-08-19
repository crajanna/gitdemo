import { LightningElement, api } from 'lwc';
import 'c/fpCssLibrary';
import My_Resource from '@salesforce/resourceUrl/FoundationImages';

export default class BgImageTextComp extends LightningElement {

    @api bgImage;
    @api titleText;
    imagePath = My_Resource;

    get backgroundImage(){
        //console.log('path : '+this.imagePath+'/img/'+this.bgImage);
        return `background-image: url(${this.imagePath}/img/${this.bgImage});
         background-repeat: no-repeat;
         background-attachment: fixed;
         background-position: center;   
        -webkit-background-size: cover;
        -moz-background-size: cover;
        -o-background-size: cover;
        background-size: cover;`
 
    }

    get text(){
        //console.log('title : '+this.titleText);
        return `${this.titleText}`;
    }

}