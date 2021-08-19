({

    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid': 'e.c:setExpId'
    },

    handleLogin: function (component, event, helpler) {
        var usernameField = component.find("username");
        var username = component.find("username").get("v.value");
        
        var password = component.find("password").get("v.value");
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");

        startUrl = decodeURIComponent(startUrl);

        action.setParams({ username: username, password: password, startUrl: startUrl });
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            console.log('error : '+rtnValue);
            if (rtnValue !== null) {
                component.set("v.errorMessage", rtnValue);
                component.set("v.showError", true);

                if(rtnValue.includes("Your login attempt has failed. Make sure the username and password are correct")){
                    component.set("v.showEmailErrorMessage", "");
                    component.set("v.showPasswordErrorMessage", " ");
                    component.set("v.showInCorrectPasswordMessage", "Your login attempt has failed. Make sure the username and password are correct");
                }

            }
        });

        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (!$A.util.isEmpty(username)) {
            if (username.match(regExpEmailformat)) {
                component.set("v.showEmailErrorMessage", "");
                usernameField.set("v.errors", [{ message: null }]);
                $A.util.removeClass(username, 'slds-has-error');

            } else {
                $A.util.addClass(usernameField, 'slds-has-error');
                component.set("v.showEmailErrorMessage", "Please enter valid email address");
            }
        } else {
            component.set("v.showEmailErrorMessage", "Email field should not be blank.");
        }

        if (!$A.util.isEmpty(password)) {
            component.set("v.showPasswordErrorMessage", " ");
        } else {
            component.set("v.showPasswordErrorMessage", "Password field should not be blank.");
        }

        $A.enqueueAction(action);
    },

    isBlank: function (str) {
        return (!str || str.length === 0);
    },

    getIsUsernamePasswordEnabled: function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getIsSelfRegistrationEnabled: function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getCommunityForgotPasswordUrl: function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getCommunitySelfRegisterUrl: function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl', rtnValue);
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