import { LightningElement } from 'lwc';
import 'c/spCssLibrary';
import templateOne from './templateOne.html';
import templateTwo from './templateTwo.html';
import templateThree from './templateThree.html';
import templateFour from './templateFour.html';

export default class SpApplication extends LightningElement {

    targetTemplate = templateOne;

    render() {
        return this.targetTemplate;
    }

    renderedCallback() {
        console.log('yyyyyyyyyy');;
        window.scroll(0, 0);
    }

    //1st screen
    studentAndGuardianInformation() {
        this.targetTemplate = templateOne;
    }

    //2nd screen
    financialInformationHandler(event) {
        this.targetTemplate = templateTwo;
    }

    //3rd screen
    studentInterests() {
        this.targetTemplate = templateThree;
    }

    //4th screen
    studentResponsibilites() {
        this.targetTemplate = templateFour;
    }

    //Submit
    finish() {
        this.targetTemplate = templateOne;
    }

    studentName = '';
    studentDateOfBirth = '';
    studentAge = '';

    studentCurrentGrade = '';
    studentGender = '';
    studentEthnicity = '';
    studentAddress = '';
    studentCity = '';

    studentST = '';
    studentZIP = '';
    studentEmailAddress = '';
    studentCellPhone = '';
    studentHomePhone = '';

    studentFloridaResidentYes = '';
    studentFloridaResidentNo = '';
    socialSecurityNumber = '';
    guardianName = '';
    guardianRelationshipToStudent = '';

    guardianStreetAddress = '';
    guardianCity = '';
    guardianST = '';
    guardianZIP = '';
    guardianEmailAddress = '';

    guardianCellPhone = '';
    guardianHomePhone = '';
    guardianWorkPhone = '';
    floridaResidencyDocumentation = '';
    floridaFileUpload = '';

    //Capture Screen property values from Student & Guardian Information ( Screen-1 )
    studentAndGuardianInformationHandler(event) {
        //Fetch 1st screen properties
        if (event.target.name == 'studentName') {
            this.studentName = event.target.value;
            console.log('this.studentName : ' + this.studentName);
        }

        if (event.target.name == 'studentDateOfBirth') {
            this.studentDateOfBirth = event.target.value;
            console.log('this.studentDateOfBirth : ' + this.studentDateOfBirth);
        }

        if (event.target.name == 'studentAge') {
            this.studentAge = event.target.value;
            console.log('this.studentAge : ' + this.studentAge);
        }




        if (event.target.name == 'studentCurrentGrade') {
            this.studentCurrentGrade = event.target.value;
            console.log('this.studentCurrentGrade : ' + this.studentCurrentGrade);
        }

        if (event.target.name == 'studentGender') {
            this.studentGender = event.target.value;
            console.log('this.studentGender : ' + this.studentGender);
        }

        if (event.target.name == 'studentEthnicity') {
            this.studentEthnicity = event.target.value;
            console.log('this.studentEthnicity : ' + this.studentEthnicity);
        }

        if (event.target.name == 'studentAddress') {
            this.studentAddress = event.target.value;
            console.log('this.studentAddress : ' + this.studentAddress);
        }

        if (event.target.name == 'studentCity') {
            this.studentCity = event.target.value;
            console.log('this.studentCity : ' + this.studentCity);
        }




        if (event.target.name == 'studentST') {
            this.studentST = event.target.value;
            console.log('this.studentST : ' + this.studentST);
        }

        if (event.target.name == 'studentZIP') {
            this.studentZIP = event.target.value;
            console.log('this.studentZIP : ' + this.studentZIP);
        }

        if (event.target.name == 'studentEmailAddress') {
            this.studentEmailAddress = event.target.value;
            console.log('this.studentEmailAddress : ' + this.studentEmailAddress);
        }

        if (event.target.name == 'studentCellPhone') {
            this.studentCellPhone = event.target.value;
            console.log('this.studentCellPhone : ' + this.studentCellPhone);
        }

        if (event.target.name == 'studentHomePhone') {
            this.studentHomePhone = event.target.value;
            console.log('this.studentHomePhone : ' + this.studentHomePhone);
        }




        if (event.target.name == 'studentFloridaResidentYes') {
            this.studentFloridaResidentYes = event.target.value;
            console.log('this.studentFloridaResidentYes : ' + this.studentFloridaResidentYes);
        }

        if (event.target.name == 'studentFloridaResidentNo') {
            this.studentFloridaResidentNo = event.target.value;
            console.log('this.studentFloridaResidentNo : ' + this.studentFloridaResidentNo);
        }

        if (event.target.name == 'socialSecurityNumber') {
            this.socialSecurityNumber = event.target.value;
            console.log('this.socialSecurityNumber : ' + this.socialSecurityNumber);
        }

        if (event.target.name == 'guardianName') {
            this.guardianName = event.target.value;
            console.log('this.guardianName : ' + this.guardianName);
        }

        if (event.target.name == 'guardianRelationshipToStudent') {
            this.guardianRelationshipToStudent = event.target.value;
            console.log('this.guardianRelationshipToStudent : ' + this.guardianRelationshipToStudent);
        }




        if (event.target.name == 'guardianStreetAddress') {
            this.guardianStreetAddress = event.target.value;
            console.log('this.guardianStreetAddress : ' + this.guardianStreetAddress);
        }

        if (event.target.name == 'guardianCity') {
            this.guardianCity = event.target.value;
            console.log('this.guardianCity : ' + this.guardianCity);
        }

        if (event.target.name == 'guardianST') {
            this.guardianST = event.target.value;
            console.log('this.guardianST : ' + this.guardianST);
        }

        if (event.target.name == 'guardianZIP') {
            this.guardianZIP = event.target.value;
            console.log('this.guardianZIP : ' + this.guardianZIP);
        }

        if (event.target.name == 'guardianEmailAddress') {
            this.guardianEmailAddress = event.target.value;
            console.log('this.guardianEmailAddress : ' + this.guardianEmailAddress);
        }




        if (event.target.name == 'guardianCellPhone') {
            this.guardianCellPhone = event.target.value;
            console.log('this.guardianCellPhone : ' + this.guardianCellPhone);
        }

        if (event.target.name == 'guardianHomePhone') {
            this.guardianHomePhone = event.target.value;
            console.log('this.guardianHomePhone : ' + this.guardianHomePhone);
        }

        if (event.target.name == 'guardianWorkPhone') {
            this.guardianWorkPhone = event.target.value;
            console.log('this.guardianWorkPhone : ' + this.guardianWorkPhone);
        }

        if (event.target.name == 'floridaResidencyDocumentation') {
            this.floridaResidencyDocumentation = event.target.value;
            console.log('this.floridaResidencyDocumentation : ' + this.floridaResidencyDocumentation);
        }

        if (event.target.name == 'floridaFileUpload') {
            this.floridaFileUpload = event.target.value;
            console.log('this.floridaFileUpload : ' + this.floridaFileUpload);
        }

    }





    //Capture Screen property values from Financial Information ( Screen-2 )
    financialInformationHandler(event) {
    
    }
}