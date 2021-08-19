import { LightningElement } from 'lwc';
import 'c/fpCssLibrary';
export default class One extends LightningElement {


    handleStudentInformation(){
        console.log('handleStudentInformation passing event param');
        const passEvent = new CustomEvent('next', {
            detail: {
                testId: 'test'
            }
        });
        this.dispatchEvent(passEvent);
    }

}