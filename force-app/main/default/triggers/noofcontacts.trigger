trigger noofcontacts on Contact (after insert,after delete) {

    if(TriggerUtil.isTriggerActive('contactTrigger')){     

        set<id>accid=new set<id>();

        list<contact>contactlist=new list<contact>();
        list<contact>listcon=new list<contact>();
        list<account>acclist=new list<account>();
        list<account>listacc=new list<account>();
        map<id,integer>mapCount=new map<id,integer>();


        if(trigger.isinsert)                              //insert   con
        {
        for(contact con:trigger.new)
        {
        accid.add(con.accountid);
        }
        }

        if (trigger.isdelete)                          //delete  con
        {
        for(contact con:trigger.old)
        {
        accid.add(con.accountid);
        }
        }

        acclist=[SELECT id,name FROM account WHERE id in:accid];
        contactlist=[SELECT id,name,accountid FROM contact WHERE accountid in:accid];

        for(account acc:acclist){
        listcon.clear();
        for(contact c:contactlist){
        if(c.accountid==acc.id){
        listcon.add(c);

        mapCount.put(c.accountid,listcon.size());
        }
        }
        }

        if(acclist.size()>0){

        for(Account a:acclist)
        {
        if(mapCount.get(a.id)==null)
        a.Number_of_Contact__c =0;

        else

        a.Number_of_Contact__c =mapCount.get(a.id);
        listacc.add(a);
        }
        }


        if(listacc.size()>0)

        update listacc;
    }
}