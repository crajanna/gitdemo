/**
 * @description       : 
 * @author            : Satishbabu Anupoju@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-07-2021   Satishbabu Anupoju@UserSettingsUnder.SFDoc   Initial Version
**/
import { LightningElement, wire } from 'lwc';
import getChoosePrograms from '@salesforce/apex/FPPedgeController.getChoosePrograms';
import getChooseSpotLightPrograms from '@salesforce/apex/FPPedgeController.getChooseSpotLightPrograms';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import 'c/fpCssLibrary';

export default class FpPledgeChooseProgram extends NavigationMixin(LightningElement) {

    selctedProgram;
    spotLight;
    spotLightId;
    spotLightName;
    spotLightImgUrl;
    spotLightDescription;
    spotLightColorCode;
    spotLightProductCode;
    spotLightLearnMoreURL;
    spotLightError;
    spotLightGtmid;
    displayNext = false;
    starIcon = FoundationImages + '/img/icon-star.svg';
    whitePlusIcon = FoundationImages + '/img/icon-plus-white.svg';

    programs =[];

    @wire(getChoosePrograms) programsData({ data, error }) {
        if (data) {
            this.programs = JSON.parse(JSON.stringify(data));
            this.programs.forEach(function(item){  
                item.gtmid = 'Choose a Program - '+item.Name;                     
            });
        } else {
            this.spotLightError = error;
        }
    };

    @wire(getChooseSpotLightPrograms) spotLightProgram({ data, error }) {
        if (data) {
            this.spotLight = data;
            this.spotLightId = this.spotLight.Id;
            this.spotLightName = this.spotLight.Name;
            this.spotLightImgUrl = FoundationImages+'/img/'+this.spotLight.Pledge_Image__c;
            this.spotLightDescription = this.spotLight.Description;
            this.spotLightColorCode = this.spotLight.Color_Code__c;
            this.spotLightProductCode = this.spotLight.ProductCode;
            this.spotLightLearnMoreURL = this.spotLight.Learn_More_URL__c;
            this.spotLightGtmid = 'Choose a Program - '+this.spotLight.Name;
        } else {
            this.spotLightError = error;
        }
    };

    handleValidateChooseProgram(){
        this.showToast('Information', 'Please select a program', 'info');
    }

    handleSelectProgram(event) {
        this.selectedProgram = event.target.value;
        let contractIdStr = event.currentTarget.id;
        const passEvent = new CustomEvent('next', {
            detail: {
                selectProgramId: this.selectedProgram
            }
        });
        this.dispatchEvent(passEvent);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            type: variant
        });
        this.dispatchEvent(evt);
    }
}