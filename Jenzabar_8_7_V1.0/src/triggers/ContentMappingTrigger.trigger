trigger ContentMappingTrigger on Content_Mapping__c (after insert, after update) {
			TriggerFactoryNew.CreateHandler('ContentMapping');
}