import { LightningElement, api, wire } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/FoundationImages';
import { CurrentPageReference } from 'lightning/navigation';
import getProduct from '@salesforce/apex/FPPedgeController.getProduct';

export default class FpPledgeWizard extends LightningElement {
    currentPageReference = null;
    urlStateParameters = null;

    imageSymbolGray = My_Resource + '/img/logo-flpp-symbol-gray.svg';


    pledgeSteps = [{ label: "1.Choose Program", value: "1" },
    { label: "2.Make a Pledge", value: "2" },
    { label: "3.Specify Payment", value: "3" },
    ];

    /* Params from Url */
    selectedScholarship = null;
    currentPage;
    currentStep = "1";
    currentIndex = 0;
    currentStepTitle = "Choose Program";

    contractId;
    selectProgramId;
    county;
    zip;
    pledge;
    productName;
    displayProduct = false;

    //col-2 Choose program information
    donationAmount;
    pledgeAmout;

    productImgURL;
    productName2;
    priductDescription;
    productDidYouKnow;
    productLearnMoreURL;
    hasRendered = false;
    //End

    @wire(CurrentPageReference)
    currentPageReference;

    // getStateParameters(currentPageReference) {
    //     ////

    //     if (currentPageReference) {
    //         this.urlStateParameters = currentPageReference.state;
    //         this.setParametersBasedOnUrl();
    //     }
    // }

    // setParametersBasedOnUrl() {        
    //     
    //     
    //     
    //     this.contractId = this.urlStateParameters.contractId || null;
    //     this.currentPage = this.urlStateParameters.currentPage || null;
    //     this.selectProgramId = this.urlStateParameters.selectProgramId || null;
    // }
    renderedCallback() {
        
        window.scroll(0, 0);
    }
    
    connectedCallback() {

        //if (!this.hasRendered) {

        this.currentPage = this.currentPageReference.state.currentPage;

        //
        //

        if (this.currentPage != null) {
            this.contractId = this.currentPageReference.state.contractId;
            this.selectProgramId = this.currentPageReference.state.selectProgramId;
            if (parseFloat(this.currentPage) == 3) {
                this.currentIndex = 2;
                this.currentStep = this.pledgeSteps[this.currentIndex].value;
                this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;
            }
            if (parseFloat(this.currentPage) == 2) {
                this.currentIndex = 1;
                this.currentStep = this.pledgeSteps[this.currentIndex].value;
                this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;
            }
            if (parseFloat(this.currentPage) == 1) {
                this.currentIndex = 0;
                this.currentStep = this.pledgeSteps[this.currentIndex].value;
                this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;
            }

            this.currentPage = null;

        } else {

            const queryString = window.location.search;
            //
            const urlParams = new URLSearchParams(queryString);

            if (urlParams.has('currentPage')) {
                this.currentPage = urlParams.get('currentPage');
                //
                //

                if (parseFloat(this.currentPage) == 3) {
                    this.currentIndex = 2;
                    this.currentStep = this.pledgeSteps[this.currentIndex].value;
                    this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;
                }
                if (parseFloat(this.currentPage) == 2) {
                    this.currentIndex = 1;
                    this.currentStep = this.pledgeSteps[this.currentIndex].value;
                    this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;
                }
                if (parseFloat(this.currentPage) == 1) {
                    this.currentIndex = 0;
                    this.currentStep = this.pledgeSteps[this.currentIndex].value;
                    this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;
                }
            } else {
                //
            }

        }

        //this.hasRendered = true;
        //}




        // if(!this.hasRendered){

        //     this.hasRendered= true;
        // }

        window.scroll(0, 0);
    }


    get chooseProgramStep() {
        //
        return this.currentStep == this.pledgeSteps[0].value;
    }

    get makePledge() {
        //
        return this.currentStep == this.pledgeSteps[1].value;
    }

    get specifyPayment() {
        //
        return this.currentStep == this.pledgeSteps[2].value;
    }


    goToNextStep(event) {
        //
        console.log('event of next step: '+JSON.stringify(event.detail));

        this.selectProgramId = event.detail.selectProgramId;
        this.county = event.detail.county;
        this.zip = event.detail.zip;
        this.pledge = event.detail.pledge;

        if (this.currentIndex + 1 == this.pledgeSteps.length) {
            this.currentStep = "1";
            this.currentIndex = 0;
            this.currentStepTitle = "Choose Program";
        } else {
            this.currentIndex++;
            this.currentStep = this.pledgeSteps[this.currentIndex].value;
            this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;
        }
    }

    goToPreviousStep(event) {
        console.log('event of previous step: '+JSON.stringify(event.detail));
        this.selectProgramId = event.detail.selectProgramId;
        this.county = event.detail.county;
        this.zip = event.detail.zip;
        this.pledge = event.detail.pledge;
        this.contractId = event.detail.contractId;
        //
        //
        //
        //
        //

        //
        this.currentIndex--;
        this.currentStep = this.pledgeSteps[this.currentIndex].value;
        this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;

    }


}