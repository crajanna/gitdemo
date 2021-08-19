import { LightningElement, api, wire, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class SpApplicationStep2 extends LightningElement {
    @api availableActions = [];
    @api currentStep;
    @api monthly;
    @api annually;
    @api wrapperJson;
    @track isLoading = true;
    monthVal = '';
    jsonObject;


    connectedCallback(){
        this.isLoading = false;
        console.log('Step 1 wrapperJson:: '+this.wrapperJson);

        // let jsonObject = {};

        if(typeof this.wrapperJson == 'string'){
            this.jsonObject = JSON.parse(this.wrapperJson);
        } else {
            this.jsonObject = JSON.parse(JSON.stringify(this.wrapperJson));
        }
        console.log('typeof this.wrapperJson2:: ' + typeof this.wrapperJson);
        console.log('this.currentStep2:: ' + this.currentStep);
        this.jsonObject.CurrentStep = this.currentStep;
        this.wrapperJson = JSON.stringify(this.jsonObject);
        // this.currentStep = this.wrapperJson.CurrentStep;

    
        // this.dispatchEvent(new FlowAttributeChangeEvent('currentStep', this.currentStep + 1));
        
    }


    handleChange(event) {
        console.log('event::' + JSON.stringify(event));
        const elementName = event.target.name;
        const elementValue = event.target.value;
        console.log('elementName::' + elementName);
        console.log('elementValue::' + elementValue);

        if (elementName === 'monthly') {
            this.jsonObject.City = elementValue;
        } else if (elementName === 'annually') {

        }

        this.dispatchEvent(new FlowAttributeChangeEvent('wrapperJson', JSON.stringify(this.jsonObject)));

    }
}