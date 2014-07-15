/** 
 *  Description : Handler class to retrieve and upload file content to AmazonS3. 
 *
 *  Revision History:
 *
 *  Version          Author              Date                Description
 *  1.0              Vishal Prasad       27/06/2014          Initial Draft
 */
public with sharing class AmazonHandler1 {
 
    /**
     * Method to create signature of amazon file
     * Argument: StringToSignByte and secret key of amazon account.
     * Return: Base64 encoded signature required to access file. 
     */
    private static String make_sig(string canonicalBuffer, String secretKey) {        
        String macUrl ;
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(secretKey));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(secretKey)); 
        macUrl = EncodingUtil.base64Encode(mac);              
        return macUrl;
    }
    /**
     * Method to do common call out for GET and PUT method.
     * Argument: Credential record,fileName to read and mode of call out
     * Return: Return response object to its caller method.
     */
    private static HttpResponse getHttpResponseBody(Credentials__c credInst, String fileName, String mode,String endPointUrl){
    	 String stringtosign;
         Datetime now = DateTime.now();
         Datetime expireson = now.AddHours(1);
         Long Lexpires = expireson.getTime()/1000;       
         if(mode.equalsIgnoreCase('GET')){
        	   stringtosign = 'GET\n\n\n'+Lexpires+'\n/'+credInst.Bucket_Name__c+'/'+fileName;
         }
         String signed = make_sig(stringtosign,credInst.Credentials__c);
         String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
         String url = endPointUrl + fileName+'?AWSAccessKeyId='+credInst.Token__c+'&Expires='+Lexpires+'&Signature='+codedsigned;
         Http h = new Http();
         HttpRequest req = new HttpRequest();
         req.setEndpoint(url);
         req.setMethod(mode); // GET or POST
         HttpResponse res = h.send(req);
         return res;
    } 
    /**
     * Method to do httpcallout to Amazon S3 server to get information stored in object file.
     * After successfull/Failed callout, it updates event object with status and fetched content from Amazon file object.
     * Arugment : List of EventBean Object and Map of Id and System.
     * 
     */
    public static void getInfo(List<EventBean> newEventBeanList,Service__c serviceObj, Map<id,System__c> sysMap,Map<String,String> externalSysMap){
        List<Event__c> updateEventList = new List<Event__c>();
        for(EventBean newEventBeanInst : newEventBeanList){
            
                Event__c newEventInst = newEventBeanInst.eventObj;
                if(externalSysMap != null && !externalSysMap.isEmpty()){
               		System__c sourceSystemInst = sysMap.get(Id.ValueOf(externalSysMap.get(newEventInst.SourceSystem_ID__c)));
	                for(Credentials__c credInst : sourceSystemInst.Credentials__r){
	                      if(credInst.Service__c == serviceObj.id){ // if source system has multiple retrievers then credential should be used only for retriever associated to this class
	                            try{
	                            	String fileName ='';
	                                String urlInfo = newEventBeanInst.link;
	                                if(urlInfo != null && urlInfo != ''){
	                                	 Integer i = urlInfo.lastIndexOf('/');
	                                	 fileName = urlInfo.subString(i+1,urlInfo.length());
	                                	 filename = EncodingUtil.urlEncode(filename, 'UTF-8');
										 urlInfo = urlInfo.subString(0,i+1);
	                                }
	                                HttpResponse res = getHttpResponseBody(credInst,filename,'GET',urlInfo);
	                                if(res != null && res.getBody() != null && (newEventInst.Content_JSON__c == null || newEventInst.Content_JSON__c == '')){
	                                      newEventInst.Content_JSON__c = res.getBody();
	                                }
	                                if(res.getStatusCode() != 200){
	                                     newEventInst.Event_State_ID__c = Label.Error_State;
	                                }
	                            }
	                            catch(Exception ex){
	                                 newEventInst.Event_State_ID__c = Label.Error_State;
	                            	 if(newEventInst.Content_JSON__c == null || newEventInst.Content_JSON__c == ''){
	                                 	 newEventInst.Content_JSON__c = ex.getMessage();
	                            	 }
	                            }
	                            updateEventList.add(newEventInst);
	                            break;         
	                     }
	                } 
                }          
        }
        try{
             update updateEventList;
        }
        catch(Exception e){
        }   
    }
    public static void putInfo(){
    	String bucketName = 'dev.crm.campusops.net';
		String AWS = 'AKIAJT7RI5J7D6MJSH2Q';
		String cred = 'ZibrJw7pAqprSllbZKD0aDD0ukEv1P4iPIG0WKSp';
		String myContent = '{"TranscriptCreditTypeID":1000,"AttemptedHours":3.0,"GPAHours":3.0,"EarnedHours":3.0,"ProgramID":null,"GradeScoreDefinitionID":0,"TerminationTime":null,"GradeScaleTypeID":0,"StudentID":38,"CreationTime":null,"AttendanceExpected":null,"IsRepeat":false,"CompleteOnTermination":false,"CEUHours":0.0,"AttendanceActual":null,"oca":3,"SectionID":58,"GPAValue":12.0}'; 
		
		String stringtosign;
		Datetime now = DateTime.now();
		Datetime expireson = now.AddHours(1);
		Long Lexpires = expireson.getTime()/1000;       
		
		stringtosign = 'PUT\n\n\n'+Lexpires+'\n/'+bucketName+'/'+'Sample1.json';
		
		String macUrl ;
		String signingKey = EncodingUtil.base64Encode(Blob.valueOf(cred));
		Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(stringtosign),blob.valueof(cred)); 
		macUrl = EncodingUtil.base64Encode(mac);
		
		String signed = macUrl;
		String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
		String url = 'http://dev.crm.campusops.net.s3.amazonaws.com/Sample1.json'+'?AWSAccessKeyId='+AWS+'&Expires='+Lexpires+'&Signature='+codedsigned;
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBodyAsBlob(Blob.valueOf(myContent));
		req.setEndpoint(url);
		req.setMethod('PUT'); 
		
		HttpResponse res = h.send(req);
		system.debug('--------------'+res);
    }
}