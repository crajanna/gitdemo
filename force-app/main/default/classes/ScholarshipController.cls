public class ScholarshipController {
    
    /**
    * @ Returning users AccountId  - using in spStudentResponsibilities.js
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return String 
    **/
    @AuraEnabled(cacheable=true)
    public static String getUserAccount(String userId){
    	User user = [SELECT AccountId FROM User where Id =: userId LIMIT 1];
        System.debug('user.AccountId; ==> '+user.AccountId);
        return user.AccountId;
    }
    
    
    /**
    * @By passing selected productId fetching related configuration properties to display HTML elements in UI
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return Scholarship_Application_Setting__mdt 
    **/
    @AuraEnabled(cacheable=true)
    public static Scholarship_Application_Setting__mdt getScholarshipApplicationDetails(String productId){
        Scholarship_Application_Setting__mdt scholarshipApplication;
    	Product2 product = [SELECT Id, Name FROM Product2 where Id =: productId];
        if(!Test.isRunningTest()){
        	scholarshipApplication = [SELECT Id, Label, Academic_Interests__c, Community_Champions__c, Essay_Contest__c, Organizations_List__c, Student_Statement__c, Tab_Name__c, Video_Statement__c, Benefits_Qualify__c, First_in_Family__c, Mentor__c, Mentor_Organization__c, Working_with_Mentor__c, Institution__c, Semester__c, Florida_Resident_to_Qualify__c, Institution_Higher_Education__c FROM Scholarship_Application_Setting__mdt where Label =: product.Name ];
            /*Student_family_qualify_benefits__c, Complete_high_school_or_attend_college__c, Student_currently_engage_with_a_mentor__c, Florida_Resident_to_qualify_for_a_Flori__c
            System.debug('scholarshipApplication -> Student_family_qualify_benefits__c : '+scholarshipApplication.Student_family_qualify_benefits__c);*/
        }
		
        return scholarshipApplication;
    }
    

   



    /**
    * @Fetch users's completed scholarship applications to show the review status
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return List<WrapperClass> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<WrapperClass> getScholarshipApplicationReview(String userId){ 
        RecordType scholarshipApplicationRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Scholarship Application' and SObjectType = 'Contract' ];
        List<Contract> contractList = [SELECT Id, Name, RecordTypeId, Account.Name, Status, Product__c, Beneficiary_Account__r.Name, CreatedDate FROM Contract where RecordTypeId =: scholarshipApplicationRecordType.Id  and OwnerId =: userId ORDER BY CreatedDate desc];
        List<WrapperClass> wpList = new List<WrapperClass>(); 
        System.debug(' '+ contractList);
        for(Contract contract: contractList){
            System.debug('Owner.Name '+ contract.Account.Name);
            Product2 product = [SELECT Id, Name, Pledge_Image__c FROM Product2 WHERE Id =: contract.Product__c LIMIT 1];
            System.debug('Product Id '+ product.Id+' --- Name : '+product.Name);
            String myPortalUrl = PageReference.forResource('FoundationImages').getUrl();
            if(!Test.isRunningTest()){
        		myPortalUrl = myPortalUrl.subString(0, myPortalUrl.indexOf('?'));
            } else {
                myPortalUrl = 'test';
            }
            String staticResourceBaseName = myPortalUrl + '/img/';
            
            wpList.add(new WrapperClass(product.Id, product.Name, staticResourceBaseName + product.Pledge_Image__c, contract.Beneficiary_Account__r.Name, contract.Status  ));        
        }
        return wpList;
    }
    
    
    /**
    * @Fetch all the eligible scholarship programs
    * @author Satishbabu Anupoju@UserSettingsUnder.SFDoc | 05-07-2021 
    * @return List<WrapperClass> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<WrapperClass> getSPChoosePrograms(){ 
        List<Product2> chooseProdcutList = [SELECT Id, Name, Description, Sort__c, Pledge_Image__c, Color_Code__c, spotlight__c, ProductCode, Learn_More_URL__c, End_Date__c    FROM Product2 WHERE  (Product_Type__c='Scholarship Application' and Start_Date__c < TODAY and End_Date__c = null) OR
       										(Product_Type__c='Scholarship Application' and Start_Date__c < TODAY and End_Date__c > TODAY) order by Sort__c asc ];
        List<WrapperClass> wpList = new List<WrapperClass>();
	    for(Product2 product: chooseProdcutList){
            String myPortalUrl = PageReference.forResource('FoundationImages').getUrl();
            if(!Test.isRunningTest()){
        		myPortalUrl = myPortalUrl.subString(0, myPortalUrl.indexOf('?'));
            } else {
                myPortalUrl = 'test';
            }
            String staticResourceBaseName = myPortalUrl + '/img/';  
            
            String endDate = '';
            if(product.End_Date__c != null){
                endDate = product.End_Date__c.format();
            }
			
            wpList.add(new WrapperClass(product.Id, product.Name, staticResourceBaseName + product.Pledge_Image__c, product.Learn_More_URL__c, endDate  ));        
        }
        System.debug('wpList size: '+wpList.size());
        return wpList;
    } 
    
    @AuraEnabled(cacheable=true)
    public static String findUserProfilePic(String userId){ 
        //'005P0000007u9mEIAQ';
        System.debug('userId : '+userId);
        User user = [select FullPhotoUrl from User where Id =:userId LIMIT 1];
        System.debug('url : '+user.FullPhotoUrl);
    	return user.FullPhotoUrl;
    }

    
    @AuraEnabled
    public static String uploadVideoToRecord(String accountId, string file, string fileName){ 
        String theUrl;
        List<ContentDocumentLink> lstCdl;
        List<ContentDocument> lstCd = new List<ContentDocument>();
        
        try{  
            String base64File = EncodingUtil.urlDecode(file, 'UTF-8');     
            ContentVersion contentVersionRec = new ContentVersion();  
            contentVersionRec.Title = fileName;  
            contentVersionRec.Description = 'Company Logo'; 
            contentVersionRec.PathOnClient = '/' + fileName;  
            contentVersionRec.FirstPublishLocationId = accountId;  
            contentVersionRec.VersionData = EncodingUtil.base64Decode(base64File);  
            contentVersionRec.IsMajorVersion = true;  
            Insert contentVersionRec;  

            //ContentVersion cvd = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionRec.Id LIMIT 1];

            ContentDocumentLink cd1 = new ContentDocumentLink();
            //cd1.ContentDocumentId = cvd.ContentDocumentId;
            cd1.LinkedEntityId=accountId;
            cd1.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cd1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUse
            //insert cd1;

            return fileName;

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String linkFileWithRecord(String contentDocumentId, String recordId){ 
        String contentDocumentLinkId;
        List<ContentDocumentLink> lstCdl;
        
        try{  
            ContentDocumentLink cdL = new ContentDocumentLink();
            cdL.contentDocumentId = contentDocumentId;
            cdL.LinkedEntityId = recordId;
            cdL.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cdL.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUse
            insert cdL;

            return cdL.Id;

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
	public class WrapperClass{
        @AuraEnabled
        public String id{get; set;}
        
        @AuraEnabled
        public String name{get; set;}
        
        @AuraEnabled
        public String imgUrl{get; set;}
        
        @AuraEnabled
        public String learnMoreUrl{get; set;}
        
        @AuraEnabled
        public String guardianName{get; set;}
        
        @AuraEnabled
        public String status{get; set;}
        
        @AuraEnabled
        public String endDate{get; set;}
        
        public WrapperClass(String i, String n, String m, String l, String d){
            id = i;
            name = n;
            imgUrl = m;
            learnMoreUrl = l;
            endDate = d;
       }

              
   	}
}