@isTest(seeAllData = true)
public with sharing class CaseTriggerHelperHandlerTest {

   static testMethod void testCaseTrigger() {
	               
            CaseTriggerHelperHandler caseTriggerHelperHandler = new CaseTriggerHelperHandler();
	
			Contact contactTest = new Contact(LastName = 'testContact1', Person_Id__c = '894');
            insert contactTest; 
            Case caseTest = new Case(Name__c = 'testContact1', Contact_External_Id__c = contactTest.Person_Id__c);
            insert caseTest;
            
           List<Case> newCase = [Select id, ContactId, Contact_External_Id__c, Name__c, SuppliedEmail, Lead_Link__c FROM Case WHERE id = :caseTest.id];
		   caseTriggerHelperHandler.searchAddContact(newCase);
		   
		    List<Case> newCaseLst = [Select ContactId FROM Case WHERE id = :caseTest.id];
            
            system.assertEquals(newCaseLst.size(), 1);
           
            
            Case caseTestNE = new Case(Name__c = 'testContact1', Contact_External_Id__c = '5590');
            insert caseTestNE;
            List<Case> newCaseNE = [Select id, ContactId, Contact_External_Id__c, Name__c, SuppliedEmail, Lead_Link__c FROM Case WHERE id = :caseTest.id];

            
            
            Contact contactTestN = new Contact(LastName = 'abc', Email = 'abc123@gmail.com');
            insert contactTestN; 
            Case caseTestN = new Case(Name__c = 'abc', SuppliedEmail = 'abc123@gmail.com');
            insert caseTestN;
            List<Case> newCaseN = [Select id, ContactId, Contact_External_Id__c, Name__c, SuppliedEmail, Lead_Link__c FROM Case WHERE id = :caseTestN.id];
            
            
            caseTriggerHelperHandler.searchAddContact(newCaseN);
            
            
            Lead leadTest = new Lead(LastName = 'test', Email = 'test@gmail.com', Company = 'pqr');
            insert leadTest;
            Case caseTestLN = new Case(Name__c = 'test', SuppliedEmail = 'test@gmail.com');
            insert caseTestLN;
            List<Case> newCaseLN = [Select id, ContactId, Contact_External_Id__c, Name__c, SuppliedEmail, Lead_Link__c FROM Case WHERE id = :caseTestLN.id];
            
            caseTriggerHelperHandler.searchAddContact(newCaseLN);
            
            
       		List<Case> updatedCase = new List<Case>();
            
          	caseTriggerHelperHandler.updateContact(newCase, updatedCase);
            
            
            Contact contactNew = new Contact(LastName = 'testContact1', Email = 'testContact1@gmail.com');
            insert contactNew;
            Case caseTestNEUpd = new Case(Name__c = 'testContact1', Suppliedemail = 'testContact1@gmail.com');
            insert caseTestNEUpd;
            List<Case> newCaseNEUpd = [Select id, ContactId, Contact_External_Id__c, Name__c, SuppliedEmail, Lead_Link__c FROM Case WHERE id = :caseTestNEUpd.id];
            
         
            
            caseTriggerHelperHandler.updateContact(newCaseNEUpd, updatedCase);
            
            
			Lead leadTestNew = new Lead(LastName = 'test', Email = 'test@gmail.com', Company = 'pqr');
			insert leadTestNew;
            Case caseTestLNew = new Case(Name__c = 'test', SuppliedEmail = 'test@gmail.com');
            insert caseTestLNew;
            List<Case> newCaseLNew = [Select id, ContactId, Contact_External_Id__c, Name__c, SuppliedEmail, Lead_Link__c FROM Case WHERE id = :caseTestLNew.id];
            
            caseTriggerHelperHandler.updateContact(newCaseLNew, updatedCase);
            
            
            Case caseTest1 = new Case(Name__c = 'test');
            insert caseTest1;
            List<Case> newCaseL1 = [Select id, ContactId, Contact_External_Id__c, Name__c, SuppliedEmail, Lead_Link__c FROM Case WHERE id = :caseTest1.id];
            
            caseTriggerHelperHandler.updateContact(newCaseL1, updatedCase);
                
            Lead leadTestNewExt = new Lead(LastName = 'testContact12', Email = 'testContact12@gmail.com', Company = 'pqr');
			insert leadTestNewExt;
            Case caseTestExt = new Case(Name__c = 'testContact12', Contact_External_Id__c = '65954', SuppliedEmail = 'testContact12@gmail.com');
            insert caseTestExt;
            List<Case> newCaseExt = [Select id, ContactId, Contact_External_Id__c, Name__c, SuppliedEmail, Lead_Link__c FROM Case WHERE id = :caseTestExt.id];
			
			
            caseTriggerHelperHandler.searchAddContact(newCaseExt);
            
            List<Case> caseUpdateLst=new List<Case>();
             List<Case> caseUpdateNewLst=new List<Case>();
            for(case caseObjItr:newCaseL1){
            			caseObjItr.Contact_External_Id__c='5674';	
            			caseUpdateLst.add(caseObjItr);  
            }
            update caseUpdateLst;
            

			 for(case caseObjNewItr:newCaseExt){
            			caseObjNewItr.Contact_External_Id__c='';	
            			caseObjNewItr.Name__c='testContact12';
            			caseObjNewItr.SuppliedEmail='testContact12@gmail.com';
            			caseUpdateNewLst.add(caseObjNewItr);  
            }
            update caseUpdateNewLst;
            
            set<Id> caseIdSet=new  set<Id>();
            for(Case caseObjNewItr:caseUpdateNewLst){
            			caseIdSet.add(caseObjNewItr.Id);			
            }
            
            List<Case> newCaseTestLst = [Select ContactId FROM Case WHERE id In : caseIdSet];
            system.assertEquals(newCaseTestLst.size(), 1);
            
            Map<id,sObject> testMap=new Map<id,sObject>();
            CaseTriggerHandler CaseTriggerHandler=new CaseTriggerHandler();
            CaseTriggerHandler.bulkBefore();
            CaseTriggerHandler.bulkAfter();
            CaseTriggerHandler.afterInsert(newCaseTestLst);
            CaseTriggerHandler.beforeDelete(newCaseTestLst);
            CaseTriggerHandler.afterDelete(newCaseTestLst);
            CaseTriggerHandler.afterUpdate(testMap,testMap);
		    CaseTriggerHandler.andFinally();
    } 

}