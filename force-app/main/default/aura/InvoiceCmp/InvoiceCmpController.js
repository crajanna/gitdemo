({
    closeQA: function (component, event, helper) {
        //alert('hi....');
        $A.get("e.force:closeQuickAction").fire();
    }
})