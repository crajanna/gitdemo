import { LightningElement } from 'lwc';

export default class EnrollmentWizard extends LightningElement {

    enrollementSteps = [{label: "Plan Selection", value: "1"}, {label: "Beneficiary Info", value: "2"}, 
                    {label: "Review Selection", value: "3"}, {label: "Your Profile", value: "4"},
                    {label: "Billing Info", value: "5"} , {label: "Agreement", value: "6"},
                    {label: "Application Submitted", value: "7"}
                   ];

    currentStep = "1";
    currentIndex = 0;
    newEnrollment = true;
    currentStepTitle="Plan Selection";

    contractId;

    renderedCallback() {
        window.scroll(0, 0);   
    }

    get planSelectionStep(){
        return this.currentStep == this.enrollementSteps[0].value;
    }

    get beneficiaryInfoStep(){
        return this.currentStep == this.enrollementSteps[1].value;
    }

    get reviewSelectionStep(){
        return this.currentStep == this.enrollementSteps[2].value;
    }

    get yourProfileStep(){
        return this.currentStep == this.enrollementSteps[3].value;
    }

    get billingInfoStep(){
        return this.currentStep == this.enrollementSteps[4].value;
    }

    get agreementStep(){
        return this.currentStep == this.enrollementSteps[5].value;
    }

    get applicationSubmittedStep(){
        return this.currentStep == this.enrollementSteps[6].value;
    }

    goToNextStep(event) {
        this.contractId = event.detail.contractId;
        window.console.log("gotonext contractId" + this.contractId);
        if(this.currentIndex + 1 == this.enrollementSteps.length) {
            this.currentStep = "1";
            this.currentIndex = 0;
            this.newEnrollment = true;
            this.currentStepTitle="Plan Selection";
        } else {
            this.currentIndex++;
            this.currentStep = this.enrollementSteps[this.currentIndex].value;
            this.currentStepTitle = this.enrollementSteps[this.currentIndex].label;
        }    
    }
}