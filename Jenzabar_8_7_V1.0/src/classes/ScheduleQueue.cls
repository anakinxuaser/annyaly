/*
 * Description : A schedule class which will fetch the new queue & schedule it per every minute.
 */
global class ScheduleQueue implements Schedulable {
    
    // This method will be used to call the queuer
    global void execute(SchedulableContext ctx) {
        this.start();
        ScheduleQueueHandler.scheduleQueue();
    }  
    
    // This method will add the 1 minute to current time
    public void start()
    {
    	Datetime dtObj = System.now().addminutes(1);
        String day = string.valueOf(dtObj.day());
        String month = string.valueOf(dtObj.month());
        String hour = string.valueOf(dtObj.hour());
        String minute = String.valueOf(dtObj.minute());
        String second = string.valueOf(dtObj.second());
        String year = string.valueOf(dtObj.year());
        String strJobName = 'Queue-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule(strJobName, strSchedule, new ScheduleQueue());
    } 
}