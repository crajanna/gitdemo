import { LightningElement, track, wire, api } from 'lwc';
import {getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';

export default class ContractAgreementFpp extends LightningElement {
    imageFpo90 =  My_Resource + '/img/img-fpo-alt-90px.png';
    
    @api contractId;

    isPdpaSelected;

    handlePdpaSelection(event){
        windows.console.log("this.isPdpaSelected.." + event.target.checked);
        this.isPdpaSelected = event.target.checked;
      }

}