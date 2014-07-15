public with sharing class TopicTriggerHelperHandler {
	
		
		public void createNewTopicContent(List<Topic__c> newTopic){
			List<Topic_Content__c> topicContentInsertLst= new List<Topic_Content__c>();
			List<Content_Mapping__c> contentMappingLst= new List<Content_Mapping__c>();
			Map<String,List<Id>> contentMappingMap= new Map<String,List<Id>>();
			Set<String> objectnameset=new Set<String>();
			
			//creating set of objectName From Topic__c Object 
			for(Topic__c topicItr:newTopic){
				 	if(topicItr.Object_Name__c!=null){
								objectnameset.add(topicItr.Object_Name__c);
				 	}
			}
			
			contentMappingLst=[SELECT Id,LocalObject__c 
							   FROM Content_Mapping__c 
							   WHERE LocalObject__c in:objectnameset];
							   
			//Creating a Map of ContentMapping__c String contains-localobject and list<Id> contains Id matching localobject				   
			for(Content_Mapping__c contentmapItr:contentMappingLst){
				
						if(contentMappingMap.containsKey(contentmapItr.LocalObject__c)){
									List<Id> contentMapIdLst =contentMappingMap.get(contentmapItr.LocalObject__c);
									contentMapIdLst.add(contentmapItr.Id);
									contentMappingMap.put(contentmapItr.LocalObject__c,contentMapIdLst);
						
						}				
						else{
									contentMappingMap.put(contentmapItr.LocalObject__c,new List<Id>{contentmapItr.Id});
						}											  				  
						
				
																	  
			}
			
			//if Localobject__c of ContentMapping__c and objectName__C of Topic Matches creates TopicContent Record.  
			for(Topic__c topicItr:newTopic){
						
						if(contentMappingMap.containsKey(topicItr.Object_Name__c)){
									
									for(Id contentMapIdItr:contentMappingMap.get(topicItr.Object_Name__c)){
										Topic_Content__c  topContentObj=new Topic_Content__c();
												system.debug('contentmapid'+contentMapIdItr);
												topContentObj.Topic__c=topicItr.Id;
												topContentObj.Content_Mapping__c=contentMapIdItr;
												topicContentInsertLst.add(topContentObj);
									}
						}
						
			}
		
			if(topicContentInsertLst.size()>0){
			insert topicContentInsertLst;
			}
		}
		
		public void updateTopicContent(Map<Id,Topic__c> newTopicMap, Map<Id,Topic__c> oldTopicMap){
					//Deletes 
					
					List<Topic_Content__c> topicContentDeleteLst=new List<Topic_Content__c>();
					List<Topic__c> newTopicLst = new List<Topic__c>();
					
					set<Id> topicIdSet= new set<Id>();
					for(Topic__c topicItr:newTopicMap.values()){
								if(topicItr.Object_Name__c!= oldTopicMap.get(topicItr.Id).Object_Name__c){	
											topicIdSet.add(topicItr.Id);
											newTopicLst.add(topicItr);
								}
					}
					topicContentDeleteLst = [SELECT Id FROM Topic_Content__c  
											WHERE Topic__c IN:topicIdSet];
					
					if (topicContentDeleteLst.size() > 0){
								delete topicContentDeleteLst;
					}
					
					if(newTopicLst.size()>0){
								TopicTriggerHelperHandler TopicTriggerHelperHandler=new TopicTriggerHelperHandler();
								TopicTriggerHelperHandler.createNewTopicContent(newTopicLst);
					}
		}
}