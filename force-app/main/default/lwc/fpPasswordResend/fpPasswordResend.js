/**
 * @description       : 
 * @author            : Satishbabu Anupoju@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-07-2021   Satishbabu Anupoju@UserSettingsUnder.SFDoc   Initial Version
**/
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import forgotPassword from '@salesforce/apex/FpForgotPasswordController.forgotPassword';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import 'c/fpCssLibrary';
export default class FpPasswordResend extends LightningElement { @track username;

    logoURL = FoundationImages + '/img/logo-flpp-foundation-color.svg';
    get logo() {
        return this.logoURL;
    }

    handleClick() {
        if (this.username != null) {
            forgotPassword({ username: this.username })
                .then(result => {
                    if(result == true){
                        this.showToast('Success', 'Password Setup mail has been sent to your email.', 'success');
                    }else{
                        this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');    
                    }
                    
                })
                .catch(error => {
                    this.error = error;
                    this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');
                });

        } else {
            this.showToast('Application Error', 'Something went wrong. Contact System Administrator', 'error');
        }
    }


    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );       
    }


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        let v = window.localStorage.getItem('dname');
        console.log('My Daughter name: '+v);
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.username = this.urlStateParameters.username || null;
    }

}