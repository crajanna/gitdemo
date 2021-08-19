import { LightningElement, track, wire } from 'lwc';
import getChoosePrograms from '@salesforce/apex/FPPedgeController.getChoosePrograms';
import getChooseSpotLightPrograms from '@salesforce/apex/FPPedgeController.getChooseSpotLightPrograms';


export default class TestFPChooseProgram extends LightningElement {

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
    @wire(getChooseSpotLightPrograms) spotLightProgram({data,error}){
        if(data){
          
            this.spotLight = data;

            console.log('this.spotLight.Id :'+this.spotLight.Id);
            console.log('this.spotLight.Name :'+this.spotLight.Name);
            console.log('this.spotLight.Pledge_Image__c :'+this.spotLight.Pledge_Image__c);
            console.log('this.spotLight.Description :'+this.spotLight.Description);
            console.log('this.spotLight.Color_Code__c :'+this.spotLight.Color_Code__c);
            console.log('this.spotLight.ProductCode :'+this.spotLight.ProductCode);

            this.spotLightId = this.spotLight.Id;
            this.spotLightName = this.spotLight.Name;
            this.spotLightImgUrl = this.spotLight.Pledge_Image__c;
            this.spotLightDescription = this.spotLight.Description;
            this.spotLightColorCode = this.spotLight.Color_Code__c;
            this.spotLightProductCode = this.spotLight.ProductCode;
        }else{
            this.spotLightError = error;
        }
    };

    handleChooseProgram(event) {
        this.selectedProgram = event.target.value;
        console.log('Selected Program: '+this.selectedProgram)
        const passEvent = new CustomEvent('next', {
            detail: { productCode: this.selectedProgram }
        });
        this.dispatchEvent(passEvent);
    }


   
}