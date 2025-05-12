drop table if exists employeemigration 
go
create table employeemigration(
employeeid int not null   ,
nationalidnumber   nvarchar(40) not null,
jobtitle nvarchar(200),
department nvarchar(50),
shift nvarchar(20),
hiredate datetime,
modifieddate datetime );
create nonclustered index ix_jobtitle on employeemigration (jobtitle);

begin transaction;

begin try

  insert into employeemigration (employeeid, nationalidnumber, jobtitle, department, shift, hiredate, modifieddate)
  select 
   e.businessentityid as employeeid,
    e.nationalidnumber,
    e.jobtitle,
    d.name as department,
    s.name as shift,
    e.hiredate,
    e.modifieddate
  from 
    humanresources.employee e
  inner join 
    humanresources.employeedepartmenthistory edh on e.businessentityid = edh.businessentityid
  inner join 
    humanresources.department d on 
	edh.departmentid = d.departmentid
  inner join 
    humanresources.shift s on edh.shiftid = s.shiftid
  where 
    e.hiredate >= '2008-01-01'
  commit transaction;
end try
begin catch
  rollback transaction;
  throw;
  end catch;
  select * from employeemigration
