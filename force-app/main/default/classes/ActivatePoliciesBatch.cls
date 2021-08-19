public class ActivatePoliciesBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'select id,Status,(select id, Status__c from InsurancePolicyCoverages where Status__c = \'Pending\') from InsurancePolicy where status = \'Pending\''
        );
    }
    public void execute(Database.BatchableContext bc, List<InsurancePolicy> records)
    {
        //update the policy coverage and policies seprately using two different maps
        List<InsurancePolicy> ip_list = new List<InsurancePolicy>();
        List<InsurancePolicyCoverage> ipc_list = new list<InsurancePolicyCoverage>();
        system.debug('records: '+records);
        if(records.size()>0)//batch input is not null
        {
            for(InsurancePolicy ip :records)
            {
                InsurancePolicy temp_ip = new InsurancePolicy();
                temp_ip.id = ip.id;
                temp_ip.Status = 'Active';
                ip_list.add(temp_ip);
                for(InsurancePolicyCoverage ipc: ip.InsurancePolicyCoverages)
                {
                    InsurancePolicyCoverage temp_ipc = new InsurancePolicyCoverage();
                    temp_ipc.id = ipc.Id;
                    temp_ipc.Status__c = 'Active';
                    ipc_list.add(temp_ipc);
               }
            }
            system.debug('ip_list: '+ip_list); 
            system.debug('ipc_list: '+ipc_list); 
            update ipc_list;
            update ip_list;
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        
    }
    
}