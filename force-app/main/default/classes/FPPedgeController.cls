/**
 * @description       : 
 * @author            : Satishbabu Anupoju@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-07-2021   Satishbabu Anupoju@UserSettingsUnder.SFDoc   Initial Version
**/
public  class FPPedgeController {
	
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return List<Product2> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Product2> getChoosePrograms(){ 
        List<Product2> chooseProdcutList = [SELECT Id, Name, Description, Sort__c, Pledge_Image__c, Color_Code__c, spotlight__c, ProductCode, Learn_More_URL__c  FROM Product2 WHERE RecordType.Name = 'Scholarship' AND spotlight__c = false AND
                                            (Product_Type__c='Scholarship Program' AND Start_Date__c < TODAY AND (End_Date__c > TODAY OR End_Date__c = null)) ORDER BY Sort__c asc];
        for(Product2 product: chooseProdcutList){
            product.Color_Code__c = 'slds-visual-picker slds-visual-picker_large card-grid-item '+product.Color_Code__c;
            String sText = product.Name;
 			product.Name = sText.replaceAll( '\\s+', ' ');
            System.debug('Name' + product.Name);
        }
        return chooseProdcutList;
    } 
    
    @AuraEnabled(cacheable=true)
    public static List<wrapperclass> getSPChoosePrograms(){ 
        List<Product2> chooseProdcutList = [SELECT Id, Name, Description, Sort__c, Pledge_Image__c, Color_Code__c, spotlight__c, ProductCode, Learn_More_URL__c  FROM Product2 WHERE  (Product_Type__c='Scholarship Application' and Start_Date__c < TODAY and End_Date__c = null) OR
       										(Product_Type__c='Scholarship Application' and Start_Date__c < TODAY and End_Date__c > TODAY) order by Sort__c asc ];
        List<wrapperclass> wpList = new List<wrapperclass>();
	    for(Product2 product: chooseProdcutList){
            String myPortalUrl = PageReference.forResource('FoundationImages').getUrl();
            
            if(!Test.isRunningTest()) {
                myPortalUrl = myPortalUrl.subString(0, myPortalUrl.indexOf('?'));        
            } else {
                myPortalUrl = 'myPortalUrl';
            }
            
            String staticResourceBaseName = myPortalUrl + '/img/'; 
            
    		wpList.add(new wrapperclass(product.Id, product.Name, staticResourceBaseName + product.Pledge_Image__c));        
        }
        
        
        return wpList;
    } 
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return Product2 
    **/
    @AuraEnabled(cacheable=true)
    public static Product2 getChooseSpotLightPrograms(){
        Product2 spotLightProduct = [SELECT Id, Name, Description, Pledge_Image__c, Color_Code__c, spotlight__c, ProductCode, Learn_More_URL__c  FROM Product2 where RecordType.Name = 'Scholarship' and spotlight__c = true LIMIT 1];
        spotLightProduct.Color_Code__c = 'slds-visual-picker slds-visual-picker_large '+spotLightProduct.Color_Code__c;
        return spotLightProduct; 
    } 
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return List<String> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> getCountyNames(){
    	Set<String> countySet = new Set<String>();
        List<String> countryList =new List<String>();
        List<Florida_Zip_Codes__mdt> countyList = [SELECT Id, County__c FROM Florida_Zip_Codes__mdt order by County__c asc];    
        for(Florida_Zip_Codes__mdt county : countyList){
            countySet.add(county.County__c);
        }
        countryList.addAll(countySet);
        return countryList;
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @param countyName 
    * @return List<Decimal> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Decimal> getCountyZipCode(String countyName){
    	List<Decimal> zipList = new List<Decimal>();
        List<Florida_Zip_Codes__mdt> countyList = [SELECT Id, Zip__c FROM Florida_Zip_Codes__mdt where County__c =: countyName order by Zip__c asc];    
        for(Florida_Zip_Codes__mdt county : countyList){
            zipList.add(county.Zip__c);
        }
        return zipList;
    }
    
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return List<Decimal> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Decimal> getZipCode(){
    	List<Decimal> zipList = new List<Decimal>();
        List<Florida_Zip_Codes__mdt> countyList = [SELECT Id, Zip__c FROM Florida_Zip_Codes__mdt order by Zip__c asc];    
        for(Florida_Zip_Codes__mdt county : countyList){
            zipList.add(county.Zip__c);
        }
        return zipList;
    }
    
    /**
    * @description 
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @param accountId 
    * @param flag 
    * @param randomNum 
    * @return List<wrapperclass> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<wrapperclass> getPledgeList(String accountId, boolean flag, String randomNum){
    //public static List<wrapperclass> getPledgeList(String accountId, boolean flag){
        String staticResourceBaseName = '';
        if(flag){
        	String myPortalUrl = PageReference.forResource('FoundationImages').getUrl();
        	myPortalUrl = myPortalUrl.subString(0, myPortalUrl.indexOf('?'));
        	staticResourceBaseName = myPortalUrl + '/img/';    
        }
        List<Contract> pledgeList =   [SELECT Id, AccountId, Product__r.Pledge_Image__c, Product__r.Name, Status, StatusCode, Name, ContractNumber, Email__c, Pledge__c, Donation_Amount__c FROM Contract where  AccountId =:accountId AND Status != 'Inactive'];
        List<wrapperclass> wpList = new List<wrapperclass>();
        for(Contract cont: pledgeList){
            cont.Name = cont.Product__r.Name;
            if(cont.Donation_Amount__c == null){
                cont.Donation_Amount__c = 0.00;
            }
            if(cont.Pledge__c == null){
                cont.Pledge__c = 0.00;
            }
            if(flag){
                wpList.add(new wrapperclass(cont.Id, cont.Product__r.Name, staticResourceBaseName+cont.Product__r.Pledge_Image__c, cont.Donation_Amount__c, cont.Pledge__c ));
            }else{
                wpList.add(new wrapperclass(cont.Id, cont.Product__r.Name, cont.Product__r.Pledge_Image__c, cont.Donation_Amount__c, cont.Pledge__c ));
            }
            
		}
        return wpList;
    }
    
    
     /**
     * @description 
     * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
     * @param productId 
     * @return Product2 
     **/
     @AuraEnabled(cacheable=true) 
     public static Product2 getProduct(String productId){
    	 return [SELECT Id, Name, Description, DisplayUrl, Pledge_Image__c, spotlight__c, Learn_More_URL__c, Did_You_Know__c FROM Product2 where Id =:productId];
     }
    
     /**
     * @description 
     * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
     * @param contractId 
     * @return Contract 
     **/
     @AuraEnabled(cacheable=true) 
     public static Contract getContract(String contractId){
    	 return [SELECT Id, Name, Product__c, Donation_Amount__c, Pledge__c, Status, AccountId, County__c, Zip_Code__c  FROM Contract where Id =:contractId];
     }

     @AuraEnabled
     public static Contract getContractDetail(String contractId){
        return getContract(contractId);
     }


     /**
     * @description 
     * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
     * @param accountId 
     * @param randomNum
     * @return Object[] 
     **/
     @AuraEnabled(cacheable=true) 
     public static Object[] getAgreegatedFundDetails(String accountId, String randomNum){
    	List<AggregateResult> c = [SELECT SUM(Donation_Amount__c)tot_donation, SUM(Pledge__c)tot_pledge FROM Contract WHERE AccountId =:accountId ];
        Object[] myval = new Object[] {c[0].get('tot_donation'), c[0].get('tot_pledge')};
        return myval;
     }

     public class FundDetailsWrapper{
        @AuraEnabled
        public String totalDonationAmount{get; set;}
        
        @AuraEnabled
        public String totalPledgeAmount{get; set;}
        
        public FundDetailsWrapper(String da, String pa){
            totalDonationAmount = da;
            totalPledgeAmount = pa;
        }
    }
    
     public class wrapperclass{
        @AuraEnabled
        public String id{get; set;}
        
        @AuraEnabled
        public String name{get; set;}
        
        @AuraEnabled
        public string imgUrl{get; set;}
        
        @AuraEnabled
        public Decimal donationAmount{get; set;}
        
        @AuraEnabled
        public Decimal pledgeAmount{get; set;}
        
        public wrapperclass(String i, String n, String m, Decimal d, Decimal p){
            id = i;
            name = n;
            imgUrl = m;
            donationAmount = d;
            pledgeAmount = p;
        }
         
         public wrapperclass(String i, String n, String m){
            id = i;
            name = n;
            imgUrl = m;
            
        }
    }
}