import { LightningElement } from 'lwc';
import 'c/fpCssLibrary';
export default class SpStudentInterests extends LightningElement {



    handleStudentInterests(){
        console.log('handleStudentInformation passing event param');
        const passEvent = new CustomEvent('next', {
            detail: {
                testId: 'test'
            }
        });
        this.dispatchEvent(passEvent);
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