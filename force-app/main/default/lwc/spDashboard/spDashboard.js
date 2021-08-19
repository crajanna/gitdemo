import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import { getRecord } from 'lightning/uiRecordApi';

import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';

import ACC_NAME from '@salesforce/schema/Account.Name';
import ACC_WEBSITE from '@salesforce/schema/Account.Website';
import ACC_PHONE from '@salesforce/schema/Account.Phone';
import ACC_EMAIL from '@salesforce/schema/Account.Email__c';
import ACC_PERSONEMAIL from '@salesforce/schema/Account.PersonEmail';
import ACC_BILLING_STREET from '@salesforce/schema/Account.BillingStreet';
import ACC_BILLING_CITY from '@salesforce/schema/Account.BillingCity';
import ACC_BILLING_STATE from '@salesforce/schema/Account.BillingState';
import ACC_BILLING_COUNTRY from '@salesforce/schema/Account.BillingCountry';
import ACC_BILLING_POSTALCODE from '@salesforce/schema/Account.BillingPostalCode';
import ACC_BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';
import ACC_BILLING_COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';

import getTaskList from '@salesforce/apex/FpDashboardController.getTaskList';
import getAccountRelationShipDetails from '@salesforce/apex/AccountController.getAccountRelationShipDetails';
import findUserProfilePic from '@salesforce/apex/ScholarshipController.findUserProfilePic';
import getScholarshipApplicationReview from '@salesforce/apex/ScholarshipController.getScholarshipApplicationReview';
import getSPChoosePrograms from '@salesforce/apex/ScholarshipController.getSPChoosePrograms';
import findLogo from '@salesforce/apex/FpDashboardController.findImageByRecord';

import 'c/spCssLibraryNew';

const userFileds = [NAME_FIELD, ACCOUNT_ID];
const accountFileds = [ACC_NAME, ACC_WEBSITE, ACC_PHONE, ACC_EMAIL, ACC_PERSONEMAIL,
    ACC_BILLING_STREET, ACC_BILLING_CITY, ACC_BILLING_STATE, ACC_BILLING_COUNTRY, ACC_BILLING_POSTALCODE, ACC_BILLING_STATE_CODE, ACC_BILLING_COUNTRY_CODE];

const content = [
    { id: 1, tag: 'New! Path to Prosperity Scholarship Program', class: 'card-cta bg-books', description: 'Together we can make a difference for Florida’s children, one college scholarship at a time.', buttonText: 'More About the Program', buttonUrl: 'https://www.floridaprepaidcollegefoundation.com/scholarships/path-to-prosperity', imageUrl: FoundationImages + '/img/icon-arrow-right.svg' },
];

export default class SpDashboard extends NavigationMixin(LightningElement) {
    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imagePathIconHelp = My_Resource + '/img/icon-help.png';
    imagesymgray = My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';
    imagerightcircle = My_Resource + '/img/icon-arrow-right-circle.png';
    imagefpostudent30 = My_Resource + '/img/img-fpo-student-30px.png';
    imageiconarrowright = My_Resource + '/img/icon-arrow-right.png';
    imagecirclefpo14 = My_Resource + '/img/circle-fpo-14px.png';
    imageiconplus = My_Resource + '/img/icon-plus.png';
    imageMugFpodropdown = My_Resource + '/img/mug-fpo-dropdown.png';
    imageMugFpotasks = My_Resource + '/img/img-fpo-tasks.png';
    imagearrowrightwhite = My_Resource + '/img/icon-arrow-right-white.png';
    imageicontrophy = My_Resource + '/img/icon-trophy.png';
    imagecirclefpo30 = My_Resource + '/img/circle-fpo-30px.png';
    imageiconhelpchat = My_Resource + '/img/icon-help-chat.png';
    checkedIcon = FoundationImages + "/img/icon-checked.svg";
    uncheckedIcon = FoundationImages + "/img/icon-unchecked.svg";
    taskIcon = FoundationImages + "/img/icon-tasks.svg";

    statusReviewIcon = FoundationImages + "/img/icon-applications.svg";
    scholarshipIcon = FoundationImages + "/img/icon-scholarship.svg";
    scholarshipBooksIcon = FoundationImages + "/img/bg-cta-books-sp.jpg";

    addressIcon = FoundationImages + "/img/icon-address-sp.svg";
    phoneIcon = FoundationImages + "/img/icon-phone-sp.svg";
    emailIcon = FoundationImages + "/img/icon-email-sp.svg";
    editIcon = FoundationImages + "/img/icon-edit-sp.svg";

    contentData = content;
    userId = Id;
    userName;
    userContactId;
    email;
    accountId;
    randomNum;
    taskList;
    taskCount = 0;
    accRelationshipList = [];
    hasRendered = true;

    profilePic;
    accountIduser;
    accName;
    accWebsite;
    accPhone;
    accEmail;
    accBillingStreet;
    accBillingCity;
    accBillingState;
    accBillingPostalCode;
    accBillingCountry;
    accBillingStateCode;
    accBillingCountryCode;

    scholarshipPrograms;
    applyBy = 'Apply By ';
    accPersonEmail;

