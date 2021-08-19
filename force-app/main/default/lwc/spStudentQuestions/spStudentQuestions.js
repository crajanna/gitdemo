import { LightningElement, api, wire } from 'lwc';
import getProduct from '@salesforce/apex/FPPedgeController.getProduct';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import getScholarshipApplicationDetails from '@salesforce/apex/ScholarshipController.getScholarshipApplicationDetails';

// import saveFile from '@salesforce/apex/LWCExampleController.saveFile';
// import releatedFiles from '@salesforce/apex/LWCExampleController.releatedFiles';
import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import CONTRACT_ACCOUNT_NAME from '@salesforce/schema/Contract.AccountId';
// import CONTRACT_STATUS from '@salesforce/schema/Contract.Status';
import CONTRACT_START_DATE from '@salesforce/schema/Contract.StartDate';
import CONTRACT_TERM from '@salesforce/schema/Contract.ContractTerm';
import CONTRACT_RECORD_TYPE_ID from '@salesforce/schema/Contract.RecordTypeId';
import userId from '@salesforce/user/Id';
import 'c/spCssLibrary';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import linkFileWithRecord from '@salesforce/apex/ScholarshipController.linkFileWithRecord';


export default class SpStudentQuestions extends LightningElement {

    
    @api selectProgramId;
    @api selectedStudentId;
    @api recordId;
    @api guardianId;
    @api accountId;

    id;
    label;
    academicInterests;
    academicInterestsInput;
    communityChampions;
    essayContest;
    allOrganizations;
    allOrganizationsInput;
    studentStatement;
    studentStatementLabel
    videoFileUploader
    videoStatement;
    scholarshipApplication;
    myVal;
    essayOrStudentStatement;
    validity = true;
    errorMessage;
    displayNext = true;
    displayBlackHistoryMonth = false;
    displayBoysAndGirls = false;
    productData;
    productName;
    productImgURL;
    priductDescription;
    productDidYouKnow;
    productLearnMoreURL;
    contractRecord = CONTRACT_OBJECT;
    loggedInUserId = userId;

    fileName = '';
    UploadFile = 'Upload File';
    showLoadingSpinner = false;

    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 25000000;
    errorMsg;
    isTrue = false;
    uploadedVideoId;
    hideUpload = false;
    data;
    parentId;
    strFileName;
    base64Data;
    videoFiles;
    proofOfBenefitsFiles;
    floridaResidentToQualifyFiles;

    proofOfBenefits;
    completeHighSchoolOrAttendCollege;
    mentor;
    mentorOrOrganization;
    workingWithMentor;
    floridaResidentToQualify;
    institution;
    semester;
    benefitsQualify;
    showProofOfBenefits = false;
    showMetorFields = false;

    benefitsQualifyLabel;
    completeHighSchoolOrAttendCollegeLabel;
    mentorLabel;
    mentorOrOrganizationLabel;
    workingWithMentorLabel;
    institutionLabel;
    semesterLabel;
    floridaResidentToQualifyLabel;
    institutionHigherEducationLabel;
    proofOfBenefitsFileName;
    floridaResidentToQualifyFileName;

    value = 'No';

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get acceptedFormats() {
        return ['.vi', '.mp4', '.mov', '.mpeg', '.mpg', '.swf'];
    }
   

