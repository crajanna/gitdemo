import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import forgotPassword from '@salesforce/apex/FpForgotPasswordController.forgotPassword';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import communityBasePath from '@salesforce/community/basePath';
import 'c/fpCssLibrary';
export default class FpVerifyEmail extends LightningElement {



    @track username;

    logoURL = FoundationImages + '/img/logo-flpp-foundation-color.svg';
    get logo() {
        return this.logoURL;
    }

    handleClick() {
        if (this.username != null) {
            console.log('username not null: ' + this.username);
            forgotPassword({ username: this.username })
                .then(result => {
                    console.log('Password sent successfully::?:: ' + result);
                    //window.location = communityBasePath+'/login/CheckPasswordResetEmail?username='+this.username;
                    
                    this.showToast('Success', 'Password setup mail has been sent to your inbox.', 'success');
                })
                .catch(error => {
                    console.log('Error Generated :' + error);
                    this.error = error;
                    this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');
                });

        } else {
            console.log('username null');
            this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');
        }

    }


    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            type: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

 
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.username = this.urlStateParameters.username || null;
        //console.log('setParametersBasedOnUrl -> username : '+this.username);
    }

}