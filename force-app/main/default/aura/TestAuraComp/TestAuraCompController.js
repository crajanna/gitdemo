({
    onScriptsLoaded: function (component) {
        console.log("the scripts have loaded successfully.")
    }
});

({
    handleClick : function(cmp, event) {
        var attributeValue = cmp.get("v.text");
        console.log("current text: " + attributeValue);
 
        var target = event.getSource();
        cmp.set("v.text", target.get("v.label"));
    }
})