({
    qsToEventMap: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleForgotPassword: function (component, event, helpler) {
        var userNameField = component.find("username");
        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var action = component.get("c.forgotPassword");

        //Scholarship portal page CheckPasswordResetEmail lwc component picks up this value
        window.localStorage.setItem('resendEmail', username);
        window.localStorage.setItem('backlink', 'forgotpassword');

        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            console.log('rtn value : '+rtnValue);
            if (rtnValue != null) {
                if(rtnValue == 'Invalid Email Address'){
                    rtnValue = 'Invalid Username';
                }

               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }

       });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }
})