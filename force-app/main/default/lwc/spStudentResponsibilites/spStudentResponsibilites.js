import { LightningElement, api, wire } from 'lwc';

import getProduct from '@salesforce/apex/FPPedgeController.getProduct';
import uploadVideo from '@salesforce/apex/ScholarshipController.uploadVideoToRecord';
import linkFileWithRecord from '@salesforce/apex/ScholarshipController.linkFileWithRecord';
import uploadResourceToRecord from '@salesforce/apex/ResourceController.uploadResourceToRecord';

import getUserAccount from '@salesforce/apex/ScholarshipController.getUserAccount';


import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';

import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import USER_OBJECT from '@salesforce/schema/User';
import CONTRACT_ACCOUNT_NAME from '@salesforce/schema/Contract.AccountId';
import CONTRACT_STATUS from '@salesforce/schema/Contract.Status';
import CONTRACT_START_DATE from '@salesforce/schema/Contract.StartDate';
import CONTRACT_TERM from '@salesforce/schema/Contract.ContractTerm';
import CONTRACT_RECORD_TYPE_ID from '@salesforce/schema/Contract.RecordTypeId';
import CONTRACT_INTERESTS from '@salesforce/schema/Contract.Interests__c';
import CONTRACT_ESSAY_OR_STUDENT_STATEMENT from '@salesforce/schema/Contract.Essay__c';
import CONTRACT_GUARDIAN_NAME from '@salesforce/schema/Contract.Guardian_Name__c';
import CONTRACT_PRODUCT_ID from '@salesforce/schema/Contract.Product__c';
import CONTRACT_BENEFICIARY_ACCOUNT from '@salesforce/schema/Contract.Beneficiary_Account__c';


import CONTRACT_BENEFICIARY_QUALIFY from '@salesforce/schema/Contract.Benefits_Qualify__c';
import CONTRACT_FIRST_IN_FAMILY from '@salesforce/schema/Contract.First_in_Family__c';
import CONTRACT_MENTOR from '@salesforce/schema/Contract.Mentor__c';
import CONTRACT_MENTOR_ORGANIZATION from '@salesforce/schema/Contract.Mentor_Organization__c';
import CONTRACT_WORKING_WITH_MENTOR from '@salesforce/schema/Contract.Working_with_Mentor__c';
import CONTRACT_INSTITUTION from '@salesforce/schema/Contract.Institution__c';
import CONTRACT_SEMESTER from '@salesforce/schema/Contract.Semester__c';

import ID_FIELD from '@salesforce/schema/Contract.Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';

import 'c/spCssLibrary';



export default class SpStudentResponsibilites extends NavigationMixin(LightningElement) {
    @api selectProgramId;
    @api selectedStudentId;
    @api guardianId;
    @api base64Data;
    @api academicInterests;
    @api videoFileUploader;
    @api videoFiles;
    @api proofOfBenefitsFiles;
    @api floridaResidentToQualifyFiles;
    @api essayStudentStatement;
    @api accountId;
    @api recordId;


    @api benefitsQualify;
    @api proofOfBenefits;
    @api completeHighSchoolOrAttendCollege;
    @api mentor;
    @api mentorOrOrganization;
    @api workingWithMentor;
    @api institution;
    @api semester;

    productData;
    productId;
    productName;
    productImgURL;
    priductDescription;
    productDidYouKnow;
    productLearnMoreURL;
    displayStudentQuestions = true;
    parentId;
    objectInfo;
    acceptTerms;
    displayFinish = false;
    loggedinUserId = USER_ID;
    user;
    userAccountId;
    connectedCallback() {
       //console.log('loggedinUserId ==> ' + this.loggedinUserId);



        // console.log('############################################# STEP 4 ################################################################');
        // console.log('@@@ Step 4 ===> benefitsQualify ===> ' + this.benefitsQualify);
        // console.log('@@@ Step 4 ===> proofOfBenefits ===> ' + this.proofOfBenefits);
        // console.log('@@@ Step 4 ===> completeHighSchoolOrAttendCollege ===> ' + this.completeHighSchoolOrAttendCollege);
        // console.log('@@@ Step 4 ===> mentor ===> ' + this.mentor);
        // console.log('@@@ Step 4 ===> mentorOrOrganization ===> ' + this.mentorOrOrganization);
        // console.log('@@@ Step 4 ===> workingWithMentor ===> ' + this.workingWithMentor);
        // console.log('@@@ Step 4 ===> institution ===> ' + this.institution);
        // console.log('@@@ Step 4 ===> semester ===> ' + this.semester);
        // console.log('############################################# STEP 4 ################################################################');

        getUserAccount({ userId: this.loggedinUserId })
            .then(data => {
                //window.console.log('result  ' + JSON.stringify(data));
                this.userAccountId = data;
                console.log('accountId : ' + this.userAccountId);

            })
            .catch(error => {
                window.console.log('Error: =========> ' + error + ' ---- JSon error : ' + JSON.stringify(error));

            });
    }


