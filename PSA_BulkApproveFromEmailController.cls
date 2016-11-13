public class PSA_BulkApproveFromEmailController {

    public string Query{ get; set; }
    public date MyFilter6 {get;set;}
    public date MyFilter7 {get;set;}
        public date MyFilter8 { get{
       if(MyFilter8==null && apexpages.currentpage().getparameters().get('Date')!=NULL && TypeFilter == 'Daily' )
           return date.parse(apexpages.currentpage().getparameters().get('Date'));
       else if(MyFilter8==null && apexpages.currentpage().getparameters().get('Date')!=NULL && TypeFilter == 'Weekly' )
       {
           return date.parse(apexpages.currentpage().getparameters().get('Date'));
       }
       else
       return MyFilter8;
    }
 set; }
 public String TypeFilter { get{
       if(TypeFilter==null)
           return apexpages.currentpage().getparameters().get('Type');
       else
       return TypeFilter;
    }
 set; }
    public String QueryWhere = '';
    public String FinalQuery {get;set;}
    public String MyFilter5 { get; set; }

    public String MyFilter4 { get; set; }
    public String MyFilter3 { get{
       if(MyFilter3==null)
           return apexpages.currentpage().getparameters().get('ResFilter');
       else
       return MyFilter3;
    }
 set; }

    public String MyFilter2 { get{
       if(MyFilter2==null)
           return apexpages.currentpage().getparameters().get('AccFilter');
       else
       return MyFilter2;
    }
 set; }
    
    public String Comments {get; set;}

    public String MyFilter1 { get{
       if(MyFilter1==null)
           return apexpages.currentpage().getparameters().get('projFilter');
       else
       return MyFilter1;
    }
 set; }
public transient String lMCaseERjson{get;set;} 
public Date StartDate {get;set;}
public Date EndDate {get;set;}
public String MyFilter {get;set;}
public list<ProcessInstanceWorkitem> piw{
get{
if(TypeFilter == 'Daily')
return [Select id,ActorId,ProcessInstance.TargetObjectId,ProcessInstance.Status from ProcessInstanceWorkitem where ActorId=:UserInfo.getUserId() and ProcessInstance.Status = 'Pending' and CreatedDate>=:MyFilter8 and CreatedDate<:MyFilter8.addDays(1)];
else if(TypeFilter == 'Weekly')
{
return [Select id,ActorId,ProcessInstance.TargetObjectId,ProcessInstance.Status from ProcessInstanceWorkitem where ActorId=:UserInfo.getUserId() and ProcessInstance.Status = 'Pending' and CreatedDate>=:MyFilter8 and CreatedDate<:MyFilter8.addDays(8)];
}
return [Select id,ActorId,ProcessInstance.TargetObjectId,ProcessInstance.Status from ProcessInstanceWorkitem where ActorId=:UserInfo.getUserId() and ProcessInstance.Status = 'Pending'];
}set;}
public list<String> TC2ApproveBYUser = new list<String>();
public list<pse__Timecard_Header__c> getTimecards2Approve()
{

return [select Id, pse__Resource__r.Name,pse__Project__r.Name,pse__Total_Hours__c,pse__Start_Date__c , pse__Status__c , pse__Sunday_Hours__c ,Name from pse__Timecard_Header__c limit 5];
}
public pse__Proj__c proj{get;set;}
public list<pse__Timecard_Header__c> TC = new list<pse__Timecard_Header__c>();
public void populateMyTable()
{
for(ProcessInstanceWorkitem piwItem:piw)
{
TC2ApproveBYUser.add(piwItem.ProcessInstance.TargetObjectId);
}
Query = 'SELECT Id,pse__Resource__r.Name, pse__Friday_Hours__c , pse__Monday_Hours__c , pse__Saturday_Hours__c , pse__Sunday_Hours__c , pse__Thursday_Hours__c , pse__Tuesday_Hours__c , pse__Wednesday_Hours__c , pse__Friday_Notes__c , pse__Monday_Notes__c , pse__Saturday_Notes__c , pse__Sunday_Notes__c , pse__Thursday_Notes__c , pse__Tuesday_Notes__c , pse__Wednesday_Notes__c ,pse__Additional_Notes__c,pse__Project__r.Name,pse__Project__r.pse__Account__c,pse__Total_Hours__c,pse__Start_Date__c from pse__Timecard_Header__c where Id in:TC2ApproveBYUser';

if(MyFilter1!=NULL)
{
    
        QueryWhere+= ' and pse__Project__c = :MyFilter1';
    
}
if(MyFilter2!=NULL)
{
    
        QueryWhere+= ' and pse__Project__r.pse__Account__c = :MyFilter2';
    
}
if(MyFilter3!=NULL)
{

    QueryWhere += ' and pse__Resource__c = :MyFilter3';  

}
FinalQuery = QueryWhere==NULL||QueryWhere.length()==0?Query:Query + QueryWhere;

TC = Database.query(FinalQuery);
//system.assertEquals(TC,NULL);
lMCaseERjson = JSON.serialize(TC);
FinalQuery='';
QueryWhere='';
}

public void ApproveMyRecords()
{
    List<Id> TCH2ApproveIds = new List<Id>();
    List<pse__Timecard_Header__c> tc2bulkApprove = ((List<pse__Timecard_Header__c>)(JSON.deserialize(lMCaseERjson,List<pse__Timecard_Header__c>.class)));
    for(pse__Timecard_Header__c tch4:tc2bulkApprove)
    {
        TCH2ApproveIds.add(tch4.Id);
    }
    List<ProcessInstanceWorkitem> piwItem = [Select Id,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in:TCH2ApproveIds];
    Approval.ProcessWorkitemRequest req2;
    List<Approval.ProcessWorkitemRequest> listReq = new List<Approval.ProcessWorkitemRequest>();
    List<Approval.ProcessResult> result2 = new List<Approval.ProcessResult>();
    for(ProcessInstanceWorkitem piw1:piwItem)
    {
        req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments(Comments);
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(piw1.Id);
        listReq.add(req2);
        
    }
     result2 =  Approval.process(listReq,False);
     for(Approval.ProcessResult result1:result2)
     {
     if(!result1.isSuccess())
     {
         //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please rectify the erros befow'));
     }
     }
}
public List<SelectOption> projectsOwned{ get 
    
    {
     if(projectsOwned==null) 
     { projectsOwned = new List<SelectOption>(); }
       projectsOwned.add(new SelectOption('',' '));
       for(pse__proj__c p1: [select id,name from pse__proj__c])
       {
        
        projectsOwned.add(new SelectOption(p1.Id,p1.Name));
    
       }
       
      return projectsOwned; 
     } set;}
     
 public List<SelectOption> AccountsOwned { get
 {
 if(AccountsOwned==null) 
     { AccountsOwned = new List<SelectOption>(); }
       AccountsOwned.add(new SelectOption('',' '));
       for(Account a1: [select id,name from Account])
       {
        
        AccountsOwned.add(new SelectOption(a1.Id,a1.Name));
    
       }
       
      return AccountsOwned; 
 } set; }
 
 public List<SelectOption> ResourcesFilter{ get
 {
 if(ResourcesFilter==null) 
     { ResourcesFilter = new List<SelectOption>(); }
       ResourcesFilter.add(new SelectOption('',' '));
       for(Contact a1: [select id,name from Contact])
       {
        
        ResourcesFilter.add(new SelectOption(a1.Id,a1.Name));
    
       }
       
      return ResourcesFilter; 
 } set; }

}