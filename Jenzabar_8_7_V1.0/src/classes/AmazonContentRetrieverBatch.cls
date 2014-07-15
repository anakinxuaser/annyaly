/** 
 *  Description : Batch class to fetch contents from AmazonS3 for all new events and make them ready.This would be called from ScheduleEventHandler class. 
 *
 *  Revision History:
 *
 *  Version          Author              Date                Description
 *  1.0              Vishal Prasad       26/06/2014          Initial Draft
 */
public class AmazonContentRetrieverBatch implements Database.Batchable<EventBean>,Database.Stateful,EventInterface,Database.AllowsCallouts{
	public List<EventBean> eBeanList;
    public Map<Id, System__c> sysMap;
    public Service__c serviceObj;
    public AmazonContentRetrieverBatch(){}
	public AmazonContentRetrieverBatch(List<EventBean> eList, Service__c sObj, Map<Id, System__c> sMap){
		  eBeanList = new List<EventBean>();
		  sysMap = new Map<Id, System__c>();
		  serviceObj = new Service__c();
		  eBeanList.addAll(eList);
		  sysMap.putAll(sMap);	
		  serviceObj = sObj; 	
	}
	/**
	 * Iterative start method. 
	 * It will iterate over list of EventBean Object considering defined scope.
	 */
	public Iterable<EventBean> start(Database.BatchableContext BC) { 
	      return eBeanList;
	}
	/**
	 * Execute Method. 
	 * Argument : List<EventBean> 
	 * Call AmazonInfoRetriever Class to perform HTTP Call out to AmazonS3 and update EventList
	 */
	public void execute(Database.BatchableContext BC, List<EventBean> scope){
		  AmazonHandler.getInfo(scope,serviceObj,sysMap);
	}
	public void finish(Database.BatchableContext BC){
		  AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
		  //Send an email to the Apex job's submitter notifying of job completion.
		  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		  String[] toAddresses = new String[] {a.CreatedBy.Email};
		  mail.setToAddresses(toAddresses);
		  mail.setSubject('Amazon Content Retriever Batch Status: ' + a.Status);
		  mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
		  //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	/* Method to call batch class and pass arugments to its parameterised constructor.
	 * This method is declared in EventInterface.
	 */
	public void newEventBatchExecute(List<EventBean> ebList,Service__c sInst, Map<Id,System__c> sysMap){
		  AmazonContentRetrieverBatch batchObj = new AmazonContentRetrieverBatch (ebList,sInst,sysMap);
          Id batchId = Database.executeBatch(batchObj,Integer.valueOf(sInst.Transaction_Scope__c));
	}

}