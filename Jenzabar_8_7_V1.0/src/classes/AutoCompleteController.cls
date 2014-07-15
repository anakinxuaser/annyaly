global class AutoCompleteController 
{
    @RemoteAction
    global static SObject[] findSObjects(string obj, string qry, string addFields, string profilename) 
    {
    	
        /* List to store Reference Mapping records */        
        List<Reference_Mapping__c> refMapping = new List<Reference_Mapping__c>();
        
        
        /* Creating the filter text */
        String filter = ' like \'%' + String.escapeSingleQuotes(qry) + '%\'';
        
        /* Begin building the dynamic soql query */
        String soql = 'SELECT Name';      
        
        /* Adding the object and filter by name to the soql */
        soql += ' from ' + 'Reference__c' + ' where name' + filter;        
        //soql += ' from ' + 'Reference__c' + ' where name LIKE \''+'dua'+'%\'';        
        
        /* Querying the  */
        if (addFields != null) 
        {
                refMapping = [Select Reference_Record_Type__c from Reference_Mapping__c where Object_Name__c = :obj and API_Name__c = :addFields];			
        }
        
        if(refMapping.size()>0){
            soql += ' and RecordType.Name=\''+refMapping[0].Reference_Record_Type__c+'\'';
            soql += ' order by Name limit 20';
            
            List<sObject> L = new List<sObject>();
            try 
            {
                L = Database.query(soql);
            }
            catch (QueryException e) 
            {
                return null;
            }
        
            return L;
        }else{
            return null;
        }
   }
}