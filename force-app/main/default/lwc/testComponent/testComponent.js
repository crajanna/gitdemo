import { LightningElement, wire } from 'lwc';
import 'c/fpCssLibrary';
import getChoosePrograms from '@salesforce/apex/FPPedgeController.getChoosePrograms';
import getChooseSpotLightPrograms from '@salesforce/apex/FPPedgeController.getChooseSpotLightPrograms';

import { NavigationMixin } from 'lightning/navigation';
export default class TestComponent extends LightningElement {

    selctedProgram;
    spotLight;

    spotLightId;
    spotLightName;
    spotLightImgUrl;
    spotLightDescription;
    spotLightColorCode;
    spotLightProductCode;
    spotLightError;

    @wire(getChoosePrograms) programs;
    @wire(getChooseSpotLightPrograms) spotLightProgram({ data, error }) {
        if (data) {

            this.spotLight = data;
            this.spotLightId = this.spotLight.Id;
            this.spotLightName = this.spotLight.Name;
            this.spotLightImgUrl = this.spotLight.Pledge_Image__c;
            this.spotLightDescription = this.spotLight.Description;
            this.spotLightColorCode = this.spotLight.Color_Code__c;
            this.spotLightProductCode = this.spotLight.ProductCode;

            // console.log('this.spotLight.Id :'+this.spotLight.Id);
            // console.log('this.spotLight.Name :'+this.spotLight.Name);
            // console.log('this.spotLight.Pledge_Image__c :'+this.spotLight.Pledge_Image__c);
            // console.log('this.spotLight.Description :'+this.spotLight.Description);
            // console.log('this.spotLight.Color_Code__c :'+this.spotLight.Color_Code__c);
            // console.log('this.spotLight.ProductCode :'+this.spotLight.ProductCode);
        } else {
            this.spotLightError = error;
        }
    };

    handleSelectProgram(event) {
        this.selectedProgram = event.target.value;
        console.log('Selected Program: ' + this.selectedProgram);
    }
    handleChooseProgram(event) {
        console.log('Next ')
        console.log('hanlde selected pledge :' + this.selectedProgram);
        const passEvent = new CustomEvent('next',{
            detail:{contractId:this.selectedProgram} 
        });
        this.dispatchEvent(passEvent);



        /*this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'pledgewizard'
            },
            state: {
                currentPage: '2',
                selectedPledgeId: this.selectedProgram
            }
        });*/
    }

}