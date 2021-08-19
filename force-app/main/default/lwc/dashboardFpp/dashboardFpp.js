import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import {getRecord} from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
export default class DashboardFpp extends NavigationMixin(LightningElement) {
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

    userId = Id;
    userName;
    accountId;


    connectedCallback(){
        localStorage.removeItem('cpSelectedBeneficiaryId');
        localStorage.removeItem('cpBeneficiaryId');
    }

    @wire(getRecord, {
        recordId: Id,
        fields: [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.accountId = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
        }
    }
    handleBeneficiaryInfoPage(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'beneficiaryinfoenrollment'
            }
        });
    }
    handleHelpCenterPage(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'profileenrollment'
            }
        });
    }

    handleBillingInfoPage(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'billinginfoenrollment'
            }
        });
    }

    handlePlanSelectionPage(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'planselectionenrollment'
            }
        });
    }


    handleAgreementPage(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'agreementenrollment'
            }
        });
    }
    

    handleUserSettingsPage(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'settings/'+Id
            }
        });
    }

    handleNewEnrollment(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'enrollmentpage'
            }
        });
    }
    

    handleReviewEnrollment(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'reviewselectionenrollment'
            }
        });
    }

    showBeneficiaryOverview(event){
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'beneficiaryoverview'
            }, state: {
                id: '001P000001pQQzkIAG'
            }
        });
    }
}