public without sharing class PrepaidPolicyController {

    
    @AuraEnabled(cacheable=true) 
    public static List<Product2> prepaidPlans(string contractyear){
        try {
            List<product2> productList = [SELECT Id, Name,Family FROM product2 where Contract_Year__c =: contractyear and Product_Type__c = 'Prepaid Plan' and IsActive = true WITH SECURITY_ENFORCED];
            return productList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true) 
    public static List<ProductCoverage> getProductCoverages(string planId){
        try {
            List<ProductCoverage> productCoveragesList = [SELECT CoverageType.Id, CoverageType.Name,Product.Name,Product.Family FROM ProductCoverage where ProductId=:planId];
            return productCoveragesList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true) 
    public static List<ProductCoverage> getCoverages(string planId){

        System.debug(' testing planId ....>' + planId);
        try {
            List<ProductCoverage> coveragesList = [SELECT CoverageType.Name FROM ProductCoverage where ProductId=:planId];
            System.debug(' testing coveragesList ....>' + coveragesList);
            return coveragesList;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



  /*  @AuraEnabled(cacheable=true)
    public static List<FinServ__AccountAccountRelation__c> getBeneficiaries(String accId) {
        try {
            List < FinServ__AccountAccountRelation__c > relationList = [SELECT  FinServ__RelatedAccount__r.Name, FinServ__RelatedAccount__c ,FinServ__RelatedAccount__r.PersonBirthdate FROM FinServ__AccountAccountRelation__c
                WHERE FinServ__Account__c =: accId AND FinServ__Active__c = true AND FinServ__Role__r.Name='Beneficiary' WITH SECURITY_ENFORCED ];
                return relationList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        
    }*/

    @AuraEnabled
    public static list<InsurancePolicy>  createPolicy(string strPolicyData,list<string> coveragesPlans) {
       
        Savepoint sp = Database.setSavepoint();
        try {
           Integer currentYear = System.Today().year();
           Date dtStart = Enrollment_Period__c.getOrgDefaults().Start_Date__c;
           Date dtEnd = Enrollment_Period__c.getOrgDefaults().End_Date__c;
           Date currentDate = System.Today();
           Map<String, Object> policyData = (Map<String, Object>)JSON.deserializeUntyped(strPolicyData);
           System.debug('accId >>' + String.valueOf(policyData.get('accId')));
           List<InsurancePolicy> policyList = new List<InsurancePolicy>();
           for(integer i=0;i<Integer.valueOf(policyData.get('numberofPolicy'));i++)
           {   
                InsurancePolicy policyObj = new InsurancePolicy();
                if((currentDate >= dtStart ) && (currentDate  <= dtEnd ))
                {
                    policyObj.Status = 'Active';
                }else{
                    policyObj.Status = 'Pending';
                }
                policyObj.NameInsuredId  = String.valueOf(policyData.get('accId'));
                String pey = String.valueOf(policyData.get('pey'));
                policyObj.Enrollment__c  = pey;
                policyObj.EffectiveDate  = Datetime.valueOf(pey+'-01-01 00:00:00');
                policyObj.ExpirationDate  = Datetime.valueOf((Integer.valueOf(pey)+9)+'-12-31 00:00:00');
                policyObj.Name  = 'Policy - '+DateTime.now().getTime();
                policyObj.Policy_Purchase_Type__c = String.valueOf(policyData.get('policyPurchaseType'));
                policyObj.Price_Book_Sub_Type__c = String.valueOf(policyData.get('PricebkSubType'));
                //policyObj.Payment_Methodology__c = String.valueOf(policyData.get('paymentMethodology'));
                policyList.add(policyObj);
            }

                insert policyList;
            
             
            

            //createPolicyParticipant(policyData,policyObj);

            createInsurancePolicyCoverage(policyData,coveragesPlans,policyList);

            String beneficiaryId = String.valueOf(policyData.get('beneficiaryId'));
            system.debug('beneficiaryId ??????????' + beneficiaryId);
            if(String.isNotBlank(beneficiaryId)){
                createPolicyParticipant(beneficiaryId,policyList);
            }
           
            return policyList;
          } catch (Exception e) {
              Database.rollback(sp);
              throw new AuraHandledException(e.getMessage());
          }       
    }

    @AuraEnabled
    public static void  createInsurancePolicyCoverage(Map<String, Object> policyData,list<string> coveragesPlans,List<InsurancePolicy> policyList) {
        Integer currentYear = System.Today().year();
        Date dtStart = Enrollment_Period__c.getOrgDefaults().Start_Date__c;
        Date dtEnd = Enrollment_Period__c.getOrgDefaults().End_Date__c;
        Date currentDate = System.Today();
        String pey = String.valueOf(policyData.get('pey'));
        String contractYear = String.valueOf(policyData.get('contractYear'));
        List<InsurancePolicyCoverage> policyCoverageList = new List<InsurancePolicyCoverage>(); 
        list<string> coveragesPlanList = new List<String>();
        list<pricebook2> priceBookDetails = [Select id from Pricebook2 where Contract_Year__c = :contractYear];
        string priceBookEntryId = priceBookDetails[0].id;
        List<Prepaid_Pricebook_Entry__c> pricebookEntryDetails = null;

        String policyPurchaseType= String.valueOf(policyData.get('policyPurchaseType'));
        String pricebkSubType = String.valueOf(policyData.get('PricebkSubType'));
        String productId = String.valueOf(policyData.get('productId'));
        String pricebookEntryDetailsId;
        if(priceBookEntryId !=null){
            pricebookEntryDetails = [SELECT Id, Name, Tution__c,Tuition_Lower_Fee__c,Tuition_Upper_Fee__c,
            Local_Fee__c,Local_Lower_Fee__c,Local_Upper_Fee__c, TDF_Fee__c,Dorm_Fee__c, PEY__c, Lump_Sum_Price__c 
            FROM Prepaid_Pricebook_Entry__c where Product__c=: productId AND PEY__c=: pey and Price_Book__c = :priceBookEntryId
            and Price_Book_Type__c = :policyPurchaseType and Sub_Type__c =:pricebkSubType];
        }

        if(null != pricebookEntryDetails){
            pricebookEntryDetailsId =  pricebookEntryDetails[0].id;
        }

        if(null != coveragesPlans && coveragesPlans.size() > 0){
            coveragesPlanList = coveragesPlans;
        } else {
            List<ProductCoverage> coveragesList = getCoverages(productId);
            String coverageName;
            for(ProductCoverage productCoverage : coveragesList){
                System.debug('product coverage name.....'+productCoverage.CoverageType.Name);
                coverageName = productCoverage.CoverageType.Name;
                coveragesPlanList.add(coverageName);
            }
            system.debug('coveragesPlanList >>>>>>>>>>>>>'+coveragesPlanList);
        }
        for(integer i=0;i<policyList.size(); i++ )
        {
            for(string str : coveragesPlanList)
            {
                InsurancePolicyCoverage pcObj = new InsurancePolicyCoverage();
                pcObj.Category = String.valueOf(policyData.get('family'));
                pcObj.CoverageName = str;  
                pcObj.No_of_Payments__c = Integer.valueOf(policyData.get('numberOfPayments')) ;
                if(str.contains('Tuition')){
                    pcObj.Coverage_Type__c = 'Tuition';
                }else if(str.contains('Local')){
                    pcObj.Coverage_Type__c = 'Local';
                }else if(str.contains('TDF')){
                    pcObj.Coverage_Type__c = 'TDF';
                }else if(str.contains('Dormitory')){
                    pcObj.Coverage_Type__c = 'Dormitory';
                }

                if((currentDate >= dtStart ) && (currentDate  <= dtEnd ))
                {
                    pcObj.Status__c = 'Active';
                }else{
                    pcObj.Status__c = 'Pending';
                }

                pcObj.Product__c = (String) policyData.get('productId');
                pcObj.Price_Book__c = priceBookEntryId;
                pcObj.Prepaid_Pricebook_Entry__c = pricebookEntryDetailsId;
                pcObj.InsurancePolicyId = policyList[i].Id;
                pcObj.EffectiveDate  = Datetime.valueOf(pey+'-01-01 00:00:00');
                pcObj.ExpirationDate  = Datetime.valueOf((Integer.valueOf(pey)+9)+'-12-31 00:00:00');
                policyCoverageList.add(pcObj);                
            }
        }

        
            insert policyCoverageList;
        
            
    }

    @AuraEnabled
    public static void  createPolicyParticipant(String beneficiaryId,List<InsurancePolicy> policyList) {
        for(integer i=0;i<policyList.size(); i++ )
        {
            InsurancePolicyParticipant pp = new InsurancePolicyParticipant();
            pp.IsActiveParticipant = true;
            pp.BeneficiarySharePercentage = 100;
            pp.InsurancePolicyId = policyList[i].Id;
            pp.PrimaryParticipantAccountId = beneficiaryId;
            pp.Role = 'Beneficiary';

           
           insert pp;
            
        }
    }
    
}