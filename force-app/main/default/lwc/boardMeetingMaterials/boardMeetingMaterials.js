import { LightningElement, wire, api } from 'lwc';
import getMeetingMaterials from '@salesforce/apex/BoardDocsController.getMeetingMaterials'

export default class BoardMeetingMaterials extends LightningElement {


    @api step;
    @api template;
    meetingMaterialList;
    boardType;
    displayFPB = false;
    displayFB = false;
    displayAB = false;
    displaySCM = false;

    connectedCallback(){
        this.getBoardDocuments();
    }


    getBoardDocuments(){
        console.log('this.step:: ' + this.step);
        console.log('this.template:: ' + this.template);
        getMeetingMaterials({ boardType: this.step, templateType: this.template })
        .then(data => {
            this.meetingMaterialList = data;

            if (data.length > 0) {
                this.boardType = data[0].boardType;
                if (this.boardType.toLowerCase() === 'Florida Prepaid Board'.toLowerCase()) {
                    this.displayFPB = true;
                    this.displayFB = false;
                    this.displayAB = false;
                } else if (this.boardType.toLowerCase() === 'Foundation Board'.toLowerCase()) {
                    this.displayFPB = false;
                    this.displayFB = true;
                    this.displayAB = false;
                } else if (this.boardType.toLowerCase() === 'ABLE Board'.toLowerCase()) {
                    this.displayFPB = false;
                    this.displayFB = false;
                    this.displayAB = true;
                } else if (this.boardType.toLowerCase() === 'Steering'.toLowerCase()) {
                    this.displayFPB = false;
                    this.displayFB = false;
                    this.displayAB = false;
                    this.displaySCM = true;
                }
        }})
        .catch(error => {
            console.log(JSON.stringify(error));
            console.log('Something went wrong');
        });
    }


}