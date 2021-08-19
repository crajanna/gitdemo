import { LightningElement, api, wire, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { FlowNavigationNextEvent , FlowNavigationBackEvent } from 'lightning/flowSupport';

export default class SpApplicationStep1 extends LightningElement {
    @api availableActions = [];
    @api currentStep;
    @api studentName;
    @api dob;
    @api wrapperJson;
    jsonObject;
    @track isLoading = true;
    wrapperData;
    nameVal = '';
    dobVal = '';


    connectedCallback(){
        this.isLoading = false;
        console.log('Step 1 wrapperJson:: '+this.wrapperJson);

        // let jsonObject = {};

        if(typeof this.wrapperJson == 'string'){
            this.jsonObject = JSON.parse(this.wrapperJson);
        } else {
            this.jsonObject = JSON.parse(JSON.stringify(this.wrapperJson));
        }
        console.log('typeof this.wrapperJson1:: ' + typeof this.wrapperJson);
        console.log('this.currentStep1:: ' + this.currentStep);
        this.jsonObject.CurrentStep = this.currentStep;
        this.wrapperJson = JSON.stringify(this.jsonObject);
        //this.currentStep = this.wrapperJson.CurrentStep;

        //this.dispatchEvent(new FlowAttributeChangeEvent('currentStep', this.currentStep + 1));


        this.nameVal = this.jsonObject.Name;
        this.dobVal = this.jsonObject.DateOfBirth;

        // Creates a dummy event.
        //const dummyEvent = new CustomEvent('dummy', { "target": 'none' });

        //this.handleChange(dummyEvent);

        
    }


    handleChange(event){
        console.log('event::'+JSON.stringify(event));
        console.log('event.target::'+JSON.stringify(event.target));

        var elementName;
        var elementValue;

        if(event.target != null){
            elementName = event.target.name;
            elementValue = event.target.value;
        } 

        console.log('elementName::'+elementName);
        console.log('elementValue::'+elementValue);

        if(elementName === 'studentName'){
            this.jsonObject.Name = elementValue;
            
        } 
        else if (elementName === 'dob'){
            this.jsonObject.DateOfBirth = elementValue;
        }
        
        this.dispatchEvent(new FlowAttributeChangeEvent('wrapperJson', JSON.stringify(this.jsonObject)));
        

    }
   
}