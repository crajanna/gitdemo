import { LightningElement, api, wire } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/FoundationImages';
import { CurrentPageReference } from 'lightning/navigation';

import 'c/spCssLibrary';

export default class SpScholarshipWizard extends LightningElement {
    pledgeSteps = [
        { label: "1. Student & Guardian Information", value: "1" },
        { label: "2. Guardian Information", value: "2" },
        { label: "3. Scholarship Requirements", value: "3" },
        { label: "4. Student Responsibilites", value: "4" },
    ];

    selectProgramId;
    selectedStudentId;
    accountId;
    guardianId;
    currentPageReference = null;
    urlStateParameters = null;
    imageSymbolGray = My_Resource + '/img/logo-flpp-symbol-gray.svg';

    currentPage;
    currentStep = "1";
    currentIndex = 0;
    currentStepTitle = "Student & Guardian Information";
    displayScholarshipResponsibilities = true;
    
    @wire(CurrentPageReference)
    currentPageReference;
    base64Data;
    base64Data1;
    academicInterests;
    videoFileUploader;
    essayStudentStatement;
    videoFiles;
    proofOfBenefitsFiles;
    floridaResidentToQualifyFiles;


    benefitsQualify;
    studentFamilyQualifyBenefits;
    proofOfBenefits;
    completeHighSchoolOrAttendCollege;
    mentor;
    mentorOrOrganization;
    workingWithMentor;
    floridaResidentToQualifyForAFlorida;
    institution;
    semester;


    renderedCallback() {
        window.scroll(0, 0);
    }
    
    connectedCallback() {
        this.selectProgramId = this.currentPageReference.state.selectProgramId;
        console.log('Wizard = > this.selectProgramId => '+this.selectProgramId);
        window.scroll(0, 0);
    }

    get studentGuardianInformationStep() {
        console.log('this.pledgeSteps[0].value => '+this.pledgeSteps[0].value);
        return this.currentStep == this.pledgeSteps[0].value;
    }

    get guardianInformationStep() {
        return this.currentStep == this.pledgeSteps[1].value;
    }

    get scholarshipRequirementStep() {
        return this.currentStep == this.pledgeSteps[2].value;
    }

    get studentResponsibilitesStep() {
        return this.currentStep == this.pledgeSteps[3].value;
    }

  
    
    

    goToNextStep(event) {

        this.benefitsQualify = event.detail.benefitsQualify;
        //console.log('@@@ Wizard ===> benefitsQualify ===> '+this.benefitsQualify);

        this.proofOfBenefits = event.detail.proofOfBenefits;
        //console.log('@@@ Wizard ===> proofOfBenefits ===> '+this.proofOfBenefits);

        this.completeHighSchoolOrAttendCollege = event.detail.completeHighSchoolOrAttendCollege;
        //console.log('@@@ Wizard ===> completeHighSchoolOrAttendCollege ===> '+this.completeHighSchoolOrAttendCollege);

        this.mentor = event.detail.mentor;
        //console.log('@@@ Wizard ===> mentor ===> '+this.mentor);

        this.mentorOrOrganization = event.detail.mentorOrOrganization;
        //console.log('@@@ Wizard ===> accountId ===> '+this.mentorOrOrganization);

        this.workingWithMentor = event.detail.workingWithMentor;
        //console.log('@@@ Wizard ===> workingWithMentor ===> '+this.workingWithMentor);

        this.institution = event.detail.institution;
        //console.log('@@@ Wizard ===> institution ===> '+this.institution);

        this.semester = event.detail.semester;
        //console.log('@@@ Wizard ===> semester ===> '+this.semester);

        this.accountId = event.detail.accountId;
        //console.log('@@@ Wizard ===> accountId ===> '+this.accountId);

        this.selectedStudentId = event.detail.selectedStudentId;
        //console.log('@@@ Wizard ===> selectedStudentId ===> '+this.selectedStudentId);

        this.guardianId = event.detail.guardianId;
        //console.log('@@@ Wizard ===> guardianId ===> '+this.guardianId);

        this.base64Data = event.detail.base64Data;
        //console.log('@@@ Wizard ===> base64Data ===> '+this.base64Data);
        
        
        if(event.detail.floridaResidentToQualifyFiles){
            this.floridaResidentToQualifyFiles = event.detail.floridaResidentToQualifyFiles;

            // if(this.floridaResidentToQualifyFiles && this.floridaResidentToQualifyFiles.length != 0) {
            //     console.log('@@@ Wizard ===> this.floridaResidentToQualifyFiles[0].fileName ===> '+this.floridaResidentToQualifyFiles[0].fileName);
            //     console.log('@@@ Wizard ===> this.floridaResidentToQualifyFiles[0].base64 ===> '+this.floridaResidentToQualifyFiles[0].base64);
            // }
        }

        if(event.detail.proofOfBenefitsFiles){
            this.proofOfBenefitsFiles = event.detail.proofOfBenefitsFiles;

            // if(this.proofOfBenefitsFiles && this.proofOfBenefitsFiles.length != 0) {
            //     console.log('@@@ Wizard ===> this.proofOfBenefitsFiles[0].fileName ===> '+this.proofOfBenefitsFiles[0].fileName);
            //     console.log('@@@ Wizard ===> this.proofOfBenefitsFiles[0].base64 ===> '+this.proofOfBenefitsFiles[0].base64);
            // }
        }
   


        if(event.detail.videoFiles){
            this.videoFiles = event.detail.videoFiles;

            // if(this.videoFiles && this.videoFiles.length != 0) {
            //     console.log('@@@ Wizard ===> this.videoFiles[0].fileName ===> '+this.videoFiles[0].fileName);
            //     console.log('@@@ Wizard ===> this.videoFiles[0].base64 ===> '+this.videoFiles[0].base64);
            // }
        }
   
        this.academicInterests = event.detail.academicInterests;
        //console.log('@@@ Wizard ===> academicInterests ===> '+this.academicInterests);

        // this.videoFileUploader = event.detail.videoFileUploader;
        // console.log('@@@ Wizard ===> videoFileUploader ===> '+this.videoFileUploader);
        
        this.essayStudentStatement = event.detail.essayOrStudentStatement;
        //console.log('@@@ Wizard ===> essayStudentStatement ===> '+this.essayStudentStatement);

        //console.log('@@@ Wizard ===> selectProgramId ===> '+this.selectProgramId);

        if (this.currentIndex + 1 == this.pledgeSteps.length) {
            this.currentStep = "1";
            this.currentIndex = 0;
            this.currentStepTitle = "Student & Guardian Information";
        } else {
            this.currentIndex++;
            this.currentStep = this.pledgeSteps[this.currentIndex].value;
            this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;
        }
    }

    goToPreviousStep(event) {
        this.selectedStudentId = event.detail.selectedStudentId;
        //console.log('@@@ selectedStudentId ===> '+this.selectedStudentId);
        this.currentIndex--;
        this.currentStep = this.pledgeSteps[this.currentIndex].value;
        this.currentStepTitle = this.pledgeSteps[this.currentIndex].label;
    }
}