public without sharing class SessionCacheController {

    public  static String check {get;set;}
    public  static String dummy {get;set;}


    public SessionCacheController(){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
        sessionPart.put('oppid', '10');
        check = (String)sessionPart.get('oppid');
    }

    //adding key,value pair to cache 
    public static void  setData()
    {      

        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
        sessionPart.put('oppid', '12345999');
                
    }

    //retrieve value by key 
    public static void getData()
    {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.FoundationCache');
        // Retrieve cache value from the partition
         check = (String)sessionPart.get('oppid');

    }
}