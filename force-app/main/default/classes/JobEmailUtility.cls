global class JobEmailUtility {
    global static void sendMessage(AsyncApexJob job, Integer recordsProcessed){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'rakesh.kumar@kyrasolutions.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('trnasfer object Batch Status ' + job.Status);
        mail.setPlainTextBody('records processed ' + recordsProcessed);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        
    }
}