import { LightningElement, api, track, wire } from 'lwc';
import { FlowNavigationNextEvent , FlowNavigationBackEvent } from 'lightning/flowSupport';

export default class SpApplicationFooter extends LightningElement {
    @api availableActions = [];
    @api wrapperJson;
    currentStep;
    @track visibleNext = false;
    @track visibleBack = false;
    @track nextLabel = 'Next';
    goBackLabel = '< Go Back';


    connectedCallback(){
        console.log('wrapperJson in footer: ' + this.wrapperJson);
        if(this.availableActions){
            if(this.availableActions.includes("NEXT"))
                this.visibleNext = true;
            if(this.availableActions.includes("BACK"))
                this.visibleBack = true;
            if(this.availableActions.includes("FINISH")){
                this.visibleNext = true;
                this.nextLabel = 'Finish';
            }
        }
    }

    handleNextScreen(event){
        event.preventDefault();
        console.log('NEXT button clicked');

        // check if NEXT is allowed on this screen
        if (this.availableActions.find(action => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    handleBackScreen(event){
        event.preventDefault();
        console.log('BACK button clicked');

        // check if BACK is allowed on this screen
        if (this.availableActions.find(action => action === 'BACK')) {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }
}