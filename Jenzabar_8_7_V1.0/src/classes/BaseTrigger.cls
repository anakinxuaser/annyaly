public abstract class BaseTrigger implements Itrigger{   
    public void insertRecord(list<sObject> sobjectLsttoUpdate){
        if(!sObjectLsttoUpdate.isEmpty()){
            try{
                insert sobjectLsttoUpdate;
            }catch(Exception e){
                System.debug('The insert exception : '+e.getMessage());
            }         
        }
    }    
    public void updateRecord(list<sObject> sobjectLsttoUpdate){
        if(!sObjectLsttoUpdate.isEmpty()){
            try{
                update sobjectLsttoUpdate;
            }catch(Exception e){
                System.debug('The update exception : '+e.getMessage());
            }           
        }
    }    
}