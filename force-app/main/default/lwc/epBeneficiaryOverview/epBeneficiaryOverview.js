import { LightningElement, wire } from 'lwc';
import {CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import getUserAccountId from '@salesforce/apex/UserController.getUserAccountId';
import { getRecord } from 'lightning/uiRecordApi';
import ACC_NAME from '@salesforce/schema/Account.Name';
const accountFields = [ ACC_NAME, ];

export default class EpBeneficiaryOverview extends NavigationMixin(LightningElement) {

    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imagePathIconHelp = My_Resource + '/img/icon-help.png';    
    imagesymgray= My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';
    imagerightcircle = My_Resource + '/img/icon-arrow-right-circle.png';
    imagefpostudent30 =  My_Resource + '/img/img-fpo-student-30px.png';
    imageiconarrowright = My_Resource + '/img/icon-arrow-right.png';
    imagecirclefpo14= My_Resource + '/img/circle-fpo-14px.png';
    imageiconplus= My_Resource + '/img/icon-plus.png';
    imageMugFpodropdown= My_Resource + '/img/mug-fpo-dropdown.png';
    imageMugFpotasks= My_Resource + '/img/img-fpo-tasks.png';
    imagearrowrightwhite= My_Resource + '/img/icon-arrow-right-white.png';
    imageicontrophy= My_Resource + '/img/icon-trophy.png';
    imagecirclefpo30= My_Resource + '/img/circle-fpo-30px.png';
    imageiconhelpchat = My_Resource + '/img/icon-help-chat.png';

    beneficiaryAccountId;
    userAccountId;
    beneficiaryName;

        // Declare the currentPageReference variable in order to track it
        currentPageReference;
        // Injects the page reference that describes the current page
        @wire(CurrentPageReference)
        setCurrentPageReference(currentPageReference) {
            this.currentPageReference = currentPageReference;

            if (this.connected) {
                // We need to have the currentPageReference, and to be connected before
                // we can use NavigationMixin
                this.generateUrls();
            } else {
                // NavigationMixin doesn't work before connectedCallback, so if we have 
                // the currentPageReference, but haven't connected yet, queue it up
                this.generateUrlOnConnected = true;
            }
        }

        connectedCallback() {
            this.connected = true;
            
            // If the CurrentPageReference returned before this component was connected,
            // we can use NavigationMixin to generate the URLs
            if (this.generateUrlOnConnected) {
                this.generateUrls();
            }
        }

        generateUrls() {
            if(this.currentPageReference){
               this.beneficiaryAccountId = this.currentPageReference.state.id;
                console.log('beneficiaryId..' +this.beneficiaryAccountId );

                getUserAccountId()
                .then(data => {
                    this.userAccountId = data;  

              }) .catch(error => {
             });

            }
        }
    
        @wire(getRecord, {
            recordId: '$beneficiaryAccountId',
            fields: accountFields
        }) wireAccount({
            error,
            data
        }) {
            if (error) {
            } else if (data) {
                if(data){
                    this.beneficiaryName = data.fields.Name.value;
                }
            }
        }


        hanldeDummyPage(event){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'dummypage'
                }
            });  
        }



        handleManageAccount(event){
            localStorage.setItem('cpBeneficiaryId',this.beneficiaryAccountId);
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'manageaccount'
                }
            });
        }


}