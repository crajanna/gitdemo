({

    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Create_Beneficiary_Info_section_beta");
    },

    statusChange : function (component, event) {
        let navService = component.find("navService");

        if (event.getParam('status') === "FINISHED") {            

            // Sets the route to [Org url]/[Community uri]/[pageName]
            let pageReference = {
                type: "comm__namedPage", // community page. See https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm
                attributes: {
                    pageName: 'comm-my-account' // pageName must be lower case
                }
            }
    
            navService.navigate(pageReference);
        }
    }

   });