/**
 * @description       : 
 * @author            : Satishbabu Anupoju@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-19-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-07-2021   Satishbabu Anupoju@UserSettingsUnder.SFDoc   Initial Version
**/
import { LightningElement, wire, api } from 'lwc';
import getCountyNames from '@salesforce/apex/FPPedgeController.getCountyNames';
import getCountyZipCode from '@salesforce/apex/FPPedgeController.getCountyZipCode';
import getZipCode from '@salesforce/apex/FPPedgeController.getZipCode';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import { CurrentPageReference } from 'lightning/navigation';
import getProduct from '@salesforce/apex/FPPedgeController.getProduct';
import getContract from '@salesforce/apex/FPPedgeController.getContract';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import 'c/fpCssLibrary';

export default class FpPledgeMakeAPledge extends LightningElement {

    @api selectedScholarship;
    @api contractId;
    @api selectProgramId;
    @api productName;
    @api displayProduct;
    @api productImgURL;

    contributionType;
    isCounty = false;
    enableZipCodes = false;
    enableCounty = false;
    countyNames;
    zipCodes;
    howMuch = '';
    county;
    selectedCounty;
    selectedZipCode;
    dollarIcon = FoundationImages + "/img/icon-dollar-sign.svg";
    pledgeIcon = FoundationImages + "/img/icon-pledges.svg";
    externalLinkIcon = FoundationImages + "/img/icon-link-external.svg";

    //col-2 Choose program information
    donationAmount = 0.00;
    pledgeAmout = 0.00;
    contractData;
    productImgURL;
    productName2;
    priductDescription;
    productDidYouKnow;
    productLearnMoreURL;
    productData;
    toolTip;
    
    logoURL2 = FoundationImages + '/img/spledge1.jpeg';
    
    logoURL1 = FoundationImages + '/img/icon-heart.svg';
    displayNext = false;
    displayErrorMsg = false;

    get heartLogo() {
        return this.logoURL1;
    }

    get programLogo() {
        return this.logoURL2;
    }

    @wire(getContract, { contractId: '$contractId' })
    getContract({ error, data }) {
    
        if (error) {
            this.error = error;
            this.donationAmount = 0.00;
            this.pledgeAmout = 0.00;
        } else if (data) {
            this.contractData = data;
            this.donationAmount = this.contractData.Donation_Amount__c;
            this.pledgeAmout = this.contractData.Pledge__c;
            this.selectedCounty = this.contractData.County__c;
            this.selectedZipCode = this.contractData.Zip_Code__c
            if(this.donationAmount == undefined ){
                this.donationAmount = 0.00;
            }
            if(this.pledgeAmout == undefined ){
                this.pledgeAmout = '0.00';
            }else if(this.pledgeAmout > 0){
                this.howMuch = this.pledgeAmout;
                this.displayNext = true;
            }
    
        }
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

    handleMakePledge(event) {
        if (this.county == null) {
            this.county = 'All';
            this.zip = 'All';
        }
        const passEvent = new CustomEvent('next', {
            detail: {
                selectProgramId: this.selectProgramId,
                contractId: this.contractId,
                county: this.county,
                zip: this.zip,
                pledge: this.howMuch
            }
        });
        this.dispatchEvent(passEvent);
    }

    handleGoBack(event) {
        const passEvent = new CustomEvent('previous', {
            detail: {
                contractId: this.contractId,
                selectProgramId: this.selectProgramId,
                county: this.county,
                zip: this.zip,
                pledge: this.howMuch
            }
        });
        this.dispatchEvent(passEvent);
    }

    handleChange(event) {

        if (event.target.name == 'contribution') {
            this.contributionType = event.target.value;
            if (this.contributionType == 'County') {
                this.isCounty = true;
                this.enableCounty = true;
                this.enableZipCodes = false;
                getCountyNames()
                    .then(result => {
                
                        this.countyNames = result;
                    })
                    .catch(error => {
                        this.error = error;
                    });
            } else if (this.contributionType == 'Florida' || this.contributionType == 'Where Most Needed') {
                this.isCounty = false;
                this.enableCounty = false;
                this.enableZipCodes = false;
            } else {
                this.isCounty = false;
                
                getZipCode()
                    .then(result => {
                
                        this.enableCounty = false;
                        this.enableZipCodes = true;
                        this.zipCodes = result;
                    })
                    .catch(error => {
                        this.error = error;
                    });
            }
        }

        if (event.target.name == 'county') {
            this.county = event.target.value;
            if (this.county == 'All') {
                this.enableZipCodes = false;
            } else {
                getCountyZipCode({ countyName: this.county })
                    .then(result => {
                        this.enableZipCodes = true;
                        this.zipCodes = result;
                    })
                    .catch(error => {
                        this.error = error;
                    });
            }
        }

        if (event.target.name == 'zip') {
            this.zip = event.target.value;
        }

        if (event.target.name == 'howMuch') {
            this.howMuch = event.target.value;
            if(!this.howMuch.indexOf('-') == 0 && 
                this.howMuch != 0 && this.howMuch != ''){
                this.displayNext = true;
                this.displayErrorMsg = false;
            }else{
                this.displayErrorMsg = true;
                this.displayNext = false;
            }
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.contractId = this.urlStateParameters.contractId || null;
        this.selectedScholarship = this.urlStateParameters.selectedPledgeId || null;
        this.currentPage = this.urlStateParameters.currentPage || "1";
    }

    showToolTip(){
        this.toolTip = true;
    }

    HideToolTip(){
        
        this.toolTip = false;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            type: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
}