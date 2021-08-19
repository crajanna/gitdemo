import { LightningElement, wire } from 'lwc';
import {CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import {getRecord} from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import getSavingsPlanDetails from '@salesforce/apex/FinancialAccountController.getSavingsPlanDetails';

export default class EpSavingsPlanOverview extends NavigationMixin(LightningElement) {

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

    showInvestmentPage = false;
    userAccountId;
    beneficiaryAccountId;
    beneficiaryName;
    financialAccountId;
    finAccTransactionDetail = [];

    savingsPlanDetail = {
        accountOwner: "",
        accountOwnerName: "",
        currentBalance:0.00,
        faNumber: "",
        faId:"",
        nextPayment: "",
        survivorName:"",
        survivorId: "",
        openDate:"",
        accountType:""
    };
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
          this.financialAccountId = this.currentPageReference.state.id;
           console.log('financialAccountId..' +this.financialAccountId );

           getSavingsPlanDetails({finAccId: this.financialAccountId})
           .then(data => {
            console.log('savingplandetils999..'+JSON.stringify(data));
            this.savingsPlanDetail = {
                accountOwner: data.accountOwner ? data.accountOwner : null,
                accountOwnerName: data.accountOwnerName? data.accountOwnerName : null,
                currentBalance: data.currentBalance ? data.currentBalance : 0.00,
                faNumber: data.faNumber ? data.faNumber : null,
                faId:data.faId?data.faId :null,
                nextPayment: data.nextPayment ? data.nextPayment : null,
                survivorName: data.survivor ? data.survivor.Name : null,
                survivorId:  data.survivor ? data.survivor.Id : null,
                beneficiaryName: data.beneficiary ? data.beneficiary.name : null,
                beneficiaryId:  data.beneficiary ? data.beneficiary.Id : null,
                openDate: data.openDate?data.openDate : null,
                accountType:data.accountType?data.accountType : null
            };

         }) .catch(error => {
        });



     }
   }

    @wire(getRecord, {
        recordId: Id,
        fields: [ACCOUNT_ID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        } else if (data) {
            console.log('userAccountId..'+JSON.stringify(data));
            this.userAccountId = data.fields.AccountId.value;
        }
    }


    handleInvestmentOptions(event){
        this.showInvestmentPage = true;
    }



    handleChangePlans(event){
        this.dummyPage();
    }


    dummyPage(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'dummypage'
            }
        });
    }



}