/* This interface will be used for all queuer classes where we will implement
 * the business logic in execute method
 */  
public interface BaseInterface {
    void execute(Id queueId);
}