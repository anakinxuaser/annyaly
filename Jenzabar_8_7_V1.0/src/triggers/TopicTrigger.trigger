trigger TopicTrigger on Topic__c (after insert, after update) {
            TriggerFactoryNew.CreateHandler('Topic');
}