    @wire(getRecord, {
        recordId: Id,
        fields: [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.accountId = data.fields.AccountId.value;
            this.email = data.fields.Email.value;
        }
    }

    @wire(getRecord, { recordId: Id, fields: userFileds }) wireuser1({ error, data }) {
        if (error) {
            this.error = error;
            //console.log('getrecord error:' + JSON.stringify(this.error));

        } else if (data) {
            //console.log('getrecord data:' + JSON.stringify(data.fields));
            this.userName = data.fields.Name.value;
            this.accountIduser = data.fields.AccountId.value;
            //console.log('wire 123 - >  this.accountIduser ==> ' + this.accountIduser+' --- random number : '+this.randomNum);

            
        }
    }
    showAddress = false;
    // APPLY FOR A SCHOLARSHIP
    @wire(getSPChoosePrograms) scholarshipPrograms;

    //APPLICATION STATUS REVIEW
    //ownerId = userId;
    @wire(getScholarshipApplicationReview, { userId: '$userId' }) reviews;

    profileVersionId;
    showLogo =false;

    @wire(findLogo, { recordId: '$accountIduser', randomNum: '$randomNum', description: 'Profile_Logo' })
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
  
    @wire(getRecord, { recordId: '$accountIduser', fields: accountFileds }) wireContact({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            //console.log('wire -> getReocrd -> this.accountIduser -> ' + this.accountIduser);
            //console.log(JSON.stringify(data.fields));
            this.accName = data.fields.Name.value;
            this.accWebsite = data.fields.Website.value;
            this.accPhone = data.fields.Phone.value;
            //this.accEmail = data.fields.Email__c.value;
            this.accPersonEmail = data.fields.PersonEmail.value;
            //console.log('accName : '+this.accName+' --- accPhone: '+this.accPhone+' --- accEmail: '+this.accEmail+' --- accPersonEmail: '+this.accPersonEmail);

            this.accBillingStreet = data.fields.BillingStreet.value;
            this.accBillingCity = data.fields.BillingCity.value;
            this.accBillingState = data.fields.BillingState.value;
            this.accBillingPostalCode = data.fields.BillingPostalCode.value;
            this.accBillingCountry = data.fields.BillingCountry.value;
            this.accBillingStateCode = data.fields.BillingStateCode.value;
            this.accBillingCountryCode = data.fields.BillingCountryCode.value;
            // console.log('this.accBillingStreet -> ' + this.accBillingStreet + ' --- this.accBillingCity --> ' + this.accBillingCity + ' --- this.accBillingState -->' + this.accBillingState
            // + ' --- this.accBillingPostalCode --> ' + this.accBillingPostalCode + ' ---  this.accBillingCountry --> ' + this.accBillingCountry + ' --- this.accBillingStateCode -->' + this.accBillingStateCode
            // + ' --- this.accBillingCountryCode --> ' + this.accBillingCountryCode);

            
            if(this.accBillingStreet != null && this.accBillingCity != null && this.accBillingCountry != null && this.accBillingPostalCode != null){
                this.showAddress = true;
            }
            
            

        }
    }
    @wire(getTaskList, { recordId: '$accountId', randomNum: '$randomNum' }) taskListData({ error, data }) {
        if (data) {
            let taskList = [];
            data.forEach(element => {
                let isCompleted = element.Status == 'Completed' ? true : false;
                let eachTask = {
                    ...element,
                    isCompleted: isCompleted,
                    icon: isCompleted ? this.checkedIcon : this.uncheckedIcon,
                    sortBy: isCompleted ? "true" : "false"
                }
                taskList.push(eachTask);
            });
            //console.log('taskList before:: ' + JSON.stringify(taskList));
            this.taskCount = taskList.filter(t => !t.isCompleted).length;
            taskList = taskList.sort((a, b) => (a.sortBy > b.sortBy) ? 1 : -1).slice(0, 3);
            this.taskList = taskList.sort((a, b) => (a.sortBy < b.sortBy) ? 1 : -1);
            //console.log('this.taskList after:: ' + JSON.stringify(this.taskList));
        } else {
            //console.log('getTask error ::' + JSON.stringify(error));
        }
    }
   

    connectedCallback() {
        this.randomNum = Math.random();   
        console.log('userId : '+this.userId);     
    }

   
    renderedCallback() {
        if (this.hasRendered) {
            return;
        }
        this.hasRendered = true;
        this.template.querySelector('c-account-relationship-component').refreshData();
    }

    handleNewAccount(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'add-scholarship-account'
            }
        });
    }

    gotoScholarshipPage(event) {
        let selectProgramId = event.target.dataset.targetId;
        //console.log('selectProgramId => ' + selectProgramId);

        let selectProgramName = event.target.dataset.targetName;
        //console.log('selectProgramName => ' + selectProgramName);

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'scholarshipwizard'
            },
            state: {
                selectProgramId: selectProgramId
            }
        });
    }

    handleProfileUpdate(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'myprofileinfo'
            }
        });
    }

    handleLogout(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
        });
    }

    handleAllTask(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'my-tasks'
            },
            state: {
                accountId: this.accountId
            }
        });
    }

}