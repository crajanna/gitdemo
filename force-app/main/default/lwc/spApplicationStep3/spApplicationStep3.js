import { LightningElement, wire, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class SpApplicationStep3 extends LightningElement {
    @api currentStep;
    @api favSubject;
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
        console.log('typeof this.wrapperJson3:: ' + typeof this.wrapperJson);
        this.jsonObject.CurrentStep = this.currentStep;
        this.wrapperJson = JSON.stringify(this.jsonObject);
        // this.currentStep = this.wrapperJson.CurrentStep;

    
        // this.dispatchEvent(new FlowAttributeChangeEvent('currentStep', this.currentStep + 1));
    }

    handleChange(event){
        console.log('event::'+JSON.stringify(event));

        const elementName = event.target.name;
        const elementValue = event.target.value;
        console.log('elementName::'+elementName);
        console.log('elementValue::'+elementValue);

        if(elementName === 'subject'){
            this.jsonObject.City = elementValue;
        } 

        this.dispatchEvent(new FlowAttributeChangeEvent('wrapperJson', JSON.stringify(this.jsonObject)));
    }
}