    handleChange(event) {
        //benefitsQualify;
        if (event.target.name == 'benefitsQualify') {
            this.benefitsQualify = event.detail.value;
            //console.log('benefitsQualify == ' + this.benefitsQualify);
            if (this.benefitsQualify == 'Yes') {
                this.showProofOfBenefits = true;
            } else {
                this.showProofOfBenefits = false;
            }
        }

        if (event.target.name == 'proofOfBenefits') {
            this.proofOfBenefits = event.detail.value;
            //console.log('proofOfBenefits == ' + this.proofOfBenefits);
        }

        if (event.target.name == 'completeHighSchoolOrAttendCollege') {
            this.completeHighSchoolOrAttendCollege = event.detail.value;
            //console.log('completeHighSchoolOrAttendCollege == ' + this.completeHighSchoolOrAttendCollege);
        }

        if (event.target.name == 'mentor') {
            this.mentor = event.detail.value;
            console.log('mentor == ' + this.mentor);
            if (this.mentor == 'Yes') {
                this.showMetorFields = true;
            } else {
                this.showMetorFields = false;
            }

        }

        if (event.target.name == 'workingWithMentor') {
            this.workingWithMentor = event.detail.value;
            //console.log('workingWithMentor == ' + this.workingWithMentor);
        }

        if (event.target.name == 'institution') {
            this.institution = event.detail.value;
            //console.log('institution == ' + this.institution);
        }

        if (event.target.name == 'semester') {
            this.semester = event.detail.value;
            //console.log('semester == ' + this.semester);
        }

    }
    /*Fetching scholarship details of select application*/
    @wire(getScholarshipApplicationDetails, { productId: '$selectProgramId' })
     //@wire(getScholarshipApplicationDetails, { productId: '01tP0000007bnaqIAA' })
    scholarApplication({ error, data }) {
        if (data) {
            console.log('data : ' + JSON.stringify(data));
            this.scholarshipApplication = data;
            this.id = this.scholarshipApplication.Id;
            this.label = this.scholarshipApplication.Label;
            this.academicInterests = this.scholarshipApplication.Academic_Interests__c;
            this.communityChampions = this.scholarshipApplication.Community_Champions__c;
            this.essayContest = this.scholarshipApplication.Essay_Contest__c;
            this.allOrganizations = this.scholarshipApplication.Organizations_List__c;
            this.studentStatementLabel = this.scholarshipApplication.Student_Statement__c;
            this.tabName = this.scholarshipApplication.Tab_Name__c;
            this.videoStatement = this.scholarshipApplication.Video_Statement__c;

            this.benefitsQualifyLabel = this.scholarshipApplication.Benefits_Qualify__c;
            this.completeHighSchoolOrAttendCollegeLabel = this.scholarshipApplication.First_in_Family__c;
            this.mentorLabel = this.scholarshipApplication.Mentor__c;
            this.mentorOrOrganizationLabel = this.scholarshipApplication.Mentor_Organization__c;
            this.workingWithMentorLabel = this.scholarshipApplication.Working_with_Mentor__c;
            this.institutionLabel = this.scholarshipApplication.Institution__c;
            this.semesterLabel = this.scholarshipApplication.Semester__c;
            this.floridaResidentToQualifyLabel = this.scholarshipApplication.Florida_Resident_to_Qualify__c;
            this.institutionHigherEducationLabel = this.scholarshipApplication.Institution_Higher_Education__c;

            // console.log('this.benefitsQualify --> ' + this.benefitsQualifyLabel);
            // console.log('this.completeHighSchoolOrAttendCollege --> ' + this.completeHighSchoolOrAttendCollegeLabel);
            // console.log('this.mentor --> ' + this.mentorLabel);
            // console.log('this.mentorOrOrganization --> ' + this.mentorOrOrganizationLabel);
            // console.log('this.workingWithMentor --> ' + this.workingWithMentorLabel);
            // console.log('this.institution --> ' + this.institutionLabel);
            // console.log('this.semester --> ' + this.semesterLabel);
            // console.log('this.floridaResidentToQualify --> ' + this.floridaResidentToQualifyLabel);
            // console.log('this.institutionHigherEducation --> ' + this.institutionHigherEducationLabel);
        }
    }

    /* Displaying product details - side component*/
    @wire(getProduct, { productId: '$selectProgramId' })
    getProduct({ error, data }) {
        if (data) {
            this.productData = data;
            this.productName = this.productData.Name;
            this.productImgURL = FoundationImages + '/img/' + this.productData.Pledge_Image__c;
            this.priductDescription = this.productData.Description;
            this.productDidYouKnow = this.productData.Did_You_Know__c;
            this.productLearnMoreURL = this.productData.Learn_More_URL__c;
        }
    }

    /*Validating the rich text editor for both Essay Contest [Black History Month Scholarship] and Student Statement [Boys & Girls Scholarship] fields */
    handleClick(event) {

        if (event.target.name == 'mentorOrOrganization') {
            this.mentorOrOrganization = event.target.value;
            //console.log('mentorOrOrganization == ' + this.mentorOrOrganization);
        }

        if (event.target.name == 'institution') {
            this.institution = event.target.value;
            //console.log(' institution : ' + this.institution);
        }
        if (event.target.name == 'semester') {
            this.semester = event.target.value;
            //console.log(' semester : ' + this.semester);
        }

        

        if (event.target.name == 'studentStatement') {
            this.essayOrStudentStatement = event.target.value;
            console.log('studentStatement -  essayOrStudentStatement : ' + this.essayOrStudentStatement);
        }

        if (event.target.name == 'essayContest') {
            this.essayOrStudentStatement = event.target.value;
            //console.log(' essayOrStudentStatement : ' + this.essayOrStudentStatement);
        }


        //this.essayOrStudentStatement = event.target.value;
        let arr = this.essayOrStudentStatement.split(' ');
        if (arr.length > 500) {
            this.validity = false;
            this.displayNext = false;
            this.errorMessage = "The length of the description has exceeded the maximum limit.";
        } else {
            this.errorMessage = "";
            this.validity = true;
            this.displayNext = true;
        }
    }