    @wire(getRecord, { recordId: '$recordId' }) user;


    showToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Scholarship Application created sucessfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    @wire(getObjectInfo, { objectApiName: CONTRACT_OBJECT }) objectInfo;

    @wire(getProduct, { productId: '$selectProgramId' })
    getProduct({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.productData = data;
            this.productId = this.productData.Id;
            console.log('this.productId => ' + this.productId);
            this.productName = this.productData.Name;
            this.productImgURL = FoundationImages + '/img/' + this.productData.Pledge_Image__c;
            this.priductDescription = this.productData.Description;
            this.productDidYouKnow = this.productData.Did_You_Know__c;
            this.productLearnMoreURL = this.productData.Learn_More_URL__c;

        }
    }

    handleGoBack(event) {
        const passEvent = new CustomEvent('previous', {
            detail: {
                selectProgramId: this.selectProgramId,
                selectedStudentId: this.selectedStudentId,
                guardianId: this.guardianId

            }
        });
        this.dispatchEvent(passEvent);
    }

    selectDeselectAll(event) {
        if (event.target.checked) {
            //console.log('Check box is checked');
            this.displayFinish = true;
        }
        else {
            console.log('check box is unchecked');
            this.displayFinish = false;
        }
    }

    handleStudentResponsibilities() {
        // console.log('user object' + JSON.stringify(this.user));
        // console.log('Account Id ====> ' + this.userAccountId);
        // console.log('Guardian Id  ===> ' + this.guardianId);
        // console.log('Beneficiary Account Id ===> ' + this.selectedStudentId);

        let recordtypeinfo = this.objectInfo.data.recordTypeInfos;
        let recordTypeId;
        for (var eachRecordtype in recordtypeinfo) {
            //console.log('eachRecordtype ==> ' + eachRecordtype + ' --- name : ' + recordtypeinfo[eachRecordtype].name)
            if (recordtypeinfo[eachRecordtype].name === 'Scholarship Application') {
                recordTypeId = recordtypeinfo[eachRecordtype].recordTypeId;
                break;
            }
        }
        this.loggedinUserId;
        const fields = {};
        fields[CONTRACT_ACCOUNT_NAME.fieldApiName] = this.userAccountId;//this.selectedStudentId;//'001P000001pQUuuIAG';
        fields[CONTRACT_START_DATE.fieldApiName] = new Date();
        fields[CONTRACT_TERM.fieldApiName] = 23;
        fields[CONTRACT_RECORD_TYPE_ID.fieldApiName] = recordTypeId;
        fields[CONTRACT_INTERESTS.fieldApiName] = this.academicInterests;
        fields[CONTRACT_ESSAY_OR_STUDENT_STATEMENT.fieldApiName] = this.essayStudentStatement;
        fields[CONTRACT_GUARDIAN_NAME.fieldApiName] = this.guardianId;
        fields[CONTRACT_PRODUCT_ID.fieldApiName] = this.selectProgramId;
        fields[CONTRACT_BENEFICIARY_ACCOUNT.fieldApiName] = this.selectedStudentId; //this.accountId;
        fields[CONTRACT_STATUS.fieldApiName] = 'Pending Review';

        fields[CONTRACT_BENEFICIARY_QUALIFY.fieldApiName] = this.benefitsQualify;
        fields[CONTRACT_FIRST_IN_FAMILY.fieldApiName] = this.completeHighSchoolOrAttendCollege;
        fields[CONTRACT_MENTOR.fieldApiName] = this.mentor;
        fields[CONTRACT_MENTOR_ORGANIZATION.fieldApiName] = this.mentorOrOrganization;
        fields[CONTRACT_WORKING_WITH_MENTOR.fieldApiName] = this.workingWithMentor;
        fields[CONTRACT_INSTITUTION.fieldApiName] = this.institution;
        fields[CONTRACT_SEMESTER.fieldApiName] = this.semester;

        

        const recordInput = { apiName: CONTRACT_OBJECT.objectApiName, fields };

        createRecord(recordInput)
            .then(contract => {
                console.log('Contract Obj 1 Id : ' + contract.id);
                this.parentId = contract.id;

                //this.saveToFile();
                if (this.parentId != undefined || this.parentId != null) {

                    console.log('Parent Id : '+this.parentId);
                    // console.log('videoFiles : '+this.videoFiles);
                    // console.log('proofOfBenefitsFiles : '+this.proofOfBenefitsFiles);
                    // console.log('floridaResidentToQualifyFiles : '+this.floridaResidentToQualifyFiles);
                    if (this.videoFiles) {
                        //this.uploadVideoFiles();
                        this.uploadFiles(this.videoFiles[0].documentId);
                    }

                    if(this.proofOfBenefitsFiles){
                        //console.log('uploading  proof of benefits file.................');
                        //this.uploadProofOfBenefitsFiles();
                        this.uploadFiles(this.proofOfBenefitsFiles[0].documentId);
                    }
                    if(this.floridaResidentToQualifyFiles){
                        //console.log('uploading  florida Resident To Qualify file.................');
                        //this.uploadFloridaResidentToQualifyFiles();
                        this.uploadFiles(this.floridaResidentToQualifyFiles[0].documentId);
                    }
                    
                    this.showToast();
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Home'
                        }
                    });
                }
            })
            .catch(error => {
                window.console.log('error---' + JSON.stringify(error.body))
            });
    }


    uploadFiles(documentId) {
        // console.log('before image upload' + this.parentId);
        // console.log('this.videoFiles.fileName : ' + JSON.stringify(this.videoFiles[0].fileName));
        // console.log('this.videoFiles.base64 : ' + JSON.stringify(this.videoFiles[0].base64));

        /*uploadVideo({
            accountId: this.parentId,
            //file: encodeURIComponent(this.videoFiles[0].base64),
            file: encodeURIComponent(this.videoFiles[0].base64),
            fileName: this.videoFiles[0].fileName
        })
            .then(result => {
                console.log('videouploadsuccess::: ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('videouploaderror":: ' + JSON.stringify(error));
                this.error = error.message;
            })*/

        linkFileWithRecord({
            contentDocumentId: documentId,
            recordId: this.parentId
        })
            .then(result => {
                console.log('videouploadsuccess::: ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('videouploaderror":: ' + JSON.stringify(error));
                this.error = error.message;
            })
    }

    /*uploadProofOfBenefitsFiles() {
        // console.log('uploadProofOfBenefitsFiles : before image upload' + this.parentId);
        // console.log('this.proofOfBenefitsFiles.fileName : ' + JSON.stringify(this.proofOfBenefitsFiles[0].fileName));
        // console.log('this.proofOfBenefitsFiles.base64 : ' + JSON.stringify(this.proofOfBenefitsFiles[0].base64));

        uploadVideo({
            accountId: this.parentId,
            //file: encodeURIComponent(this.videoFiles[0].base64),
            file: encodeURIComponent(this.proofOfBenefitsFiles[0].base64),
            fileName: this.proofOfBenefitsFiles[0].fileName
        })
            .then(result => {
                console.log('proof of benefits success::: ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('proof of benefits error":: ' + JSON.stringify(error));
                this.error = error.message;
            })
    }

    uploadFloridaResidentToQualifyFiles() {
        // console.log('uploadFloridaResidentToQualifyFiles before image upload' + this.parentId);
        // console.log('this.floridaResidentToQualifyFiles.fileName : ' + JSON.stringify(this.floridaResidentToQualifyFiles[0].fileName));
        // console.log('this.floridaResidentToQualifyFiles.base64 : ' + JSON.stringify(this.floridaResidentToQualifyFiles[0].base64));

        uploadVideo({
            accountId: this.parentId,
            //file: encodeURIComponent(this.videoFiles[0].base64),
            file: encodeURIComponent(this.floridaResidentToQualifyFiles[0].base64),
            fileName: this.floridaResidentToQualifyFiles[0].fileName
        })
            .then(result => {
                console.log('florida Resident To Qualify success::: ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('florida Resident To Qualify error":: ' + JSON.stringify(error));
                this.error = error.message;
            })
    }*/   

}