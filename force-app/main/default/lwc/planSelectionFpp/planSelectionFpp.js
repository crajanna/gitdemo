import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {  ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {getRecord, createRecord } from 'lightning/uiRecordApi';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import ACCOUNT_ID_PC from '@salesforce/schema/Account.Id';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import AGE_GRADE from '@salesforce/schema/Contact.Age_Grade__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import CONTRACT_ACCOUNT_NAME from '@salesforce/schema/Contract.AccountId';
import X529_SAVINGS_PLAN from '@salesforce/schema/Contract.X529_Savings_Plan__c';
import X529_SAVINGS_PLAN_OPTION from '@salesforce/schema/Contract.X529_Savings_Plan_Option__c';
import BENEFICIARY_BIRTH_DATE from '@salesforce/schema/Contract.Beneficiary_Birthdate__c';	
import SP_SELECTED_PORTFOLIOS from '@salesforce/schema/Contract.SP_Selected_Portfolios__c';
import SP_INITIAL_CONTRIBUTION from '@salesforce/schema/Contract.Initial_Contribution__c';
import SP_AMOUNT from '@salesforce/schema/Contract.SP_Amount__c';	
import SP_SCHEDULE_REC_CONT from '@salesforce/schema/Contract.SP_Schedule_Recurring_Contribution__c';
import ENROLLMENT_STATUS_C from '@salesforce/schema/Contract.Enrollment_Status__c';
import SP_RECURRING_CONTRIBUTION from '@salesforce/schema/Contract.SP_Schedule_Recurring_Contribution__c';
import SP_INVESTMENT_SETUP from '@salesforce/schema/Contract.SP_Investment_Setup__c';
import SP_FREQUENCY from '@salesforce/schema/Contract.SP_Frequency__c';
import getProductsByPEY from '@salesforce/apex/EpProductController.getProductsByPEY';
import findResourceByRecord from '@salesforce/apex/ResourceController.findResourceByRecord';
import PP_SELECTED_PLANS from '@salesforce/schema/Contract.PP_Selected_Plans__c';

const userFileds = [NAME_FIELD, EMAIL_FIELD, ACCOUNT_ID, USER_CONTACT_ID];
const accountFields = [ACCOUNT_ID_PC];
const PEY_MAX_NUMBER = 19;
export default class PlanSelectionFpp extends NavigationMixin(LightningElement) {

    imagePath = My_Resource + '/img/logo-fl-prepaid-black-320px.png';
    imageFpoGrayPath = My_Resource + '/img/img-fpo-gray.png';
    imageMugFpoPath = My_Resource + '/img/mug-fpo-40px.png';
    imageMugFpoPath160 = My_Resource + '/img/mug-fpo-160px.png';
    imagePathIconHelp = My_Resource + '/img/icon-help.png'; 
    imageFpo90 =  My_Resource + '/img/img-fpo-alt-90px.png';
    imagesymgray= My_Resource + '/img/logo-fl-prepaid-symbol-gray-260px.png';
    isLoading = false;
    userId = Id;
    userName;
    email;
    accountIduser;
    userContactId;
    pey;
    contractYear;
    activeSections = ['PP', 'SP', 'AP'];
    richtext ;
    selectedLevel;
    showAgeBased = false;
    showStaticPortfolios = false;
    showIndFundOptions = false;
    newBeneficiaryDate;
    ageFundAbbr;
    ageGradeValue;
    showSavingsPlanDetails = false;
    showPortfolios = false;
    birthdate = null;
    todaydate;
    age;
    fundAllocListUpdated; 
    totalFAPercentage;   
    contractObjId;
    productList = [];
    investmentOptionsType;
    initialContribution;
    scheduleRecurringContr;
    amountChange;
    spFrequencyOption;
    profileSrcData;
    disablesp= true;

    prepaidSelectionList = [];
    showPlans = false;

    
    prepaidPlansSelectedInfoList =[];

        @wire(getRecord, {
          recordId: Id,
          fields: userFileds
      }) wireuser1({
          error,
          data
      }) {
          if (error) {
            this.error = error ; 
          } else if (data) {
              console.log( JSON.stringify( data.fields ) );
              this.userName = data.fields.Name.value;
              this.accountIduser = data.fields.AccountId.value;
              this.email = data.fields.Email.value;
              this.userContactId = data.fields.ContactId.value;
            }
      }

      
    @wire(getRecord, {
      recordId:'$accountIduser',
      fields: accountFields
  }) wireAccount({
      error,
      data
  }) {
      if (error) {
         this.error = error ; 
      } else if (data) {
           this.accountIdpc = data.fields.Id.value;
           findResourceByRecord({recordId: this.accountIdpc,                
                                description: 'Profile_Logo'
       }).then(result => {
             this.profileSrcData = result;
       }).catch(error => {
          console.log('profile upload error..'+JSON.stringify(error));   
      });

        }
  }


    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

    @wire(getPicklistValues,
      {
          recordTypeId: '$contactInfo.data.defaultRecordTypeId', 
          fieldApiName: AGE_GRADE
      }
  )
  ageGradeListValues;


  get investmentOptions() {
    return [
        { label: 'Set Up Investment', value: 'Set Up Investment' },
        { label: 'Mail in Payment', value: 'Mail in Payment' },           
    ];
}

get frequencyOptions() {
  return [
      { label: 'Weekly', value: 'Weekly' },
      { label: 'Biweekly', value: 'Biweekly' },
      { label: 'Monthly', value: 'Monthly' },           
      { label: 'Quaterly', value: 'Quaterly' },           
      { label: 'Semiannual', value: 'Semiannual' },           
      { label: 'Annual', value: 'Annual' },                      
  ];
}


   handleInvestmentOptionsChange(event){
    this.investmentOptionsType = event.detail.value;
    window.console.log('this.planPayment---' + this.investmentOptionsType )
}

    sphandler(event) {
        const selection = event.detail;
        window.console.log('selected value SavingsPlanComponent ===> '+selection);
        this.selectedLevel = selection;
        if (this.selectedLevel === "SIMPLIFIED") {
            this.showAgeBased = true;
            this.showStaticPortfolios = false;
            this.showIndFundOptions = false;
            this.showPortfolios = true;
          } else if (this.selectedLevel === "INTERMEDIATE") {
            this.showAgeBased = true;
            this.showStaticPortfolios = true;
            this.showIndFundOptions = false;
            this.showPortfolios = true;
          } else if (this.selectedLevel === "EXPERT") {
            this.showAgeBased = true;
            this.showStaticPortfolios = true;
            this.showIndFundOptions = true;
            this.showPortfolios = true;
          } else {
            this.showAgeBased = false;
            this.showStaticPortfolios = false;
            this.showIndFundOptions = false;
            this.showPortfolios = false;
          }
     }


     handleNewBeneficiaryDateChange(event){
      this.showPlans = true;
      this.disablesp = true;
      this.richtext = "<img src="+this.imageFpo90+" />Default <br>Value";
        if(event.detail.value!=null){
          this.birthdate = new Date(event.detail.value);
          this.disablesp = false;
          this.age = this.getAge(this.birthdate);

          window.console.log('age--:'+this.age);

          this.setAgeGrageValue();
          console.log('ageFundAbr..' + this.ageFundAbbr);
        }
       

     }

     handleSavingsPlanSelection(event){
        console.log("this.birthdate,"+this.birthdate);
        if(this.birthdate==null){
          this.showToast('Error', 'Please enter Beneficiary Birth Date', 'error');
        }else{
          this.showSavingsPlanDetails = event.target.checked;     
        }
    }

     handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        window.console.log(openSections);
    }

    onAllocationSelection(event){
      this.fundAllocListUpdated = event.detail.fundAllocListUpdated;
      this.totalFAPercentage =event.detail.totalFAPercentage;
      window.console.log("plan selection this.fundAllocListUpdated......"+JSON.stringify(this.fundAllocListUpdated));
  }
   handleInitialContributionChange(event){
    this.initialContribution = event.detail.value;
   }

   handleScheduleRecurringContr(event){
    this.scheduleRecurringContr = event.target.checked;
   }

   handleAmountChange(event){
     this.amountChange =event.target.value;
   }

   
   handleSPFrequncyOptionsChange(event){
    this.spFrequencyOption = event.detail.value;
}

    savePlanSelection(){


      this.isLoading = true;
      this.createContractRecord();
     
    //   if( this.totalFAPercentage != 100){
    //     this.dispatchEvent(
    //         new ShowToastEvent({
    //             title: 'Error saving data',
    //             message: 'ALLOCATED total percentage must be equal to 100%',
    //             variant: 'error'
    //         })
    //     );
    // }else{
    //    this.isLoading = true;
    //     this.createContractRecord();
    //   }
  
    }

    createContractRecord(){
      console.log("savePlanSelection");
      console.log("this.accountIduser-"+ this.accountIduser);
      console.log("this.showSavingsPlanDetails-"+ this.showSavingsPlanDetails);
      console.log("this.fundAllocListUpdated-"+ this.fundAllocListUpdated);
      console.log("this.birthdate-"+ this.birthdate);
      console.log("this.selectedLevel-"+ this.selectedLevel);
      console.log("this.investmentOptionsType-"+ this.investmentOptionsType); 
      console.log("this.initialContribution-"+ this.initialContribution); 
      console.log("this.scheduleRecurringContr-"+ this.scheduleRecurringContr);
      console.log("this.amountChange-"+ this.amountChange); 
      console.log("this.spFrequencyOption-"+ this.spFrequencyOption);
      console.log("JSON.stringify(this.prepaidPlansSelectedInfoList)-"+ JSON.stringify(this.prepaidPlansSelectedInfoList));
     
         const fields = {};
         fields[CONTRACT_ACCOUNT_NAME.fieldApiName] = this.accountIduser;

        if(this.showSavingsPlanDetails){
          fields[SP_SELECTED_PORTFOLIOS.fieldApiName] = JSON.stringify(this.fundAllocListUpdated);
          fields[SP_INVESTMENT_SETUP.fieldApiName] = this.investmentOptionsType;
          fields[SP_INITIAL_CONTRIBUTION.fieldApiName] = this.initialContribution;
          fields[SP_RECURRING_CONTRIBUTION.fieldApiName] = this.scheduleRecurringContr;
          fields[SP_AMOUNT.fieldApiName] = this.amountChange;
          fields[SP_FREQUENCY.fieldApiName] = this.spFrequencyOption;  
          fields[X529_SAVINGS_PLAN.fieldApiName] =  this.showSavingsPlanDetails;
          fields[X529_SAVINGS_PLAN_OPTION.fieldApiName] = this.selectedLevel;
        }


         fields[BENEFICIARY_BIRTH_DATE.fieldApiName] = this.birthdate;      
         fields[ENROLLMENT_STATUS_C.fieldApiName] = "Plan Selection";
         fields[PP_SELECTED_PLANS.fieldApiName] = JSON.stringify(this.prepaidPlansSelectedInfoList);

         const recordInput = { apiName: CONTRACT_OBJECT.objectApiName, fields };

         createRecord(recordInput)
         .then(contract => {
            window.console.log('contract ===> ' + JSON.stringify(contract));
            console.log('Contract Obj 1 Id : ' + contract.id);
            this.isLoading = false;
            this.contractObjId=contract.id;
            const passEvent = new CustomEvent('next', {
              detail:{contractId:this.contractObjId} 
          }); 
           this.dispatchEvent(passEvent);
             
         })
         .catch(error => {
          this.isLoading = false;
            window.console.log('error---' + JSON.stringify(error.body) )
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Error creating record',
                     message: error.body.message,
                     variant: 'error',
                 }),
             );
         });
    }


    handleLearnMoreInvOptions(event){
      window.open("https://www.myfloridaprepaid.com/savings-plan/investment-options/", "_blank");
    }


    isLeapYear(year) {
      var d = new Date(year, 1, 28);
      d.setDate(d.getDate() + 1);
      return d.getMonth() == 1;
  }
  
   getAge(date) {
      var d = new Date(date), now = new Date();
      var currentMonth = now.getMonth();
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
      return Math.floor(years + days / (this.isLeapYear(eofy.getFullYear()) ? 366 : 365));
  }

  handePrepaidPlanSelection(event){
   if(event.target.checked){
      this.prepaidSelectionList.push(event.target.accessKey);
   }else{
    this.prepaidSelectionList = this.prepaidSelectionList.filter(value => value !== event.target.accessKey);
    this.prepaidPlansSelectedInfoList = this.prepaidPlansSelectedInfoList.filter(function( obj ) {
                                                          return obj.id !== event.target.accessKey;
                                                      });
   }
   console.log('JSON.remvoe..' + JSON.stringify(this.prepaidPlansSelectedInfoList));  
   this.template.querySelectorAll('[data-element="prepaid-radiogroup"]')
          .forEach(element => { 
                  if(!this.prepaidSelectionList.includes(element.name)){
                      element.checked = false;
                      element.disabled = true;
                  }else{
                    element.disabled = false;
                  }
                  
    });
                  

  }

  handlePaymentOptionSelected(event){
    console.log('selected value..' + event.target.value);
    this.template.querySelectorAll('[data-element="prepaid-checkbox"]')
    .forEach(element => { 
            if(element.id.split('-')[0] == event.target.value.split('-')[0]){
                element.checked = true;
                if(!this.prepaidSelectionList.includes(element.id.split('-')[0])){
                  this.prepaidSelectionList.push(element.id.split('-')[0]);
              }
              var prepaidPlansSelectedInfo ={};
              prepaidPlansSelectedInfo.id=element.id.split('-')[0];
              prepaidPlansSelectedInfo.productId = event.target.value.split('-')[1];
              prepaidPlansSelectedInfo.productFamily = event.target.value.split('-')[2];
              prepaidPlansSelectedInfo.paymentOption = event.target.value.split('-')[3];
              this.prepaidPlansSelectedInfoList.push(prepaidPlansSelectedInfo);
              console.log('JSON.stringify11..' + JSON.stringify(this.prepaidPlansSelectedInfoList));  
            }        
     });

  }

  setAgeGrageValue(){

    var d = new Date(this.birthdate), now = new Date();
    var currentMonth = now.getMonth();
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

      if(this.age== -1){
        this.pey = parseFloat(d.getFullYear() )+ parseFloat(PEY_MAX_NUMBER)+1;
      }else if(this.age==0){
        this.pey = parseFloat(d.getFullYear() )+ parseFloat(PEY_MAX_NUMBER);
      }else{
        this.pey = parseFloat(d.getFullYear() )+ parseFloat(PEY_MAX_NUMBER) - parseFloat(this.age);
      }
    switch (this.age) {
      case -1:
        this.ageGradeValue = "NEWBORN";
        this.ageFundAbbr = 'ABM00';        
        break;
      case 0:
        this.ageGradeValue = "INFANT";
        this.ageFundAbbr = 'ABM00';
        break;
      case 1:
        this.ageGradeValue = "1 YEARS OLD";
        this.ageFundAbbr = 'ABM00';
        break;
      case 2:
        this.ageGradeValue = "2 YEARS OLD";
        this.ageFundAbbr = 'ABM00';
        break;
      case 3:
        this.ageGradeValue = "3 YEARS OLD";
        this.ageFundAbbr = 'ABM00';
        break;
      case 4:
        this.ageGradeValue = "4 YEARS OLD";
        this.ageFundAbbr = 'ABM00';
        break;
      case 5:
        this.ageGradeValue = "KINDERGARTEN";
        this.ageFundAbbr = 'ABM05';
        break;
      case 6:
        this.ageGradeValue = "1ST GRADE";
        this.ageFundAbbr = 'ABM06';
        break;
      case 7:
        this.ageGradeValue = "2ND GRADE";
        this.ageFundAbbr = 'ABM07';
        break;
      case 8:
        this.ageGradeValue = "3RD GRADE";
        this.ageFundAbbr = 'ABM08';
        break;
      case 9:
        this.ageGradeValue = "4TH GRADE";
        this.ageFundAbbr = 'ABM09';
        break;
      case 10:
        this.ageGradeValue = "5TH GRADE";
        this.ageFundAbbr = 'ABM10';
        break;
      case 11:
        this.ageGradeValue = "6TH GRADE";
        this.ageFundAbbr = 'ABM11';
       break;
       case 12:
        this.ageGradeValue = "7TH GRADE";
        this.ageFundAbbr = 'ABM12';
       break;
       case 13:
        this.ageGradeValue = "8TH GRADE";
        this.ageFundAbbr = 'ABM13';
       break;
       case 14:
        this.ageGradeValue = "9TH GRADE";
        this.ageFundAbbr = 'ABM14';
       break;
       case 15:
        this.ageGradeValue = "10TH GRADE";
        this.ageFundAbbr = 'ABM15';
       break;
       case 16:
        this.ageGradeValue = "11TH GRADE";
        this.ageFundAbbr = 'ABM16';
       break;
       case 17:
        this.ageGradeValue = "12TH GRADE";
        this.ageFundAbbr = 'ABM17';
       break;
       case 18:
        this.ageGradeValue = "ADULT";
        this.ageFundAbbr = 'ABM18';
       break;
       case 19:
        this.ageGradeValue = "ADULT";
        this.ageFundAbbr = 'ABM19';
       break;
  }

    // if(this.age<0){
    //   this.ageGradeValue = "NEWBORN";
    //  }
    //  if(this.age==0){
    //   this.ageGradeValue = "INFANT";
    //  }else if(this.age==1){
    //   this.ageGradeValue = "1 YEAR OLD";
    //  }else if(this.age==2){
    //   this.ageGradeValue = "2 YEARS OLD";
    //  }else if(this.age==3){
    //   this.ageGradeValue = "3 YEARS OLD";
    //  }else if(this.age==3){
    //   this.ageGradeValue = "3 YEARS OLD";
    //  }
    //  if(this.age<=4){
    //   this.ageFundAbbr = 'ABM00';
    //  }else if(this.age == 5){
    //   this.ageFundAbbr = 'ABM05';
    //  }else if(this.age == 6){
    //   this.ageFundAbbr = 'ABM06';
    //  }else if(this.age == 7){
    //   this.ageFundAbbr = 'ABM07';
    //  }else if(this.age == 8){
    //   this.ageFundAbbr = 'ABM08';
    //  }else if(this.age == 9){
    //   this.ageFundAbbr = 'ABM09';
    //  }else if(this.age == 10){
    //   this.ageFundAbbr = 'ABM10';
    //  }else if(this.age == 11){
    //   this.ageFundAbbr = 'ABM11';
    //  }else if(this.age == 12){
    //   this.ageFundAbbr = 'ABM12';
    //  }else if(this.age == 13){
    //   this.ageFundAbbr = 'ABM13';
    //  }else if(this.age == 14){
    //   this.ageFundAbbr = 'ABM14';
    //  }else if(this.age == 15){
    //   this.ageFundAbbr = 'ABM15';
    //  }else if(this.age == 16){
    //   this.ageFundAbbr = 'ABM16';
    //  }else if(this.age == 17){
    //   this.ageFundAbbr = 'ABM17';
    //  }else if(this.age == 18){
    //   this.ageFundAbbr = 'ABM18';
    //  }else if(this.age >= 19){
    //   this.ageFundAbbr = 'ABM19';
    //  }

     this.productList = null;
     getProductsByPEY({'pey':this.pey, 'prepaidPricebookIds':null}).then(data =>{
      console.log( JSON.stringify( data ) );
        this.productList = data;
    }).catch(error =>{	
      this.productList = null;
    });	
  }

  showToast(title, message, variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        type: variant
    });
    this.dispatchEvent(evt);
}

}