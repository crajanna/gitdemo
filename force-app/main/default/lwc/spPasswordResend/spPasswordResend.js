import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import forgotPassword from '@salesforce/apex/FpForgotPasswordController.forgotPassword';

import { NavigationMixin } from 'lightning/navigation';

import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import 'c/spCssLibraryNew';

export default class SpPasswordResend extends NavigationMixin(LightningElement) {

    @track username;
    //logoURL = FoundationImages + '/img/logo-flpp-foundation-color.svg';
    logoURL = FoundationImages + '/img/logo-fl-prepaid-black-320px.png';
    
    isLoading =false;
    showSuccessMessage = false;
    get logo() {
        return this.logoURL;
    }

    handleClick() {
        this.isLoading =true;
        if (this.username != null) {
            console.log('user name: '+this.username);
            forgotPassword({ username: this.username })
                .then(result => {
                    console.log('result ==> '+JSON.stringify(result));
                    if (result == true) {
                        this.showSuccessMessage = true;
                        this.isLoading =false;
                    //    this.showToast('Success', 'Password Setup mail has been sent to your email.', 'success');
                    } else {
                        this.isLoading =false;
                        // this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');
                    }
                })
                .catch(error => {
                    this.isLoading =false;
                    //console.log('error: '+JSON.stringify(error));
                    this.error = error;
                    // this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');
                });

        } else {
            this.isLoading =false;
            this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');
        }
    }


    showToast(title, message, variant) {
        console.log('showToast called -> title:'+title+' --- message : '+message+' --- variant : '+variant);
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    backlink;
    showForgotPasswordContent = false;
    showSelfRegistrationContent = false;
    connectedCallback() {
        this.username = window.localStorage.getItem('resendEmail');
        this.backlink = window.localStorage.getItem('backlink');
        console.log('backlink => '+this.backlink);
        if(this.backlink){
            console.log(' if backlink : '+this.backlink );
            this.showForgotPasswordContent = true;
            //this.showSelfRegistrationContent = false;
            //window.localStorage.removeItem('backlink');
        }// }else{
        //     console.log(' else backlink : '+this.backlink );
        //     this.showForgotPasswordContent = false;
        //     this.showSelfRegistrationContent = true;
        // }

        console.log('this.showForgotPasswordContent ==> '+this.showForgotPasswordContent);
        console.log('this.showSelfRegistrationContent ==> '+this.showSelfRegistrationContent);
    }


       
    handleLogin(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'login'
            }
        });
    }

}