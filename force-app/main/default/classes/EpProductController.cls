public without sharing class EpProductController {


    @AuraEnabled
    public static list<InsurancePolicy> createPrepaidPolicy(Id accId, string pey,
                                                          string paymentMethodology, 
                                                          decimal numberOfPayments,
                                                          string prepaidPriceBookId,
                                                          Id beneficiartAccount)
    {
 
     if(prepaidPriceBookId!=null){
         
         
      list<InsurancePolicy> inspolicyList =  PrepaidBulkPolicyController.insertPolicy( '1', accId, pey, String.valueOf(EpHelper.getContractYear()),paymentMethodology, numberOfPayments, null, prepaidPriceBookId, 'Individual' ,null, null);
             
         List<InsurancePolicyParticipant> policyParticipantList = new List<InsurancePolicyParticipant>();
                 
                 if(inspolicyList.size()>0){
                     for(integer i=0;i<inspolicyList.size(); i++ )
                     {
                         InsurancePolicyParticipant pcObj = new InsurancePolicyParticipant();
                         pcObj.InsurancePolicyId = inspolicyList[i].Id;
                         pcObj.PrimaryParticipantAccountId = beneficiartAccount;  
                         pcObj.Role = 'Beneficiary';
                         pcObj.EffectiveDate  = Datetime.valueOf(pey+'-01-01 00:00:00');
                         pcObj.ExpirationDate  = Datetime.valueOf((Integer.valueOf(pey)+9)+'-12-31 00:00:00');    
                                              
                         policyParticipantList.add(pcObj);
                     }
                     if(policyParticipantList.size()>0){
                         insert policyParticipantList;
                     }
                 }
                 return inspolicyList;
      }
 
      return null;
    }


    @AuraEnabled(cacheable=true)
    public static List<ProductDetails> getProductsByPEY(String pey) {
        return getProductsByPEY(pey, null);
    }


    @AuraEnabled(cacheable=true)
    public static List<ProductDetails> getProductsByPEY(String pey, List<String> prepaidPricebookIds) {

        Date currentDate = System.today(); //current date
        Integer currentYear = currentDate.Year(); //get year

        Date dtStart = Date.newInstance(currentYear,02,01); 
        Date dtEnd = Date.newInstance(currentYear,4,30); 

        if(!(currentDate > dtStart && currentDate  < dtEnd ))
        {
            currentYear = 2021;
        
        }

        List<Prepaid_Pricebook_Entry__c> pricebookList = null;

        List<ProductDetails> saList = new List<ProductDetails>();

        if(prepaidPricebookIds !=null && prepaidPricebookIds.size()>0){
            pricebookList =  [SELECT Id, Product__r.Id, Product__r.Name, Product__r.Description,
                                    Product__r.Family, 
                                    Local_Lower_Fee__c, 
                                    Local_Upper_Fee__c, 
                                    Tuition_Lower_Fee__c, 
                                    Tuition_Upper_Fee__c,
                                    Tution__c,
                                    TDF_Fee__c,
                                    Local_Fee__c, 
                                    Dorm_Fee__c, 
                                    Product__r.Local_Lower__c, 
                                    Product__r.Local_Upper__c, 
                                    Product__r.Tuition_Lower__c, 
                                    Product__r.Tuition_Upper__c, 
                                    Product__r.Tuition__c, 
                                    Product__r.TDF__c, 
                                    Product__r.Local__c, 
                                    Product__r.Dormitory__c 
                                    FROM Prepaid_Pricebook_Entry__c where id IN: prepaidPricebookIds
                                    ];

        }else{
            pricebookList =  [SELECT Id, Product__r.Id, Product__r.Name, Product__r.Description,
                                                    Product__r.Family, 
                                                    Local_Lower_Fee__c, 
                                                    Local_Upper_Fee__c, 
                                                    Tuition_Lower_Fee__c, 
                                                    Tuition_Upper_Fee__c,
                                                    Tution__c,
                                                    TDF_Fee__c,
                                                    Local_Fee__c, 
                                                    Dorm_Fee__c, 
                                                    Product__r.Local_Lower__c, 
                                                    Product__r.Local_Upper__c, 
                                                    Product__r.Tuition_Lower__c, 
                                                    Product__r.Tuition_Upper__c, 
                                                    Product__r.Tuition__c, 
                                                    Product__r.TDF__c, 
                                                    Product__r.Local__c, 
                                                    Product__r.Dormitory__c 
                                                    FROM Prepaid_Pricebook_Entry__c where PEY__c =:pey
                                                    and Price_Book_Type__c = 'Individual'
                                                    and Product__r.Family in('College','University','Bundled','Dorm') 
                                                    and Product__r.Contract_Year__c = :String.valueOf(EpHelper.getContractYear())
                                                    order by Product__r.Sort__c asc];

        }

       
        for(Prepaid_Pricebook_Entry__c item: pricebookList){

            ProductDetails saObj = new ProductDetails();
            saObj.id = item.Id;
            saObj.productId = item.Product__r.Id;
            saObj.name = item.Product__r.Name;
            saObj.description = item.Product__r.Description;            
            saObj.productFamily = item.Product__r.Family;
            saObj.localLowerFee = item.Local_Lower_Fee__c; 
            saObj.localUpperFee = item.Local_Upper_Fee__c; 
            saObj.tutionLowerFee = item.Tuition_Lower_Fee__c;
            saObj.tutionUpperFee = item.Tuition_Upper_Fee__c;
            saObj.tution = item.Tution__c;
            saObj.tdfFee = item.TDF_Fee__c;
            saObj.localFee = item.Local_Fee__c;
            saObj.dormFee = item.Dorm_Fee__c;
            saObj.productLocalLowerFee = item.Product__r.Local_Lower__c; 
            saObj.productLocalUpperFee = item.Product__r.Local_Upper__c; 
            saObj.productTutionLowerFee = item.Product__r.Tuition_Lower__c; 
            saObj.productTutionUpperFee = item.Product__r.Tuition_Upper__c; 
            saObj.productTution = item.Product__r.Tuition__c; 
            saObj.productTdfFee = item.Product__r.TDF__c; 
            saObj.productLocalFee = item.Product__r.Local__c; 
            saObj.productDormFee = item.Product__r.Dormitory__c ;

            saList.add(saObj);
        }		
        System.debug('getProductsByPEY ... ' +  saList.size());  
        return saList;
    }



    public class ProductDetails {
        
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String productId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String productFamily;
        @AuraEnabled
        public Decimal localLowerFee;
        @AuraEnabled
        public Decimal localUpperFee;
        @AuraEnabled
        public Decimal tutionLowerFee;
        @AuraEnabled
        public Decimal tutionUpperFee;
        @AuraEnabled
        public Decimal tution;
        @AuraEnabled
        public Decimal tdfFee;
        @AuraEnabled
        public Decimal localFee;
        @AuraEnabled
        public Decimal dormFee;
        @AuraEnabled
        public Decimal productLocalLowerFee;
        @AuraEnabled
        public Decimal productLocalUpperFee;
        @AuraEnabled
        public Decimal productTutionLowerFee;
        @AuraEnabled
        public Decimal productTutionUpperFee;
        @AuraEnabled
        public Decimal productTution;
        @AuraEnabled
        public Decimal productTdfFee;
        @AuraEnabled
        public Decimal productLocalFee;
        @AuraEnabled
        public Decimal productDormFee;

       
        @AuraEnabled
        public boolean getDorm(){
            return 'Dorm'.equals(productFamily);
        }
        
        @AuraEnabled
        public boolean getUniversity(){
            if(!productFamily.equalsIgnoreCase('Dorm')){
                return true;
            }
            return false;          
        }
        @AuraEnabled
        public Decimal getLumpSumPrice(){
  
            if(!productFamily.equalsIgnoreCase('Foundation')){
                Decimal val = localLowerFee*productLocalLowerFee + 
                                    localUpperFee*productLocalUpperFee + 
                                    tutionLowerFee*productTutionLowerFee +
                                    tutionUpperFee*productTutionUpperFee +
                                    tution*productTution +
                                    tdfFee*productTdfFee +
                                    localFee*productLocalFee +
                                    dormFee*productDormFee ;    

                return val.setScale(2, RoundingMode.HALF_UP);  
  
            }
            return 0;           
        }

        @AuraEnabled
        public List<Map<String,String>> getPriceOptions(){  
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            selectOpt.add(new Map<String, String>{'value' => id+'-'+productId+'-'+productFamily+'-lumpsum', 'label' => String.valueOf(getLumpSumPrice())});
            return selectOpt;           
        }
    }

}