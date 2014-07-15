/** 
 *  Description : Interface to be used with AmazonContentRetrieverBatch.This helps to initialize parametrized constructor dynamically.
 *
 *  Revision History:
 *
 *  Version          Author              Date                Description
 *  1.0              Vishal Prasad       26/06/2014          Initial Draft
 */
public interface EventInterface{
     void newEventBatchExecute(List<EventBean> ebList, Service__c serviceObj, Map<Id,System__c> sysMap);
}