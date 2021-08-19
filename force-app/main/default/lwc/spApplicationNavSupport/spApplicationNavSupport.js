import { LightningElement, api, track, wire } from 'lwc';
import { FlowNavigationNextEvent , FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class SpApplicationNavSupport extends LightningElement {
    @api currentStep;
    @api activeSession;


    connectedCallback(){

        let step = this.currentStep;
        console.log('NAV Support this.currentStep ' + this.currentStep);
        console.log('NAV Support this.activeSession ' + this.activeSession);
        if(this.activeSession ){
            this.currentStep = step - 1;
        }
        
        this.activeSession = true;

        const sessionAttributeChange = new FlowAttributeChangeEvent('activeSession', this.activeSession);
        this.dispatchEvent(sessionAttributeChange);

        const stepAttributeChange = new FlowAttributeChangeEvent('currentStep', this.currentStep);
        this.dispatchEvent(stepAttributeChange);

        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}