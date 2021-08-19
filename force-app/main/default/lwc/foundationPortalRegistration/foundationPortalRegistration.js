import { LightningElement, wire } from 'lwc';
import createPortalUser from '@salesforce/apex/CreatePortalUserController.createPortalUser';
import isExistingUser from '@salesforce/apex/CreatePortalUserController.isExistingUser';
import 'c/fpCssLibrary';

import {  ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FoundationPortalRegistration extends LightningElement {

    firstName = '';
    lastName = '';
    email = '';
    businessName = '';
    orgUserId = '';
    uniqueEmail = false;
    enableSignup = true;

   contactChangeVal(event) {

        if (event.target.label == 'First Name') {
            this.firstName = event.target.value;
        }
        if (event.target.label == 'Last Name') {
            this.lastName = event.target.value;
        }
        if (event.target.label == 'Email') {
            this.email = event.target.value;
            console.log('----------------------------------');
            isExistingUser({email: this.email})
            .then(result => {
                console.log('isExisting Contact : '+result);
                if(result == true){
                    console.log('result: '+result);
                    this.uniqueEmail = true;
                    this.enableSignup = false;
                }else{
                    this.uniqueEmail = false;
                    this.enableSignup = true;
                }
                
            })
            .catch(error => {
                this.error = error;
                this.uniqueEmail = false;
                
                console.log('Error while fetching Contact info:'+this.error);
            });

        }
        if (event.target.label == 'Bunisess Name') {
            this.businessName = event.target.value;
        }
        
        console.log(this.firstName + ' --- ' + this.lastName + ' --- ' + this.email + ' --- ' + this.businessName);
    }

  
    handleClick() {
        console.log('Button clicked');
        //console.log('hi::button invoked'+this.firstName+'--'+this.lastName+' --- email: '+this.email+' -- businessName: '+this.businessName);
        /*createOrgUser().then(result =>{
            console.log('org user => '+result); 
            this.orgUserId = result;
            createPortalUser({firstName: this.firstName, lastName: this.lastName, email: this.email, businessName: this.businessName, orgUserId: this.orgUserId})
            .then(result => {
                //this.contacts = result;
                //console.log('success');
                console.log('$#$#$# => UserId : '+result);
            })
            .catch(error => {
                console.log('Error Generated :'+error);
                this.error = error;
            });
        })
        .catch(error => {    
            console.log('Error Generated :'+error);
            console.error('e.name => ' + error.name );
            console.error('e.message => ' + error.message );
            console.error('e.stack => ' + error.stack );
            this.error = error;
        });*/
        
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isInputsCorrect) {
         //perform success logic
         console.log('form submitting....');
         createPortalUser({firstName: this.firstName, lastName: this.lastName, email: this.email, businessName: this.businessName})
         .then(result => {
             //this.contacts = result;
             //console.log('success');
             console.log('$#$#$# => Userinfo : '+result);
             window.location = '/foundation/s/login/CheckPasswordResetEmail';
             
         })
         .catch(error => {
             console.log('Error Generated :'+error);
             this.error = error;
         });
        }
        

        /*createPortalUser({firstName: this.firstName, lastName: this.lastName, email: this.email, businessName: this.businessName})
            .then(result => {
                //this.contacts = result;
                //console.log('success');
                console.log('$#$#$# => UserId : '+result);
            })
            .catch(error => {
                console.log('Error Generated :'+error);
                this.error = error;
            });*/
        
    }

}