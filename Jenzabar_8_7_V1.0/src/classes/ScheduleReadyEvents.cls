/*
 * Description : A schedule class which will fetch the ready events & schedule it per every minute.
 */
global with sharing class ScheduleReadyEvents implements Schedulable{
    
    // This method will call a method to create queue.
    global void execute(SchedulableContext ctx) {
        this.start();
        ScheduleEventHandler.createReadyQueue();
    }  
    
    // This method will add the 1 minute to current time
    public void start()
    {
    	
    	Datetime dt = system.now().addMinutes(1);
        String day = string.valueOf(dt.day());
        String month = string.valueOf(dt.month());
        String hour = string.valueOf(dt.hour());
        String minute = String.valueOf(dt.minute());
        String second = string.valueOf(dt.second());
        String year = string.valueOf(dt.year());
        String strJobName = 'Event_Ready' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule(strJobName, strSchedule, new ScheduleReadyEvents ());
    } 
}