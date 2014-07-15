@isTest(SeeAllData=true)
private class CustomLookupCtlrTest {
    static testMethod void testCustomLookupCtlrWithRecordType(){
    Reference_Mapping__c rMap = new Reference_Mapping__c(
                                    Object_Name__c = 'Contact',
            						API_Name__c = 'Religion_Type__c',
            						Reference_Record_Type__c = 'ref_organizationroletype');
    
    insert rMap;
    system.assert(rMap.id != null, 'Reference Mapping record Created Successfully.');
    
    List<RecordType> lstRec = [Select Name,Id 
                               From RecordType 
                               where name='ref_organizationroletype'];
                               
    system.assert(lstRec[0].id != null, 'Record type id get Successfully.');      
      
    Reference__c ref = new Reference__c(RecordTypeId =lstRec[0].id);
    insert ref;
    Contact con = new Contact(LastName = 'test contact');
    insert con;
    system.assert(con.id != null, 'Contact record Created Successfully.');
    PageReference pageRef = Page.ContactCustomLookup;
    system.Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id',con.id);
    CustomLookupCtlr clc = new CustomLookupCtlr();  
    	clc.flagRecType = true;
        clc.setobjectName('Contact');
        clc.getobjectName();
        clc.Edit();
        clc.doSave();
        clc.Cancel();
    CustomLookupCtlr.findSObjects('Contact', 'hin', 'Religion_Type__c');
    } 
    
    static testMethod void testCustomLookupCtlrWithNoRecordType(){
    Reference_Mapping__c rMap = new Reference_Mapping__c(
                                    Object_Name__c = 'Contact',
            						API_Name__c = 'Religion_Type__c',
            						Reference_Record_Type__c = 'ref_organizationroletype');
    
    insert rMap;
    system.assert(rMap.id != null, 'Reference Mapping record Created Successfully.');
    
    List<RecordType> lstRec = [Select Name,Id 
                               From RecordType 
                               where name='ref_organizationroletype'];
                               
    system.assert(lstRec[0].id != null, 'Record type id get Successfully.');      
      
    Reference__c ref = new Reference__c(RecordTypeId =lstRec[0].id);
    insert ref;
    Contact con = new Contact(LastName = 'test contact');
    insert con;
    system.assert(con.id != null, 'Contact record Created Successfully.');
    PageReference pageRef = Page.ContactCustomLookup;
    system.Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id',con.id);
    CustomLookupCtlr clc = new CustomLookupCtlr();  
    	clc.flagRecType = false;
        clc.setobjectName('Contact');
        clc.getobjectName();
    CustomLookupCtlr.findSObjects('Contact', 'hin', 'Religion_Type__c');
    } 
}