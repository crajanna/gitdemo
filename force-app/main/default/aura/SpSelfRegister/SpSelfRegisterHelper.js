({
    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid': 'e.c:setExpId'
    },

    handleSelfRegister: function (component, event, helpler) {
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var emailField = component.find("email");
        var email = component.find("email").get("v.value");
        console.log('firstname: ' + firstname + ' --- lastname: ' + lastname + ' --- email: ' + email);
        //var includePassword, password, confirmPassword, action, extraFields;
        var includePassword = component.get("v.includePasswordField");

        var password = null; //component.find("password").get("v.value");
        var confirmPassword = null; //component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        console.log('firstName: ' + firstname);
        console.log('1 startUrl: ' + startUrl);
        startUrl = decodeURIComponent(startUrl);
        console.log('2 startUrl: ' + startUrl);

        //Scholarship portal page CheckPasswordResetEmail lwc component picks up this value
        window.localStorage.setItem('resendEmail', email);
        window.localStorage.setItem('backlink', '');

        action.setParams(
            {
                firstname: firstname,
                lastname: lastname,
                email: email,
                password: password,
                confirmPassword: confirmPassword,
                accountId: accountId,
                regConfirmUrl: regConfirmUrl,
                extraFields: extraFields,
                startUrl: startUrl,
                includePassword: includePassword
            });


           


        action.setCallback(this, function (a) {

            var rtnValue = a.getReturnValue();
            console.log('spSelfRegisterHelper -> rtnValue -> ' + rtnValue);

            if (rtnValue !== null) {
                component.set("v.errorMessage", rtnValue);
                component.set("v.showError", true);
                //component.set("v.showEmailErrorMessage", "Email address already in use");

                if(rtnValue.includes('Your request cannot be processed at this time. The site administrator has been alerted.')){
                    component.set("v.showEmailErrorMessage", "Email address already in use");
                }else{
                    component.set("v.showEmailErrorMessage", "");
                }
            }
            
            if ($A.util.isEmpty(lastname)) {
                component.set("v.showLastNameErrorMessage", "Last Name field should not be blank");
            }else{
                component.set("v.showLastNameErrorMessage", " ");
            }
            
     

            var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            if (!$A.util.isEmpty(email)) {
                if (email.match(regExpEmailformat)) {
                    emailField.set("v.errors", [{ message: null }]);
                    $A.util.removeClass(emailField, 'slds-has-error');

                } else {
                    $A.util.addClass(emailField, 'slds-has-error');
                    component.set("v.showEmailErrorMessage", "Please enter valid email address");
                }
            } else {
                component.set("v.showEmailErrorMessage", "Email field should not be blank.");
            }
        });

        if(!component.get("v.acceptTermsCheck")){
            component.set("v.showTermsErrorMessage", "Please accept terms and conditions."); 
        }else{
            component.set("v.showTermsErrorMessage", " "); 
            $A.enqueueAction(action);
        }       
    },

    getExtraFields: function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({ expId: expId });
            action.setCallback(this, function (a) { });
            $A.enqueueAction(action);
        }
    }
})