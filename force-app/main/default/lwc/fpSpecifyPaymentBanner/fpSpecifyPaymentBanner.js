import { LightningElement, wire, api } from 'lwc';
import 'c/fpCssLibrary';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
export default class FpSpecifyPaymentBanner extends LightningElement {

    logoURL2 = FoundationImages + '/img/spledge1.jpeg';
    logoURL1 = FoundationImages + '/img/icon-fpo.png';
   
    get heartLogo() {
        return this.logoURL1;
    }
 
    get programLogo() {
        return this.logoURL2;
    }
}