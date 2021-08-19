import { LightningElement } from 'lwc';
import 'c/fpCssLibrary';
export default class Three extends LightningElement {

    finish(){
        console.log('finish invoked');
        
    }

    handleGoBack(event) {
        const passEvent = new CustomEvent('previous', {
            detail: {
                testId: this.testId,
            }
        });
        this.dispatchEvent(passEvent);
    }
}