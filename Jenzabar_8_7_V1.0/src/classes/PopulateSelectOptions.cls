public class PopulateSelectOptions {

public Case c {get;set;}
public List<SelectOption> accountList {get;set;}

public PopulateSelectOptions(ApexPages.StandardController cont){
c = (Case)cont.getRecord();
populateList();
}

private void populateList(){
    accountList = new List<SelectOption>();
    //I am populating a query to dynamically fill the select list...normally this would be with a related object
    List<Account> accs = [SELECT Id,Name FROM Account LIMIT 100];
    for (Account a : accs){
        accountList.add(new SelectOption(a.Id,a.Name));
    }
}

public void actionMethod(){
    //some kind of logic
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'This was rerendered by the component'));
}

}