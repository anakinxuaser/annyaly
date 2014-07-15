/** 
 *  Description : Handler class to retrieve and upload file content to AmazonS3. 
 *
 *  Revision History:
 *
 *  Version          Author              Date                Description
 *  1.0              Vishal Prasad       27/06/2014          Initial Draft
 */
public with sharing class AmazonHandler {
 
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
         HttpResponse res = new HttpResponse();
         if(!Test.isRunningTest()){
              res = h.send(req);
         }
         else {
         	  if(!url.contains('test')){
		           res.setHeader('Content-Type', 'application/json');
			       res.setBody('{"TranscriptCreditTypeID":1000,"AttemptedHours":3.0,"GPAHours":3.0}');
			       res.setStatusCode(200);
		      }
		      else{
		           res.setHeader('Content-Type', 'text/xml');
		           res.setBody('<?xml version="1.0" encoding="UTF-8"?><Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message><RequestId>06F3712510FA6773</RequestId></Error>');
			       res.setStatusCode(400);
		     }
         }
         return res;
    } 
    /**
     * Method to do httpcallout to Amazon S3 server to get information stored in object file.
     * After successfull/Failed callout, it updates event object with status and fetched content from Amazon file object.
     * Arugment : List of EventBean Object and Map of Id and System.
     * 
     */
    public static void getInfo(List<EventBean> newEventBeanList,Service__c serviceObj, Map<id,System__c> sysMap){
    
        List<Event__c> updateEventList = new List<Event__c>();
        for(EventBean newEventBeanInst : newEventBeanList){
                Event__c newEventInst = newEventBeanInst.eventObj;
           		System__c sourceSystemInst = sysMap.get(newEventInst.Source_System__c);
           		if(sourceSystemInst.Credentials__r != null && sourceSystemInst.Credentials__r.size()>0){
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
           		else{
           			 newEventInst.Content_JSON__c = Label.Credential_Not_Available;
           			 newEventInst.Event_State_ID__c = Label.Error_State;
           			 updateEventList.add(newEventInst);
           		}      
        }
        try{
             Database.SaveResult[] updateResults = Database.update(updateEventList,false);
             List<Event__c> copyUpdateEventList = new List<Event__c>();
             
             for(Integer i=0; i<updateResults.size(); i++){
	             if (!updateResults.get(i).isSuccess()){
	                 // DML operation failed
	                 Database.Error error = updateResults.get(i).getErrors().get(0);
	                 String failedDML = error.getMessage();
	                 failedDML = failedDML.subString(0,100);
	                 Event__c eInst = updateEventList.get(i);//failed record from the list
				     eInst.Content_JSON__c = failedDML;
		             eInst.Event_State_ID__c = Label.Error_State;
		             copyUpdateEventList.add(eInst);
	             }
	         }
             if(copyUpdateEventList.size()>0){
             	  Database.SaveResult[] srList1 = Database.update(updateEventList,false);
             }
        }
        catch(Exception e){} 
    }
}