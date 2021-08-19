public without sharing class PrepaidBulkPolicyController {
    
    @AuraEnabled(cacheable=true) 
   public static List<Product2> prepaidPlans(string contractyear){
       try {
          List<product2> productList = [SELECT Id, Name FROM product2 where Contract_Year__c =: contractyear and Product_Type__c = 'Prepaid Plan' and IsActive = true];
          return productList;
           
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }

   @AuraEnabled(cacheable = true)
    public static List<InsurancePolicy> fetchPoliciesDetails(String accountId){
        List<InsurancePolicy> policyList = [SELECT Id, Name, Enrollment__c,Policy_Premium_Amount__c,EffectiveDate,ExpirationDate
                                    FROM InsurancePolicy WHERE NameInsuredId=: accountId];
        return policyList;
    }


     @AuraEnabled(cacheable=true) 
   public static List<Product2> ScholarshipPlans(){
       try {
          List<product2> productList = [SELECT Id, Name FROM product2 where Product_Type__c = 'Scholarship Program'];
          return productList;
           
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }


    @AuraEnabled
    public static List<Prepaid_Pricebook_Entry__c> PriceBookEntryDetails(string pey,string contractYear,string productId,string PolicyPurchaseType,string PricebkSubType){

    try {

            List<Prepaid_Pricebook_Entry__c> pricebookEntryDetails = null;
            list<pricebook2> priceBookDetails = [Select id from Pricebook2 where Contract_Year__c = :contractYear];
                string priceBookEntryId = priceBookDetails[0].id;

                if(PolicyPurchaseType == 'Individual')   
               {
               pricebookEntryDetails = [SELECT Id, Name, Product__c, Product__r.Name, 
                                                  Product__r.Family,  Price_Book__c, Tution__c,Tuition_Lower_Fee__c,Tuition_Upper_Fee__c,
                                                  Local_Fee__c,Local_Lower_Fee__c,Local_Upper_Fee__c, TDF_Fee__c,Dorm_Fee__c, PEY__c, Lump_Sum_Price__c FROM Prepaid_Pricebook_Entry__c 
                                                                            where Product__c=: productId AND PEY__c=: pey and Price_Book_Type__c = :PolicyPurchaseType];

               }
               else
               {
                    pricebookEntryDetails = [SELECT Id, Name, Product__c, Product__r.Name, 
                                                  Product__r.Family,  Price_Book__c, Tution__c,Tuition_Lower_Fee__c,Tuition_Upper_Fee__c,
                                                  Local_Fee__c,Local_Lower_Fee__c,Local_Upper_Fee__c, TDF_Fee__c,Dorm_Fee__c, PEY__c, Lump_Sum_Price__c FROM Prepaid_Pricebook_Entry__c 
                                                                            where Product__c=: productId AND PEY__c=: pey and Price_Book_Type__c = :PolicyPurchaseType and Sub_Type__c =:PricebkSubType];

              

               }

                /*    
                pricebookEntryDetails = [SELECT Id, Name, Product__c, Product__r.Name, 
                                                    Product__r.Family,  Price_Book__c, Tution__c,Tuition_Lower_Fee__c,Tuition_Upper_Fee__c,
                                                    Local_Fee__c,Local_Lower_Fee__c,Local_Upper_Fee__c, TDF_Fee__c,Dorm_Fee__c, PEY__c, Lump_Sum_Price__c FROM Prepaid_Pricebook_Entry__c 
                                                                                where Product__c=: productId AND PEY__c=: pey and Price_Book_Type__c =: PolicyPurchaseType];
            
            */
            
            return pricebookEntryDetails;
            
        } catch (Exception e)
         {
            throw new AuraHandledException(e.getMessage());
        }

    }

   @AuraEnabled
   public static list<InsurancePolicy> createPolicy(string numberofPolicy, Id accId, string pey,string contractYear, 
                                                string paymentMethodology, decimal numberOfPayments,string productId,string PolicyPurchaseType,string Scholarplantype,string PricebkSubType)
   {
        return insertPolicy( numberofPolicy, accId, pey, contractYear,paymentMethodology, numberOfPayments, productId, null, PolicyPurchaseType,Scholarplantype,PricebkSubType);
   }

   public static list<InsurancePolicy> insertPolicy(string numberofPolicy, Id accId, string pey,string contractYear, 
                                                string paymentMethodology, decimal numberOfPayments,string productId, string prepaidPriceBookId,string PolicyPurchaseType,string Scholarplantype,string PricebkSubType)
   {

       try {
         Integer currentYear = System.Today().year();

        //Date dtStart = Date.newInstance(currentYear,02,01); 
        //Date dtEnd = Date.newInstance(currentYear,04,30);

        Date dtStart = Enrollment_Period__c.getOrgDefaults().Start_Date__c;
        Date dtEnd = Enrollment_Period__c.getOrgDefaults().End_Date__c;
      //  Date dtStart = Date.valueOf(Start_Enrollment);
      //  Date dtEnd = Date.valueOf(End_Enrollment);



        Date currentDate = System.Today();

        List<InsurancePolicy> PolicyList = new List<InsurancePolicy>();
       for(integer i=0;i<Integer.valueOf(numberofPolicy);i++)
           {    
       InsurancePolicy policyObj = new InsurancePolicy();
         if((currentDate >= dtStart ) && (currentDate  <= dtEnd ))
            {
                policyObj.Status = 'Active';
            }else{
                policyObj.Status = 'Pending';
            }
       policyObj.NameInsuredId  = accId;
       policyObj.Policy_Purchase_Type__c = PolicyPurchaseType;
       if(Scholarplantype!=null){
        policyObj.Scholarship_Plan__c = Scholarplantype ;
       }
       policyObj.Enrollment__c  = pey;
       policyObj.Price_Book_Sub_Type__c = PricebkSubType;
       policyObj.EffectiveDate  = Datetime.valueOf(pey+'-01-01 00:00:00');
       policyObj.ExpirationDate  = Datetime.valueOf((Integer.valueOf(pey)+9)+'-12-31 00:00:00');
       policyObj.Name  = 'Policy - '+DateTime.now().getTime()+i;
       policyObj.Payment_Methodology__c = paymentMethodology;
       PolicyList.add(policyObj);
       }
       insert PolicyList;
    
       string family = null;
       list<pricebook2> priceBookDetails = [Select id from Pricebook2 where Contract_Year__c = :contractYear];
       string priceBookEntryId = priceBookDetails[0].id;
       if(prepaidPriceBookId!=null){
          Prepaid_Pricebook_Entry__c ppe = [SELECT Id, Product__c,
                                             Product__r.Family
                                             FROM Prepaid_Pricebook_Entry__c where id =: prepaidPriceBookId];
        productId = ppe.Product__c;
          family = ppe.Product__r.Family;
       }else{

          list<product2> prodlist = [select id, family from product2 where id=:productId];         
          family = prodlist[0].family;
       }

         map<string,decimal> coveragesNameAmountMap =   policyCoverages(contractYear, productId, pey, prepaidPriceBookId,PolicyPurchaseType,PricebkSubType);
         Set<String> coveragesPlans = coveragesNameAmountMap.KeySet();
        List<InsurancePolicyCoverage> policyCoverageList = new List<InsurancePolicyCoverage>();
        for(integer i=0;i<PolicyList.size(); i++ )
       {
           for(string str : coveragesPlans)
           {
           InsurancePolicyCoverage pcObj = new InsurancePolicyCoverage();
           if((currentDate >= dtStart ) && (currentDate  <= dtEnd ))
            {
                pcObj.Status__c = 'Active';
            }else{
                pcObj.Status__c = 'Pending';
            }
           pcObj.Category = family;
           pcObj.CoverageName = str;  
           pcObj.No_of_Payments__c = numberOfPayments;
           pcObj.Frequency__c = 'One-Time';
            pcObj.Coverage_Type__c = str;
          
           pcObj.Product__c = productId;
           pcObj.Price_Book__c = priceBookEntryId;
           pcObj.price__c = coveragesNameAmountMap.get(str);
           //pcObj.Coverage_Price__c = coveragesNameAmountMap.get(str);
           pcObj.InsurancePolicyId = PolicyList[i].Id;
           pcObj.EffectiveDate  = Datetime.valueOf(pey+'-01-01 00:00:00');
           pcObj.ExpirationDate  = Datetime.valueOf((Integer.valueOf(pey)+9)+'-12-31 00:00:00');
           pcObj.IsFinanceChargeCalculated__c = false;
           policyCoverageList.add(pcObj);
           }
       }
       insert policyCoverageList;



       return PolicyList;
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
       
   }

   @AuraEnabled
   public static map<string,decimal> policyCoverages(string contractYear,string Product_Id, string pey) {

        return policyCoverages(contractYear, Product_Id, pey, null,'Individual',null);
   }

     @AuraEnabled
   public static map<string,decimal> policyCoverages(string contractYear,string Product_Id, string pey, string prepaidPriceBookId,string PolicyPurchaseType,string PricebkSubType) {
       try {

           List<Prepaid_Pricebook_Entry__c> pricebookEntryDetails = null;

           map<string,decimal> coveragesNameAmountMap = new map<string,decimal>();
   
           

           if(prepaidPriceBookId!=null){
               pricebookEntryDetails = [SELECT Id, Name, Product__c, Product__r.Name, 
                                        Product__r.Family,  Price_Book__c, Tution__c, Tuition_Lower_Fee__c,Tuition_Upper_Fee__c,
                                        Local_Fee__c, Local_Lower_Fee__c,Local_Upper_Fee__c, TDF_Fee__c, Dorm_Fee__c, PEY__c, Lump_Sum_Price__c 
                                        FROM Prepaid_Pricebook_Entry__c where id =: prepaidPriceBookId and Price_Book_Type__c = :PolicyPurchaseType];
           }else{
               list<pricebook2> priceBookDetails = [Select id from Pricebook2 where Contract_Year__c = :contractYear];
               string priceBookEntryId = priceBookDetails[0].id;

               if(PolicyPurchaseType == 'Individual')   
               {
               pricebookEntryDetails = [SELECT Id, Name, Product__c, Product__r.Name, 
                                                  Product__r.Family,  Price_Book__c, Tution__c,Tuition_Lower_Fee__c,Tuition_Upper_Fee__c,
                                                  Local_Fee__c,Local_Lower_Fee__c,Local_Upper_Fee__c, TDF_Fee__c,Dorm_Fee__c, PEY__c, Lump_Sum_Price__c FROM Prepaid_Pricebook_Entry__c 
                                                                            where Product__c=: Product_Id AND PEY__c=: pey and Price_Book_Type__c = :PolicyPurchaseType];

               }
               else
               {
                    pricebookEntryDetails = [SELECT Id, Name, Product__c, Product__r.Name, 
                                                  Product__r.Family,  Price_Book__c, Tution__c,Tuition_Lower_Fee__c,Tuition_Upper_Fee__c,
                                                  Local_Fee__c,Local_Lower_Fee__c,Local_Upper_Fee__c, TDF_Fee__c,Dorm_Fee__c, PEY__c, Lump_Sum_Price__c FROM Prepaid_Pricebook_Entry__c 
                                                                            where Product__c=: Product_Id AND PEY__c=: pey and Price_Book_Type__c = :PolicyPurchaseType and Sub_Type__c =:PricebkSubType];

              

               }
           }
          

         List<ProductCoverage> productCoveragesList = [SELECT CoverageType.Id, CoverageType.Name,Product.Name,Product.Family FROM ProductCoverage where ProductId=:Product_Id];
           
           if(productCoveragesList.size()>0){       

               for(integer i =0 ; i<productCoveragesList.size(); i++)    
               {
               system.debug('inside productCoveragesList:  ' +productCoveragesList[i]);
                  if(productCoveragesList[i].CoverageType.Name == 'Tuition')
                       coveragesNameAmountMap.put(productCoveragesList[i].CoverageType.Name, pricebookEntryDetails[0].Tution__c+pricebookEntryDetails[0].Tuition_Lower_Fee__c+pricebookEntryDetails[0].Tuition_Upper_Fee__c);
                  if(productCoveragesList[i].CoverageType.Name == 'Local')
                  coveragesNameAmountMap.put(productCoveragesList[i].CoverageType.Name, pricebookEntryDetails[0].Local_Fee__c+pricebookEntryDetails[0].Local_Lower_Fee__c+pricebookEntryDetails[0].Local_Upper_Fee__c);
                  if(productCoveragesList[i].CoverageType.Name == 'TDF')
                   coveragesNameAmountMap.put(productCoveragesList[i].CoverageType.Name, pricebookEntryDetails[0].TDF_Fee__c);
                  if(productCoveragesList[i].CoverageType.Name == 'Dorm')
                    coveragesNameAmountMap.put(productCoveragesList[i].CoverageType.Name, pricebookEntryDetails[0].Dorm_Fee__c);
              }     
           }
           system.debug('coveragesNameAmountMap: '+coveragesNameAmountMap);
                  return coveragesNameAmountMap;
           
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }
    
  
}