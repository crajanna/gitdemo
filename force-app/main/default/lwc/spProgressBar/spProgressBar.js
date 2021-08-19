import { LightningElement, api, track } from 'lwc';
// import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class SpProgressBar extends LightningElement {
    @api currentStep;
    @track activeStep;
    @track dataId;
    step1class = 'btn-wiz-new';
    step2class = 'btn-wiz-new';
    step3class = 'btn-wiz-new';
    step4class = 'btn-wiz-new';

    connectedCallback(){
        console.log('thiscurrentStep in PGB::'+this.currentStep);

        if(this.currentStep){
            if(this.currentStep == 1){
                this.step1class = 'btn-wiz-new active';
                console.log('PGB inside step 1');
            } else if(this.currentStep == 2){
                this.step1class = 'btn-wiz-new done';
                this.step2class = 'btn-wiz-new active';
                console.log('PGB inside step 2');
            }else if(this.currentStep == 3){
                this.step1class = this.step2class = 'btn-wiz-new done';
                this.step3class = 'btn-wiz-new active';
                console.log('PGB inside step 3');
            }else if(this.currentStep == 4){
                this.step1class = this.step2class = this.step3class = 'btn-wiz-new done';
                this.step4class = 'btn-wiz-new active';
                console.log('PGB inside step 4');
            }
        }
    }
}