    handleStudentQuestions() {


        // console.log('------------------------------ STEP 3 START -----------------------------------------------------');
        // console.log('Step 3 -> Next -> selectedStudentId : ' + this.selectedStudentId);
        // console.log('Step 3 -> Next -> accountId : ' + this.accountId);

        // console.log('Step 3 -> Next -> academicInterests : ' + this.academicInterestsInput);
        // console.log('Step 3 -> Next -> essayOrStudentStatement : ' + this.essayOrStudentStatement);
        // console.log('Step 3 -> Next -> guardianId : ' + this.guardianId);

        // console.log('Step 3 -> Next -> benefitsQualify : ' + this.benefitsQualify);
        // console.log('Step 3 -> Next -> completeHighSchoolOrAttendCollege : ' + this.completeHighSchoolOrAttendCollege);
        // console.log('Step 3 -> Next -> mentor : ' + this.mentor);
        // console.log('Step 3 -> Next -> mentorOrOrganization : ' + this.mentorOrOrganization);
        // console.log('Step 3 -> Next -> workingWithMentor : ' + this.workingWithMentor);
        // console.log('Step 3 -> Next -> institution : ' + this.institution);
        // console.log('Step 3 -> Next -> semester : ' + this.semester);
        // console.log('Step 3 -> Next -> proofOfBenefitsFiles : ' + this.proofOfBenefitsFiles);
        // console.log('Step 3 -> Next -> floridaResidentToQualifyFiles : ' + this.floridaResidentToQualifyFiles);
        // console.log('------------------------------ STEP 3 ENDED -----------------------------------------------------');

        const passEvent = new CustomEvent('next', {
            detail: {
                selectedStudentId: this.selectedStudentId,
                academicInterests: this.academicInterestsInput,
                essayOrStudentStatement: this.essayOrStudentStatement,
                guardianId: this.guardianId,
                accountId: this.accountId,
                videoFiles: this.videoFiles,

                benefitsQualify: this.benefitsQualify,
                proofOfBenefitsFiles: this.proofOfBenefitsFiles,
                completeHighSchoolOrAttendCollege: this.completeHighSchoolOrAttendCollege,
                mentor: this.mentor,
                mentorOrOrganization: this.mentorOrOrganization,
                workingWithMentor: this.workingWithMentor,
                institution: this.institution,
                semester: this.semester,
                floridaResidentToQualifyFiles: this.floridaResidentToQualifyFiles,


            }
        });
        this.dispatchEvent(passEvent);
    }

    handleGoBack(event) {
        const passEvent = new CustomEvent('previous', {
            detail: {
                selectedStudentId: this.selectedStudentId,
            }
        });
        this.dispatchEvent(passEvent);
    }

    handleUploadFinished() {
        console.log('video uploaded');
    }

    academicInterestsHandler(event) {
        if (event.target.name === 'academicInterestsInput') {
            this.academicInterestsInput = event.target.value;
            //console.log(' =====academicInterestsInput====== > ' + this.academicInterestsInput);

        }
    }

    handleFileChange(event) {
        // Get the list of uploaded files
        console.log('eventdetailupload:: '+ JSON.stringify(event));
        if(event.target.dataset.id == 'videoFileUploader'){
            this.videoFiles = event.detail.files;
            this.fileName = this.videoFiles[0].name;  
        }else if(event.target.dataset.id == 'proofOfBenefits'){
            this.proofOfBenefitsFiles = event.detail.files;  
            this.proofOfBenefitsFileName = this.proofOfBenefitsFiles[0].name;
        }else if(event.target.dataset.id == 'floridaResidentToQualify'){
            this.floridaResidentToQualifyFiles = event.detail.files; 
            this.floridaResidentToQualifyFileName = this.floridaResidentToQualifyFiles[0].name;          
        }
        
        console.log('uploadedFiles:: '+ JSON.stringify(this.videoFiles));
        
    }


