public with sharing class ContentMappingTriggerHelperHandler {
		
		public void createNewTopicContentInsert(List<Content_Mapping__c> newContentMapping){
					List<Topic_Content__c> topicContentInsertLst= new List<Topic_Content__c>();
					Map<String,List<Id>> topicMap= new Map<String,List<Id>>();
					set<String> localObjectSet = new set<String>();
					
					for(Content_Mapping__c contentMapObj:newContentMapping){
								localObjectSet.add(contentMapObj.LocalObject__c);
													
					}
						
					for(Topic__c topicItr:[SELECT Id,Object_Name__c 
										   FROM Topic__c 
										   WHERE Object_Name__c IN: localObjectSet]){
												  
						if(topicMap.containsKey(topicItr.Object_Name__c)){
									List<Id> topicIdLst =topicMap.get(topicItr.Object_Name__c);
									topicIdLst.add(topicItr.Id);
									topicMap.put(topicItr.Object_Name__c,topicIdLst);
						
						}				
						else{
									topicMap.put(topicItr.Object_Name__c,new List<Id>{topicItr.Id});
									system.debug('topicobjectname'+topicItr.Object_Name__c);
						}											  
					}			
					
					for(Content_Mapping__c ContentMappingItr:newContentMapping){
						
						if(topicMap.containsKey(ContentMappingItr.LocalObject__c)){
									
									for(Id topicIdItr:topicMap.get(ContentMappingItr.LocalObject__c)){
										Topic_Content__c  topContentObj=new Topic_Content__c();
												system.debug('contentmapid'+topicIdItr);
												system.debug('topicid'+ContentMappingItr.Id);
												topContentObj.Content_Mapping__c=ContentMappingItr.Id;
												topContentObj.Topic__c=topicIdItr;
												
												topicContentInsertLst.add(topContentObj);
									}
						}
						
					}		
					if(topicContentInsertLst.size()>0){		  
					insert topicContentInsertLst;
					}
		}
		
		public void updateTopicContent(Map<Id,Content_Mapping__c> newContentMappingMap, Map<Id,Content_Mapping__c> oldContentMappingMap){
						List<Topic_Content__c> topicContentDeleteLst=new List<Topic_Content__c>();
						List<Content_Mapping__c> newContentMappingLst= new List<Content_Mapping__c>();
						set<Id> contentMappingIdSet= new set<Id>();
					
					for(Content_Mapping__c contentMappingItr:newContentMappingMap.values()){
								if(contentMappingItr.LocalObject__c!= oldContentMappingMap.get(contentMappingItr.Id).LocalObject__c){		
											contentMappingIdSet.add(contentMappingItr.Id);
											newContentMappingLst.add(contentMappingItr);
								}
					}
					
					for(Topic_Content__c  topicContentItr:[SELECT Id 
														   FROM Topic_Content__c  
												 		   WHERE Content_Mapping__c IN:contentMappingIdSet]){
												  	
				    			topicContentDeleteLst.add(topicContentItr);							  
					}
					
					
					if(topicContentDeleteLst.size()>0){
					delete topicContentDeleteLst;
					}
					
					if(newContentMappingLst.size()>0)
					{
								ContentMappingTriggerHelperHandler ContentMappingTriggerHelperHandler=new ContentMappingTriggerHelperHandler();
								ContentMappingTriggerHelperHandler.createNewTopicContentInsert(newContentMappingLst);			
					}					
		}
}