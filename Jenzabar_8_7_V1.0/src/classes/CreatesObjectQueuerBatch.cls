/* 
 * Description : Batch class for creating sObject 
 */
global class CreatesObjectQueuerBatch implements Database.Batchable<sObject>,QueuerInterface,Database.stateful {

    public static final string queryString = 'SELECT Id FROM Queue__c WHERE Id IN: queueIdsforBatch ';
    Set<Id> queueIdsforBatch = new Set<Id>();
    List<Queue__c> failedQueueUpdate = new List<Queue__c>();
    global CreatesObjectQueuerBatch(){}
    global CreatesObjectQueuerBatch(Set<Id> pQueIds){
        queueIdsforBatch.addAll(pQueIds);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Id> queueIds = new Set<Id>();
        for(sObject scopeItr : scope){
            queueIds.add(scopeItr.id); 
        }
        try{
            CreatesObjectQueuerController.execute(queueIds);
        }catch(Exception e){
            System.debug('exception message==='+e.getMessage());
            for(Queue__c queItr : [SELECT Retriever__c,Queue_State_ID__c FROM Queue__c WHERE Id IN: queueIds]){
            	System.debug(queItr);
                queItr.Queue_State_ID__c = Label.Queue_Error;
                queItr.Retriever__c = e.getMessage();
                failedQueueUpdate.add(queItr);
            }
        }
    }
    
    // Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
    global void finish(Database.BatchableContext BC){
        if(!failedQueueUpdate.isEmpty()){
            update failedQueueUpdate;
        }
            
        AsyncApexJob asynApexjob = [SELECT Id, 
                                        Status, 
                                        NumberOfErrors, 
                                        JobItemsProcessed,
                                        TotalJobItems, 
                                        CreatedBy.Email, 
                                        ExtendedStatus
                                        FROM AsyncApexJob 
                                        WHERE Id = :BC.getJobId()];
                         
         // Email the Batch Job's submitter that the Job is finished.
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] {asynApexjob.CreatedBy.Email};
         mail.setToAddresses(toAddresses);
         mail.setSubject('CreatesObjectQueuerBatch Job Status: ' + asynApexjob.Status);
         mail.setPlainTextBody('The batch Apex job processed ' + asynApexjob.TotalJobItems +
          ' batches with '+ asynApexjob.NumberOfErrors + ' failures. ExtendedStatus: ' + asynApexjob.ExtendedStatus);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void batchExecute(Set<Id> pQueIds,Integer pScope){
        CreatesObjectQueuerBatch batchObj = new CreatesObjectQueuerBatch (pQueIds);
        Id batchId = Database.executeBatch(batchObj,pScope);
    }
}