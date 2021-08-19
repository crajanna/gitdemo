({    
         
    save : function (component, event, helper){
          //get all the inputs from form
          var firstname = component.get("v.firstName");
          var lastname = component.get("v.lastName");
          //Error handling: if any field is undefined
          if(firstname == undefined || lastname == undefined)
          {
           helper.showToast('Ooops !', 'Please fill up all the information', 'error');
          }
          else
          {
      //if everything is okey then make server call   
        var action = component.get("c.saveAccount"); 
           action.setParams({
            firstName : firstname, 
            lastName : lastname
              }); 
       action.setCallback(this,function(response){
       var state = response.getState();
   //if callback is Success then show toast message and close the modal popup
           if(state === "SUCCESS")
           {
  //pass parameters to helper showToast method  
    helper.showToast('Success !', 'Record Inserted Successfully', 'success');
             $A.get("e.force:closeQuickAction").fire();
           }
         });
            $A.enqueueAction(action);
        }  
      }
      
  })