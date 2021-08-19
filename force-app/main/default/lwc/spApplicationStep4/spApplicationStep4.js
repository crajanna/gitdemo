import { LightningElement, wire, api, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class SpApplicationStep4 extends LightningElement {
    @api currentStep;
    @api wrapperJson;
    @track isLoading = true;
    jsonObject;

    connectedCallback(){
        console.log('wrapperJson screen 2 CCB:: ' + this.wrapperJson);
        this.isLoading = false;

        // let jsonObject = {};

        if(typeof this.wrapperJson == 'string'){
            this.jsonObject = JSON.parse(this.wrapperJson);
        } else {
            this.jsonObject = JSON.parse(JSON.stringify(this.wrapperJson));
        }
        console.log('typeof this.wrapperJson2:: ' + typeof this.wrapperJson);
        this.jsonObject.CurrentStep = this.currentStep;
        this.wrapperJson = JSON.stringify(this.jsonObject);
    //     this.currentStep = this.wrapperJson.CurrentStep;

    
        // this.dispatchEvent(new FlowAttributeChangeEvent('currentStep', this.currentStep ));
    }

}