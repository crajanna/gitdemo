import { LightningElement, wire, api } from 'lwc';
import getProduct from '@salesforce/apex/FPPedgeController.getProduct';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';

export default class SpStudentSelectedProgram extends LightningElement {
    @api selectProgramId;

    productData;
    productName;
    productImgURL;
    priductDescription;
    productDidYouKnow;
    productLearnMoreURL;

    logoURL1 = FoundationImages + '/img/icon-heart.svg';
    get heartLogo() {
        return this.logoURL1;
    }

    @wire(getProduct, { productId: '$selectProgramId' })
    getProduct({ error, data }) {
        
        if (error) {
            this.error = error;
        } else if (data) {
            this.productData = data;
            this.productName = this.productData.Name;
            if (this.productName == 'Path to Prosperity') {
                this.displayProduct = true;
            }
            this.productImgURL = FoundationImages + '/img/' + this.productData.Pledge_Image__c;
            this.priductDescription = this.productData.Description;
            this.productDidYouKnow = this.productData.Did_You_Know__c;
            this.productLearnMoreURL = this.productData.Learn_More_URL__c;
        }
    }

}