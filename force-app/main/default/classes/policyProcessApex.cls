/**
* @description       : 
* @author            : Pradeep Landge
* @group             : 
* @last modified on  : 02-17-2021
* @last modified by  : Pradeep Landge
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   02-17-2021   Pradeep Landge   Initial Version
**/
public class policyProcessApex {
    
    @AuraEnabled
    public static list < string > policyType() {
        try {
            return new List < string > {
                'University',
                    'College',
                    'Foundation'
                    };
                        } catch (Exception e) {
                            throw new AuraHandledException(e.getMessage());
                        }
    }
    
    @AuraEnabled
    public static list < string > enrollmentYear() {
        try {
            List < String > pickListValuesList = new List < String > ();
            Schema.DescribeFieldResult fieldResult = Prepaid_Pricebook_Entry__c.PEY__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal: ple) {
                pickListValuesList.add(pickListVal.getLabel());
            }
            return pickListValuesList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static map < string, string > paymentMethodology() {
        try {
            map < String, string > pickListValuesMap = new map < String, string > ();
            Schema.DescribeFieldResult fieldResult = InsurancePolicy.Payment_Methodology__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal: ple) {
                pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
            return pickListValuesMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static map<string,decimal> policyCoverages(string contractYear,string planId, string pey) {
        try {
            map<string,decimal> coveragesNameAmountMap = new map<string,decimal>();
            string priceBookEntryId;
            string productFamily;
            
            list<product2> productDetails = [SELECT id, Name, Family from Product2 Where id=:planId];
            productFamily = productDetails[0].Family;
            
            if(contractYear == '2009'){
                list<pricebook2> priceBookDetails = [Select id from Pricebook2 where name = '2009 Fee Schedule'];
                priceBookEntryId = priceBookDetails[0].id;
            }else if(contractYear == '2021'){
                list<pricebook2> priceBookDetails = [Select id from Pricebook2 where name = '2020-2021 Fee Schedule'];
                priceBookEntryId = priceBookDetails[0].id;
            }
            
            list<Prepaid_Pricebook_Entry__c> pricebookEntryDetails = [SELECT Id, Name, Product__c, Price_Book__c, Tution__c, Local_Fee__c, TDF_Fee__c, PEY__c, Lump_Sum_Price__c FROM Prepaid_Pricebook_Entry__c 
                                                                      where Product__c=: planId AND Price_Book__c=:priceBookEntryId AND PEY__c=: pey];
            system.debug('pricebookentry detials'+pricebookEntryDetails.isEmpty());
            system.debug('productDetails detials'+productDetails.isEmpty());
            
            if(!pricebookEntryDetails.isEmpty() && !productDetails.isEmpty()){
                
                if(contractYear == '2021'){
                    if(productFamily == 'University' || productFamily == 'Bundled'){
                        coveragesNameAmountMap.put('Tuition - '+ productDetails[0].Name, pricebookEntryDetails[0].Tution__c);
                        coveragesNameAmountMap.put('Local - '+ productDetails[0].Name, pricebookEntryDetails[0].Local_Fee__c);
                        coveragesNameAmountMap.put('TDF - '+ productDetails[0].Name, pricebookEntryDetails[0].TDF_Fee__c);
                        
                    }else if(productFamily == 'College'){
                        coveragesNameAmountMap.put('Tuition - '+ productDetails[0].Name, pricebookEntryDetails[0].Tution__c);
                        coveragesNameAmountMap.put('Local - '+ productDetails[0].Name, pricebookEntryDetails[0].Local_Fee__c);
                    }else if(productFamily == 'Dorm'){
                        coveragesNameAmountMap.put('Dorm - '+ productDetails[0].Name, pricebookEntryDetails[0].Lump_Sum_Price__c);
                    }
                }else if(contractYear == '2009'){
                        coveragesNameAmountMap.put(productDetails[0].Name, pricebookEntryDetails[0].Lump_Sum_Price__c);
                }
            }
            system.debug('coveragesNameAmountMap'+coveragesNameAmountMap);
            return coveragesNameAmountMap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static map<string,map<string,string>> productContractYearMap(){
        try {
            map<string,map<string,string>> contractYearListProductIdMap = new map<string,map<string,string>>();

            List<product2> productList = [SELECT Id, 
                                          Name,
                                          Contract_Year__c
                                          FROM product2
                                          WHERE isActive = TRUE
                                         ];
            
            if(!productList.isEmpty()){
                for(product2 p : productList){
                   if(contractYearListProductIdMap.containskey(p.Contract_Year__c)){
                       map<string,string> tempMap =  contractYearListProductIdMap.get(p.Contract_Year__c);
                       tempMap.put(p.Id,p.Name);
                       contractYearListProductIdMap.put(p.Contract_Year__c,tempMap);
                   }else{
                    map<string,string> tempMap = new map<string,string>();
                    tempMap.put(p.id,p.name);
                    contractYearListProductIdMap.put(p.Contract_Year__c,tempMap);
                   }
                }
            }
            system.debug('contractYearListProductIdMap'+contractYearListProductIdMap);
            return contractYearListProductIdMap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    @AuraEnabled
    public static map<string,string> productPlanType(){
        try {
            List<product2> productList = [SELECT Id, 
                                          Name
                                          FROM product2
                                         ];
            
            map<string,string> productnameIdMap = new map<string,string>();                                                                 
            if(!productList.isEmpty()){
                for(product2 p : productList){
                    productnameIdMap.put(p.Name,p.id);
                }
            }
            return productnameIdMap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static boolean hasUniversityCoverage(string beneficiaryId,string productId, string recordId){
        try {
            Boolean hasCoverage = false;
            set<id> policyId = new set<id>();
            set<id> beneficiarySet = new set<id>();

            list<product2> prodList = [SELECT id, family from Product2 where id=:productId];

            if(prodList[0].family == 'dorm'){

              list<InsurancePolicyCoverage> covgs = [select id, 
              category, 
              InsurancePolicyId, 
              InsurancePolicy.NameInsuredid from 
              InsurancePolicyCoverage  
              where Category ='University' 
              AND InsurancePolicy.NameInsuredid =: recordId];
              system.debug('coverages'+covgs);
        
            if(!covgs.isEmpty()){
                for(InsurancePolicyCoverage ipc:covgs){
                    policyId.add(ipc.InsurancePolicyId);
                }

                if(!policyId.isEmpty()){
                     list<InsurancePolicyParticipant> inPart = [select id,
                     InsurancePolicyId,
                     PrimaryParticipantAccountId
                     from InsurancePolicyParticipant
                     where InsurancePolicyId IN: policyId];
                    
                     if(!inPart.isEmpty()){
                         for(InsurancePolicyParticipant ip: inPart){
                            beneficiarySet.add(ip.PrimaryParticipantAccountId);
                         }
                     }
                     system.debug('beneficiarySet'+beneficiarySet);

                     if(beneficiarySet.contains(beneficiaryId)){
                        hasCoverage = true;
                     }

                }
            }

            if(!policyId.isEmpty()){
                list<InsurancePolicyCoverage> covgList = [Select id, Category from InsurancePolicyCoverage where InsurancePolicyId IN : policyId ];

                if(!covgList.isEmpty()){
                    for(InsurancePolicyCoverage ic: covgList){
                          if(ic.Category == 'University'){
                            hasCoverage = true;
                            break;
                          }
                    }
                }
            }
        }
        else{
            hasCoverage = true;
        }
            system.debug('hascoverage'+hasCoverage);
            return hasCoverage;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id createPolicy(Id beneficiaryId, Id accId, string pey, string productId, list<string> coveragesPlans, string contractYear, list<string> coveragesWithAmount,string paymentMethodology, decimal numberOfPayments) {
        //   try {
        system.debug('createPolicy productList >> '+ coveragesWithAmount);
        map<string,decimal> mapCoverageAmount = new map<string,decimal>();
        Integer currentYear = System.Today().year();
        Date dtStart = Date.newInstance(currentYear,02,01); 
        Date dtEnd = Date.newInstance(currentYear,04,30);
        Date currentDate = System.Today();

        if(!coveragesWithAmount.isEmpty()){
             for(string str:coveragesWithAmount){
                 list<string> tempList = str.split(';');
                 mapCoverageAmount.put(templist[0],Decimal.valueOf(templist[1]));
             }
        }
        system.debug('coverage map'+mapCoverageAmount);
        string priceBookEntryId;

        list<product2> prodlist = [select id, family from product2 where id=:productId];

        if(contractYear == '2009'){
            list<pricebook2> priceBookDetails = [Select id from Pricebook2 where name = '2009 Fee Schedule'];
            priceBookEntryId = priceBookDetails[0].id;
        }else if(contractYear == '2021'){
            list<pricebook2> priceBookDetails = [Select id from Pricebook2 where name = '2020-2021 Fee Schedule'];
            priceBookEntryId = priceBookDetails[0].id;
        }

        InsurancePolicy policyObj = new InsurancePolicy();
        if((currentDate >= dtStart ) && (currentDate  <= dtEnd ))
        {
            policyObj.Status = 'Active';
        }else{
            policyObj.Status = 'Pending';
        }
        List<InsurancePolicyCoverage> policyCoverageList = new List<InsurancePolicyCoverage>();       
        policyObj.NameInsuredId  = accId;
        policyObj.Enrollment__c  = pey;
        policyObj.EffectiveDate  = Datetime.valueOf(pey+'-01-01 00:00:00');
        policyObj.ExpirationDate  = Datetime.valueOf((Integer.valueOf(pey)+9)+'-12-31 00:00:00');
        policyObj.Name  = 'Policy - '+DateTime.now().getTime();
       
        policyObj.Payment_Methodology__c = paymentMethodology;
        insert policyObj;

        InsurancePolicyParticipant pp = new InsurancePolicyParticipant();
        pp.IsActiveParticipant = true;
        pp.BeneficiarySharePercentage = 100;
        pp.InsurancePolicyId = policyObj.Id;
        pp.PrimaryParticipantAccountId = beneficiaryId;
        pp.Role = 'Beneficiary';
        insert pp;

        //Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT Id,Name FROM Product2 WHERE Id IN: productList]);
        for(string str : coveragesPlans){
            InsurancePolicyCoverage pcObj = new InsurancePolicyCoverage();
            pcObj.Category = prodlist[0].family;
            pcObj.CoverageName = str;  
            pcObj.No_of_Payments__c = numberOfPayments;
            if(str.contains('Tuition')){
                pcObj.Coverage_Type__c = 'Tuition';
            }else if(str.contains('Local')){
                pcObj.Coverage_Type__c = 'Local';
            }if(str.contains('TDF')){
                pcObj.Coverage_Type__c = 'TDF';
            }

            if((currentDate >= dtStart ) && (currentDate  <= dtEnd ))
            {
                pcObj.Status__c = 'Active';
            }else{
                pcObj.Status__c = 'Pending';
            }

            pcObj.Product__c = productId;
            pcObj.Price_Book__c = priceBookEntryId;
           /* pcObj.price__c = mapCoverageAmount.get(str);*/
            pcObj.InsurancePolicyId = policyObj.Id;
            pcObj.EffectiveDate  = Datetime.valueOf(pey+'-01-01 00:00:00');
            pcObj.ExpirationDate  = Datetime.valueOf((Integer.valueOf(pey)+9)+'-12-31 00:00:00');
            policyCoverageList.add(pcObj);
        }
        insert policyCoverageList;
        
        return policyObj.Id;
        
        /*
} catch (Exception e) {
throw new AuraHandledException(e.getMessage());
}*/
    }
    
    @AuraEnabled
    public static map < string, string > productList(string prodFamily, String enrollmentYear, String duration) {
        try {
            map < string, string > prodNameIdMap = new map < string, string > ();
            List < product2 > prodList = [SELECT id,
                                          name
                                          FROM product2
                                          WHERE Family =: prodFamily
                                          AND isactive = true AND Plan_Duration__c =: duration AND PEY__c =: enrollmentYear
                                         ];
            
            if (!prodList.isEmpty()) {
                for (Product2 p: prodList) {
                    prodNameIdMap.put(p.name, p.id);
                }
                
            }
            
            system.debug('prodlist' + prodList);
            return prodNameIdMap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static map < string, string > getBeneficiary(Id accId) {
        try {
            map < string, string > accNameIdMap = new map < string, string > ();
            List < FinServ__AccountAccountRelation__c > relationList = [SELECT id,
                                                                        FinServ__Account__c, FinServ__RelatedAccount__r.Name, FinServ__RelatedAccount__c, FinServ__Role__r.FinServ__InverseRole__c, FinServ__Active__c
                                                                        FROM FinServ__AccountAccountRelation__c
                                                                        WHERE FinServ__Account__c =: accId
                                                                        AND FinServ__Active__c = true AND FinServ__Role__r.Name='Beneficiary'
                                                                       ];
            
            if (!relationList.isEmpty()) {
                for (FinServ__AccountAccountRelation__c accRelation: relationList) {
                    accNameIdMap.put(accRelation.FinServ__RelatedAccount__r.Name, accRelation.FinServ__RelatedAccount__c);
                }
                
            }
            
            system.debug('accNameIdMap' + accNameIdMap);
            return accNameIdMap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static map < string, string > pricebookList() {
        try {
            map < string, string > priceBookNameIdMap = new map < string, string > ();
            List < Pricebook2 > pricebookList = [SELECT id,
                                                 name
                                                 FROM Pricebook2
                                                 WHERE isactive = true
                                                ];
            
            
            if (!pricebookList.isEmpty()) {
                for (Pricebook2 p: pricebookList) {
                    priceBookNameIdMap.put(p.name, p.id);
                }
                
            }
            return priceBookNameIdMap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
@AuraEnabled
public static void createPolicy(string enrollmentYear, string PriceBook, list < string > ProductList) {
//  try {
//create effective date
Date effectiveDate = date.newInstance(Integer.valueof(enrollmentYear.trim()), 01, 01);

//create expiry date
Date expiryDate = effectiveDate.addYears(9);

//create insurance record
InsurancePolicy newPolicy = new InsurancePolicy();
newPolicy.Name = 'Test Policy';
newPolicy.NameInsuredId = '0013F00000f2fs8QAA';
newPolicy.EffectiveDate = effectiveDate;
newPolicy.ExpirationDate = expiryDate;
insert newPolicy;

//create coverage record for the insurance
list < InsurancePolicyCoverage > coverageList = new list < InsurancePolicyCoverage > ();
if (!ProductList.isEmpty()) {
for (string str: ProductList) {
InsurancePolicyCoverage policyCoverage = new InsurancePolicyCoverage();
policyCoverage.InsurancePolicyId = newPolicy.Id;
//policyCoverage.Product__c = str;
coverageList.add(policyCoverage);
}
insert coverageList;
}


} catch (Exception e) {
system.debug('error' + e.getMessage());
throw new AuraHandledException(e.getMessage());

}

} */
}