    /*async handleFileChangeold(event) {
        if (event.target.files.length != 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: "test",
                    variant: 'error'
                })
            );
        } else {
            //console.log('$$$ proofOfBenefits  == ' + event.target.name);
            
            if (event.target.name == 'floridaResidentToQualify') {
                this.floridaResidentToQualifyFiles = await Promise.all(
                    [...event.target.files].map(file => this.readFile(file))
                );

                this.floridaResidentToQualifyFileName = this.floridaResidentToQualifyFiles[0].fileName;
                //console.log('strFileName1 --> ' + this.floridaResidentToQualifyFiles[0].fileName);
                //console.log('base64Data1 ---> ' + this.floridaResidentToQualifyFiles[0].base64);
            }else 
            if (event.target.name == 'proofOfBenefits') {
                this.proofOfBenefitsFiles = await Promise.all(
                    [...event.target.files].map(file => this.readFile(file))
                );

                this.proofOfBenefitsFileName = this.proofOfBenefitsFiles[0].fileName;
                //console.log('strFileName1 --> ' + this.proofOfBenefitsFiles[0].fileName);
                //console.log('base64Data1 ---> ' + this.proofOfBenefitsFiles[0].base64);
            } else {
                this.videoFiles = await Promise.all(
                    [...event.target.files].map(file => this.readFile(file))
                );

                this.fileName = this.videoFiles[0].fileName;
                //console.log('strFileName1 --> ' + this.videoFiles[0].fileName);
                //console.log('base64Data1 ---> ' + this.videoFiles[0].base64);
            }


        }
    }

    readFile(fileSource) {
        return new Promise((resolve, reject) => {
            const fileReader = new FileReader();
            const fileName = fileSource.name;
            fileReader.onerror = () => reject(fileReader.error);
            fileReader.onload = () => resolve({ fileName, base64: fileReader.result.split(',')[1] });
            fileReader.readAsDataURL(fileSource);
        });
    }*/


    // getting file 
    // handleFilesChange(event) {
    //     if (event.target.files.length > 0) {
    //         this.filesUploaded = event.target.files;
    //         this.fileName = event.target.files[0].name;
    //         console.log('filename: ' + this.fileName);
    //         this.handleSave();
    //     }

    // }

    // handleSave() {
    //     //alert('hi');
    //     if (this.filesUploaded.length > 0) {
    //         this.uploadHelper();
    //     }
    //     else {
    //         this.fileName = 'Please select file to upload!!';
    //     }
    // }

    // uploadHelper() {
    //     this.file = this.filesUploaded[0];
    //     if (this.file.size > this.MAX_FILE_SIZE) {
    //         errorMsg
    //         window.console.log('File Size is to long');
    //         return;
    //     }
    //     //this.showLoadingSpinner = true;
    //     // create a FileReader object 
    //     this.fileReader = new FileReader();
    //     // set onload function of FileReader object  
    //     this.fileReader.onloadend = (() => {
    //         this.fileContents = this.fileReader.result;
    //         let base64 = 'base64,';
    //         this.content = this.fileContents.indexOf(base64) + base64.length;
    //         this.fileContents = this.fileContents.substring(this.content);
    //         //console.log('this.fileContents ==> '+this.fileContents);
    //         // call the uploadProcess method 
    //         //this.saveToFile();
    //     });

    //     this.fileReader.readAsDataURL(this.file);

    //     this.strFileName = this.file.name;
    //     this.base64Data = encodeURIComponent(this.fileContents);

    //     console.log('strFileName --> ' + this.file.name);
    //     console.log('base64Data ---> ' + this.base64Data);

    //     this.fileName = this.fileName + ' has been added successfully';
    //     this.isTrue = true;
    //     this.showLoadingSpinner = false;

    //}


    // handleCreateContract() {
    //     const fields = {};
    //     fields[CONTRACT_ACCOUNT_NAME.fieldApiName] = '001P000001pQUuuIAG';
    //     //fields[CONTRACT_STATUS.fieldApiName] = 'Draft';
    //     fields[CONTRACT_START_DATE.fieldApiName] = new Date();;
    //     fields[CONTRACT_TERM.fieldApiName] = 18;
    //     fields[CONTRACT_RECORD_TYPE_ID.fieldApiName] = '012P0000002KENkIAO';

    //     const recordInput = { apiName: CONTRACT_OBJECT.objectApiName, fields };
    //     createRecord(recordInput)
    //         .then(contract => {
    //             window.console.log('contract ===> ' + JSON.stringify(contract));
    //             console.log('Contract Obj 1 Id : ' + contract.id);
    //             this.parentId = contract.id;
    //             this.saveToFile();

    //         })
    //         .catch(error => {
    //             window.console.log('error---' + JSON.stringify(error.body))
    //         });
    // }


    handleResetVideo(event) {
        var chkVal = event.target.value;
        console.log('chkVal : ' + chkVal);

        if (chkVal == 'true') {
            console.log('Changing value....');
            this.isTrue = false;
            this.data = '';
            this.UploadFile = 'Upload Video';
            this.fileName = '';
        }
    }

}