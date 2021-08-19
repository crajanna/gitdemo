import { LightningElement } from 'lwc';
import 'c/fpCssLibrary';

export default class FpConfirmPaymentDetails extends LightningElement {

    handleGoBack(event){
        const passEvent = new CustomEvent('previous'); 
         this.dispatchEvent(passEvent);
    }
    
}