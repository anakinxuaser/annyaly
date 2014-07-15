/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ScheduleEventHandlerTest {

    static testMethod void testScheduleEventHandler() {
    	
    	List<Event__c> eventTestList = new List<Event__c>();
    	List<Content_Mapping__c> contentTestMapList = new List<Content_Mapping__c>();
    	
    	System__c sysTestInst = new System__c(Name__c = 'HIR',Description__c = 'Test System');
    	insert sysTestInst;
    	Service__c serviceTestInst = new Service__c(Name = 'Amazon', Class__c = 'AmazonContentRetrieverBatch',	Transaction_Scope__c = 10);
    	insert serviceTestInst;
    	
    	Credentials__c credTestInst = new Credentials__c(Bucket_Name__c = 'dev.crm.campusops.net',Credentials__c ='ZibrJw7pAqprSllbZKD0aDD0ukEv1P4iPIG0WKSp',Service__c = serviceTestInst.id,System__c = sysTestInst.id,Token__c='AKIAJT7RI5J7D6MJSH2Q', URL__c='http://dev.crm.campusops.net.s3.amazonaws.com');
    	insert credTestInst;
    	
    	insert new TriggerSetting__c(Name = 'Topic',Handler_Names__c='TopicTriggerHandler');
    	
    	Topic__c topicTestInst = new Topic__c(Name__c = 'Test Topic',Object_Name__c = 'Contact',Scope__c = 10);
    	insert topicTestInst;
    	
    	insert new TriggerSetting__c(Name = 'ContentMapping',Handler_Names__c='ContentMappingTriggerHandler');
    	
    	Content_Mapping__c conTestInst1 = new Content_Mapping__c(JSONField__c='Kind',JSONObject__c='',Local_Field__c='Type',LocalObject__c='',Source_ID__c=sysTestInst.id,Status__c=true);
    	Content_Mapping__c conTestInst2 = new Content_Mapping__c(JSONField__c='Url',JSONObject__c='',Local_Field__c='Location',LocalObject__c='',Source_ID__c=sysTestInst.id,Status__c=true);
    	contentTestMapList.add(conTestInst1);
    	contentTestMapList.add(conTestInst2);
    	insert contentTestMapList;
    	
    	Event__c eventTestInst1 = new Event__c(Event_State_ID__c='New',Content_JSON__c='',Retriever_Info__c='{"Url":"http://dev.crm.campusops.net.s3.amazonaws.com/file1.txt","Kind":"Amazon"}',Source_System__c = sysTestInst.id,Topic__c=topicTestInst.id);
        Event__c eventTestInst2 = new Event__c(Event_State_ID__c='New',Content_JSON__c='',Retriever_Info__c='{"Url":"http://dev.crm.campusops.net.s3.amazonaws.com/file2.txt","Kind":"Amazon"}',Source_System__c = sysTestInst.id,Topic__c=topicTestInst.id);
        Event__c eventTestInst3 = new Event__c(Event_State_ID__c='New',Content_JSON__c='',Retriever_Info__c='{"Url":"http://test.s3.amazonaws.com/file3.txt","Kind":"Amazon"}',Source_System__c = sysTestInst.id,Topic__c=topicTestInst.id); 
        Event__c eventTestInst4 = new Event__c(Event_State_ID__c='New',Content_JSON__c='',Retriever_Info__c='{"Url":"http://test.s3.amazonaws.com/file3.txt","Kind":"AmazonTest"}',Source_System__c = sysTestInst.id,Topic__c=topicTestInst.id);      
        Event__c eventTestInst5 = new Event__c(Event_State_ID__c='New',Content_JSON__c='',Retriever_Info__c='{"Url":"","Kind":"Amazon"}',Source_System__c=sysTestInst.id,Topic__c=topicTestInst.id);           
        
        Event__c eventTestInst6 = new Event__c(Event_State_ID__c='Ready',Content_JSON__c='{"TranscriptCreditTypeID":1001,"AttemptedHours":4.0,"GPAHours":7.0,"EarnedHours":3.0}',Retriever_Info__c='{"Url":"http://dev.crm.campusops.net.s3.amazonaws.com/file4.txt","Kind":"Amazon"}',Source_System__c=sysTestInst.id,Topic__c=topicTestInst.id);
        Event__c eventTestInst7 = new Event__c(Event_State_ID__c='Ready',Content_JSON__c='{"TranscriptCreditTypeID":1002,"AttemptedHours":5.0,"GPAHours":8.0,"EarnedHours":3.0}',Retriever_Info__c='{"Url":"http://dev.crm.campusops.net.s3.amazonaws.com/file5.txt","Kind":"Amazon"}',Source_System__c=sysTestInst.id,Topic__c=topicTestInst.id);
        
        eventTestList.add(eventTestInst1);
        eventTestList.add(eventTestInst2);
        eventTestList.add(eventTestInst3);
        
        eventTestList.add(eventTestInst4);
        eventTestList.add(eventTestInst5);
        eventTestList.add(eventTestInst6);
        eventTestList.add(eventTestInst7);
      
        
        insert eventTestList;
    	
        Test.StartTest();
           ScheduleEventHandler.fetchNewEvent();
           ScheduleEventHandler.createReadyQueue();
        Test.StopTest();
        List<Event__c> tempList= [Select id,Event_State_ID__c from Event__c where id IN : eventTestList];
        system.assertEquals(tempList[0].Event_State_ID__c,'Ready');    
        system.assertEquals(tempList[1].Event_State_ID__c,'Ready');  
        system.assertEquals(tempList[2].Event_State_ID__c,'Error');   
    }      
}