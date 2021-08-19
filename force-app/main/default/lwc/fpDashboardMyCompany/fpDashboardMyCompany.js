import { LightningElement, api, wire, track } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/FoundationImages';
//import uploadLogo from '@salesforce/apex/CreatePersonAccount.uploadLogoToRecord';
import uploadLogo from '@salesforce/apex/FpDashboardController.uploadLogoToRecord';
//import findLogo from '@salesforce/apex/CreatePersonAccount.findImageByRecord';
import findLogo from '@salesforce/apex/FpDashboardController.findImageByRecord';
import { NavigationMixin } from 'lightning/navigation';

export default class FpDashboardMyCompany extends NavigationMixin(LightningElement) {
    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imagecirclefpo30 = My_Resource + '/img/circle-fpo-30px.png';
    iconAddress = My_Resource + "/img/icon-address.svg"; 
    iconPhone = My_Resource + "/img/icon-phone.svg"; 
    iconEmail = My_Resource + "/img/icon-email.svg"; 
    iconWebsite = My_Resource + "/img/icon-website.svg"; 
    @api accountIduser;
    @api accountData;
    showLogo = false;
    @track profileVersionId;
    currentAccount = this.accountData;
    @track hasAccountData = false;
    hasAccountAddress = false;
    hasAccountPhone = false;
    hasAccountEmail = false;
    hasAccountWebsite = false;
    websiteUrl;
    profileImage = [];
    randomNum;

    @wire(findLogo, { recordId: '$accountIduser', randomNum: '$randomNum', description: 'Company Logo'})
    profileLogowireContact({
        error,
        data
    }) {
        if (error) {
            this.error = error;
            this.showLogo = false;
        } else if (data) {
            this.profileVersionId = data;
            this.showLogo = true;
        }
    }

    connectedCallback(){
        this.randomNum = Math.random(); 
    }
    
    renderedCallback(){
        this.hasAccountData = this.accountData ? true : false;
        this.hasAccountAddress = this.accountData && (this.accountData.accShippingStreet || this.accountData.accShippingCity || this.accountData.accShippingStateCode || this.accountData.accShippingPostalCode) ? true : false;
        this.hasAccountPhone = this.accountData && this.accountData.accPhone? true : false;
        this.hasAccountEmail = this.accountData && this.accountData.accEmail? true : false;
        this.hasAccountWebsite = this.accountData && this.accountData.accWebsite? true : false;
    }

    addHttp(){

    }

    readFile(fileSource) {
        return new Promise((resolve, reject) => {
            const fileReader = new FileReader();
            const fileName = fileSource.name;
            fileReader.onerror = () => reject(fileReader.error);
            fileReader.onload = () => resolve({ fileName, base64: fileReader.result.split(',')[1] });
            fileReader.readAsDataURL(fileSource);
        });
    }

    async handleFileChange(event) {
        if (event.target.files.length != 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: "test",
                    variant: 'error'
                })
            );
        } else {
            this.profileImage = await Promise.all(
                [...event.target.files].map(file => this.readFile(file))
            );

            uploadLogo({
                accountId: this.accountIduser,
                file: encodeURIComponent(this.profileImage[0].base64),
                fileName: this.profileImage[0].fileName
            })
                .then(result => {
                    this.profileVersionId = result;
                    this.showLogo = true;

                    this.dispatchEvent(new CustomEvent('imageupload'));
                })
                .catch(error => {
                    this.error = error.message;
                    this.showLogo = false;
                });

        }
    }

    @api
    handleAccountEditModal(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'editaccount'
            }, state: {
                accountId: this.accountIduser
            }
        });
    }
}