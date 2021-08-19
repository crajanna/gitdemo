public class RestCalloutDemo {
    @AuraEnabled
    public static String callout(){
        String CLIENT_ID='ATnKGquq4DD9RrPuvdjvH_XfVVEQFODlijMRTTD-Wb5c3HXjSJdZpJMboGq0HmPhqLib6q7KQxSszjzH'; 
		String CLIENT_SECRET='EFHPE63OPxVIa9kI2ugcIXbctFKw2QFDe22WfJRpsAv541Meov45cq8zo-A2nVdvI4JS-_HKB2nQye5v'; 
		String ACCESS_TOKEN_ENDPOINT = 'https://api-m.sandbox.paypal.com/v1/oauth2/token'; 
        String PAYMENT_ENDPOINT = 'https://api.sandbox.paypal.com/v1/payments/payment'; 
		String ACCESS_TOKEN_BODY='grant_type=client_credentials';
        String PAYMENT_BODY = '{"intent":"sale","payer":{"payment_method":"paypal"},"transactions":[{"amount":{"total":"30.11","currency":"USD","details":{"subtotal":"30.00","tax":"0.07","shipping":"0.03","handling_fee":"1.00","shipping_discount":"-1.00","insurance":"0.01"}},"description":"The payment transaction description.","custom":"EBAY_EMS_90048630024435","invoice_number":"48787589673","payment_options":{"allowed_payment_method":"INSTANT_FUNDING_SOURCE"},"soft_descriptor":"ECHI5786786","item_list":{"items":[{"name":"hat","description":"Brown hat.","quantity":"5","price":"3","tax":"0.01","sku":"1","currency":"USD"},{"name":"handbag","description":"Black handbag.","quantity":"1","price":"15","tax":"0.02","sku":"product34","currency":"USD"}],"shipping_address":{"recipient_name":"Brian Robinson","line1":"4th Floor","line2":"Unit #34","city":"San Jose","country_code":"US","postal_code":"95131","phone":"011862212345678","state":"CA"}}}],"note_to_payer":"Contact us for any questions on your order.","redirect_urls":{"return_url":"https://fpcbdevp1-fpcb.cs4.force.com/foundation/s/","cancel_url":"https://google.com"}}';

        System.debug('==========================================');
		Blob headerValue = Blob.valueOf(CLIENT_ID +':'+CLIENT_SECRET);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		System.debug('Encoder Value: ' + EncodingUtil.base64Encode(headerValue));
		
       
        
        Http http1 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(PAYMENT_ENDPOINT);
        req1.setHeader('Content-Type', 'application/json');
        req1.setHeader('Authorization', authorizationHeader);
        req1.setBody(PAYMENT_BODY);
        HttpResponse res1 = http1.send(req1);
        System.debug('==> Response Status: '+res1.getStatus());
        System.debug('==> Response Body: '+res1.getBody());
        System.debug('==> Status code ' + res1.getStatusCode());
        String rsep = res1.getBody();
        rsep = rsep.replaceAll('currency', 'currencyMode');
        PaypalResponse paypalresult =  (PaypalResponse)JSON.deserializeStrict(rsep, PaypalResponse.class);
        String responseUrl = '';
        if(!paypalresult.links.isEmpty()) {
            for(Links link : paypalresult.links) {
                if(link.rel == 'approval_url') {
                    responseUrl = link.href;
                }
            }
        }
        System.debug('responseUrl --  ' + responseUrl);
        return responseUrl;
    }
    
    public class PaypalResponse {
        public String id {get;set;} 
        public String intent {get;set;} 
        public String state {get;set;} 
        public Payer payer {get;set;} 
        public List<Transactions> transactions {get;set;} 
        public String note_to_payer {get;set;} 
        public String create_time {get;set;} 
        public List<Links> links {get;set;} 
    }
    
    public class Payer {
		public String payment_method {get;set;} 
	}
	
	public class Transactions {
		public Amount amount {get;set;} 
		public String description {get;set;} 
		public String custom {get;set;} 
		public String invoice_number {get;set;} 
		public String soft_descriptor {get;set;} 
		public Payment_options payment_options {get;set;} 
		public Item_list item_list {get;set;} 
		public List<String> related_resources {get;set;} 
	}
	
	public class Details {
		public String subtotal {get;set;} 
		public String tax {get;set;} 
		public String shipping {get;set;} 
		public String insurance {get;set;} 
		public String handling_fee {get;set;} 
		public String shipping_discount {get;set;} 
	}
	
	public class Item_list {
		public List<Items> items {get;set;} 
		public Shipping_address shipping_address {get;set;} 
	}
	
	public class Amount {
		public String total {get;set;} 
		public String currencyMode {get;set;} // in json: currency
		public Details details {get;set;} 
	}
	
	public class Payment_options {
		public String allowed_payment_method {get;set;} 
		public Boolean recurring_flag {get;set;} 
		public Boolean skip_fmf {get;set;} 
	}
	
	public class Links {
		public String href {get;set;} 
		public String rel {get;set;} 
		public String method {get;set;}
	}
	
	public class Items {
		public String name {get;set;} 
		public String sku {get;set;} 
		public String description {get;set;} 
		public String price {get;set;} 
		public String currencyMode {get;set;} // in json: currency
		public String tax {get;set;} 
		public Integer quantity {get;set;} 
	}
	
	public class Shipping_address {
		public String recipient_name {get;set;} 
		public String line1 {get;set;} 
		public String line2 {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String postal_code {get;set;} 
		public String country_code {get;set;} 
		public String phone {get;set;} 
	}
}