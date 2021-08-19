@isTest
public class FpPedgeControllerTest2 {

    @TestSetup
    public static void makeData()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        //MetadataService.MetadataPort service = createService(); 
            
        MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
        staticResource.fullName = 'MyResource123';
        staticResource.contentType = 'text';
        staticResource.cacheControl = 'public';
        staticResource.content = EncodingUtil.base64Encode(Blob.valueOf('Static stuff'));
        MetadataService.SaveResult[] results = service.createMetadata(new List<MetadataService.Metadata> { staticResource });

        
    }
   
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static  void testGetStaticResource(){
       Test.setMock(HttpCalloutMock.class, new RestMock());
        StaticResource sr = [SELECT Id, Name, SystemModStamp FROM StaticResource WHERE Name = 'MyResource123' LIMIT 1];
        
       Test.startTest();
        //String staticResourceName = FPPedgeController.getStaticResourceBaseURL(sr.Name);   
        Test.stopTest();
        //System.assertEquals(staticResourceName.contains('MyResource123'), true);
    }
}