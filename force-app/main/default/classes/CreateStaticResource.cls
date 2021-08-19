public class CreateStaticResource {
public static void createStatic(){ 
    MetadataService.MetadataPort service = createService(); 
	System.debug('Create SErvice : '+service);    
    MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
    staticResource.fullName = 'MyResource123';
    staticResource.contentType = 'text';
    staticResource.cacheControl = 'public';
    staticResource.content = EncodingUtil.base64Encode(Blob.valueOf('Static stuff'));
    MetadataService.SaveResult[] results = service.createMetadata(new List<MetadataService.Metadata> { staticResource });
    System.debug('results : '+results);

}
private static MetadataService.MetadataPort createService(){ 
    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    service.SessionHeader = new MetadataService.SessionHeader_element();
    service.SessionHeader.sessionId = UserInfo.getSessionId();
    return service;     
}
}