import { LightningElement, api, wire } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import findResourceByRecord from '@salesforce/apex/ResourceController.findResourceByRecord';

import 'c/cssLibraryFpp';

const accountFields = ['Account.Name', 'Account.PersonBirthdate', 'Account.PersonEmail', 'Account.Phone', 
                       'Account.BillingStreet', 'Account.BillingCity', 'Account.BillingState', 'Account.BillingStateCode', 'Account.BillingPostalCode', 'Account.Residency_Validated__c'];

export default class BeneficiaryInfoComponent extends NavigationMixin(LightningElement) {
    imagecirclefpo30= My_Resource + '/img/circle-fpo-30px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imageiconcheck20 = My_Resource + '/img/icon-check-20px.png';

    @api recordId;
    accDetails = {
        accountName: "",
        dob:"",
        phone: "",
        email: "",
        floridaResident:"",
        address1: "",
        address2: "",
        city: "",
        state: "",
        zip: "",
        ageGrade:"",
        residencyStatus:""
    };

    profileData;


    @wire(getRecord, {
        recordId: '$recordId',
        fields: accountFields
    }) wireAccount({
        error,
        data
    }) {
        if (error) {
        } else if (data) {
            console.log(JSON.stringify(data));
            if (data && data.fields) {
                var result = data.fields;
                this.accDetails = {
                    accountName: result.Name.value ? result.Name.value : null,
                    dob: result.PersonBirthdate.value ? result.PersonBirthdate.value : null,
                    email: result.PersonEmail.value ? result.PersonEmail.value : null,
                    phone: result.Phone.value ? result.Phone.value : null,
                    street: result.BillingStreet.value ? result.BillingStreet.value : null,
                    city: result.BillingCity.value ? result.BillingCity.value : null,
                    state: result.BillingStateCode.value ? result.BillingStateCode.value : null,
                    zip: result.BillingPostalCode.value ? result.BillingPostalCode.value : null,
                    ageGrade: this.getAgeValue(result.PersonBirthdate.value) +"/"+ this.getGrade(result.PersonBirthdate.value),
                    residencyStatus: result.Residency_Validated__c.value? result.Residency_Validated__c.value : null
                };

                findResourceByRecord({
                    recordId:  '001P000001ouR6NIAU',
                    description: 'Profile_Logo'
                }).then(result => {
                    console.log('profile upload ..' + JSON.stringify(result));

                    this.profileData = result;
                }).catch(error => {
                    console.log('profile upload error..' + JSON.stringify(error));
                });

            }

        }
    }


    getAgeValue(date){
        var age = this.getAge(date);
        if(age == -1){
            age = "NEWBORN";
        }
        else if(age == 0){
            age = "INFANT";
        }else{
            age = age + " Years";
        }
        return age;
    }

    getGrade(date){
  
        var age = this.getAge(date);
        var ageGradeValue;
        switch (age) {
          case -1:
            ageGradeValue = "NEWBORN";
            break;
          case 0:
            ageGradeValue = "INFANT";
            break;
          case 1:
            ageGradeValue = "1 YEARS OLD";
            break;
          case 2:
            ageGradeValue = "2 YEARS OLD";
            break;
          case 3:
            ageGradeValue = "3 YEARS OLD";
            break;
          case 4:
            ageGradeValue = "4 YEARS OLD";
            break;
          case 5:
            ageGradeValue = "KINDERGARTEN";
            break;
          case 6:
            ageGradeValue = "1st GRADE";
            break;
          case 7:
            ageGradeValue = "2nd GRADE";
            break;
          case 8:
            ageGradeValue = "3rd GRADE";
            break;
          case 9:
            ageGradeValue = "4th GRADE";
            break;
          case 10:
            ageGradeValue = "5th GRADE";
            break;
          case 11:
            ageGradeValue = "6th GRADE";
           break;
           case 12:
            ageGradeValue = "7th GRADE";
           break;
           case 13:
            ageGradeValue = "8th GRADE";
           break;
           case 14:
            ageGradeValue = "9th GRADE";
           break;
           case 15:
            ageGradeValue = "10th GRADE";
           break;
           case 16:
            ageGradeValue = "11th GRADE";
           break;
           case 17:
            ageGradeValue = "12th GRADE";
           break;
           case 18:
            ageGradeValue = "ADULT";
           break;
           case 19:
            ageGradeValue = "ADULT";
           break;
      }
      return ageGradeValue;
    
   }


   getAge(date) {
    var d = new Date(date), now = new Date();
    var eofyear = now.getFullYear();
    if(d.getMonth()< now.getMonth()){
      eofyear =  now.getFullYear()-1;
    }
    var eofy = new Date(eofyear+"-08-31");
    var years = eofy.getFullYear() - d.getFullYear();
    d.setFullYear(d.getFullYear() + years);
    if (d > eofy) {
        years--;
        d.setFullYear(d.getFullYear() - 1);
    }
    var days = (eofy.getTime() - d.getTime()) / (3600 * 24 * 1000);

    console.log('math..'+Math.floor(years + days / (this.isLeapYear(eofy.getFullYear()) ? 366 : 365)));
    return Math.floor(years + days / (this.isLeapYear(eofy.getFullYear()) ? 366 : 365));
}
isLeapYear(year) {
    var d = new Date(year, 1, 28);
    d.setDate(d.getDate() + 1);
    return d.getMonth() == 1;
}

}