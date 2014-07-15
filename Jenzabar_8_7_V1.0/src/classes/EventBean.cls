/** 
 *  Description : Wrapper class group event object, link and retriever type together. This will be used to process new events in AmazonContentRetrieverBatch class.
 *
 *  Revision History:
 *
 *  Version          Author              Date                Description
 *  1.0              Vishal Prasad       26/06/2014          Initial Draft
 */
public with sharing class EventBean {
	public Event__c eventObj;
      public String retriverType;
      public String link;
      public EventBean(){}
}