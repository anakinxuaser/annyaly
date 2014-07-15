/*
 * Description : A class that contains the method that are related to the
 *               External Records mapping which handles all the functionality related 
 *               to External Records.
 */

public class ExternalRecMappingHandler{
	
	 /* This method will set all the lookup field those required ID to be mapped to false
     * so that we can check for stub record creation for those are not present.
     */
    public static Map<String,Boolean> init(Map<String,String> pJsonContent){
        
        Map<String,Boolean> returnMap = new Map<String,Boolean>();
        for(String strItr : pJsonContent.keySet()){
            returnMap.put(strItr,false);
        }
        
        return returnMap;
    }
    
    // This method will be used to fetch the Internal ID for any External Record.
  	public static Map<String,String> getExternalRecordFieldValues(Map<String,String> pLookupMap,Map<String,String>pLookupSystem,Set<String> pObjectReferenced){
  	
  		Map<String,Boolean> refJsonContent = init(pLookupMap);
  		for(External_Record__c extItr : [SELECT Internal_ID__c,
                                                External_ID__c,
                                                Internal_Type__c
                                                FROM External_Record__c
                                                WHERE External_ID__c IN: pLookupMap.values() 
                                                AND Internal_Type__c IN: pObjectReferenced]
                                                ){
            if(pLookupMap.containsKey(extItr.Internal_Type__c+','+extItr.External_ID__c) &&
                extItr.Internal_Type__c != null && extItr.External_ID__c != null && extItr.Internal_ID__c != null){
                refJsonContent.put(extItr.Internal_Type__c+','+extItr.External_ID__c,true);
                pLookupMap.put(extItr.Internal_Type__c+','+extItr.External_ID__c,extItr.Internal_ID__c);
            }
         }
         
         for(String str : refJsonContent.keySet()){
         	if(refJsonContent.get(str) == true){
         		refJsonContent.remove(str);
         	}
         }
         
         if(!refJsonContent.isEmpty()){
         	NotificationUtilityController.createStubRec(pLookupMap,refJsonContent,pLookupSystem);
         }
         return pLookupMap;
    }
}