/******* Controller Class for LWC to get Vf origin and for LWC to fire a Platform Event *******/
public without sharing class POV_Controller {


    // VF Getter Variable for dynamic LEX Origin
    public string lexOrigin {get{ return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0] + '.lightning.force.com';} set;}
    // Expected Format = https://domain.lightning.salesforce.com
  
  
  
  
    /******* Method to dynamically obtain VF origin for the iframe VF page in LWC  *******/
    @AuraEnabled(cacheable = true)
    public static string getVFOrigin() {
      string vfOrigin = '';
      string baseURL = URL.getOrgDomainUrl().toExternalForm(); // Expected Format = https://domain.my.salesforce.com
  
      // Expected Format for DE, Sandbox & Production ORgs = https://domain--c.visualforce.com
      vfOrigin = baseURL.split('.my.')[0] + '--c.' + 'visualforce.com';
  
      /* ********* Below odd Discrepancy was found while implementing this in a Trailhead Playground ***********
      Organization oOrg = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization LIMIT 1];
      if(oOrg.OrganizationType == 'Developer Edition'){
        // Expected Format for Trailhead Playground DE Org = https://domain--c.ap4.visual.force.com
        vfOrigin = baseURL.split('.my.')[0]+'--c.'+oOrg.InstanceName.toLowercase()+'.visual.force.com';
      } else {
        // Expected Format for personal DE, Sandbox & Production Orgs = https://domain--c.visualforce.com
        vfOrigin = baseURL.split('.my.')[0]+'--c.'+'visualforce.com';
      }  */
  
      return vfOrigin;
    }
  }