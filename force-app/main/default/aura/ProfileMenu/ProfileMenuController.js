({
    handleClick : function(component, event, helper) {
        var source = event.getSource();
        var label = source.get("v.label");
        console.log('label'+label);
        if(label=="My Profile"){
            console.log('0label.'+ label);
        }
        
    }
})