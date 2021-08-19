import { LightningElement, track } from 'lwc';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import changePassword from '@salesforce/apex/FpChangePasswordController.changePassword';

export default class FpSetupPasswordLwc extends LightningElement {

    @track isLength = false;
    @track isUpperLowerCase = false;
    @track isNumber = false;
    @track isSpecialChar = false;
    @track isPasswordMatch = false;
    error;
    password = '';
    confirmPassword = '';
    logoURL = FoundationImages + '/img/logo-flpp-foundation-color.svg';

    get logo(){
        //console.log('FPCF_LOGO : '+this.logoURL);
        return this.logoURL;
    } 
     
    handlePassword(event){
        var password = event.target.value;
        var minMaxLength = /^[\s\S]{8,32}$/,
        upper = /[A-Z]/,
        lower = /[a-z]/,
        number = /[0-9]/,
        special = /[ !"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]/;

        if(minMaxLength.test(password)){
            this.isLength = true;
        }else{
            this.isLength = false;
        }

        if(upper.test(password) && lower.test(password)){
            this.isUpperLowerCase = true;
        }else{
            this.isUpperLowerCase = false;
        }

        if(number.test(password)){
            this.isNumber = true;
        }else{
            this.isNumber = false;
        }

        if(special.test(password)){
            this.isSpecialChar = true;
        }else{
            this.isSpecialChar = false;
        }

        if(this.isLength && this.isUpperLowerCase && this.isNumber && this.isSpecialChar){
            this.password = password;
        }else{
            this.password = '';
        }
    }

    handleConfirmPassword(event){
        this.confirmPassword = event.target.value;
        if(this.password != undefined && (this.password === this.confirmPassword)){
            this.isPasswordMatch = true;
        }else{
            this.isPasswordMatch = false;
        }
    }

    handleContinue(){
        if(this.password != undefined && this.confirmPassword != undefined){
            changePassword({ newPassword: this.password, verifyNewPassword: this.confirmPassword, oldpassword: '12345' })
            .then(result=>{
                console.log('success: '+result)
            }).catch(error=>{
                console.log("error in handle continue: "+JSON.stringify(error));
                this.error = error.body.message;
            })
        }
    }
}