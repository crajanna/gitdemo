public class NavFileProcessing {
    public List<Investment_Transaction__c> invTransactions{get; set;}
    public boolean showProcess{get; set;}
    public NavFileProcessing(ApexPages.StandardSetController stdSetController){
        // Returns all selected records
        //invTransactions = (List<Investment_Transaction__c>) stdSetController.getSelected();
       // if(invTransactions == null || invTransactions.isEmpty()){
        showProcess = true;
            invTransactions = [Select Id, Name,Status__c,Financial_Account__c,Financial_Account__r.Name From Investment_Transaction__c Where Status__c = 'Processing'];
            if(invTransactions == null || invTransactions.isEmpty()){
                showProcess = false;
            }
       // }
    }
    
    public PageReference save(){
        
        InvestmentTransactionRS.markCompleted();// proccessing Investment Transaction status update .
        apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Processing Started'));
        Schema.DescribeSObjectResult result = Investment_Transaction__c.SObjectType.getDescribe(); 
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
        pageRef.setRedirect(true); 
        return pageRef; 
        //return null;
    }
}