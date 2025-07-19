# Employee Migration SQL Script

This SQL script is designed to migrate employee data from an existing database (assumed to be part of the Human Resources system) into a new table called `employeemigration`. It performs the following operations:

* Drops the existing `employeemigration` table (if it exists).
* Creates the `employeemigration` table to store employee data.
* Creates a non-clustered index on the `jobtitle` column for faster queries.
* Migrates employee data from the source tables into the `employeemigration` table with specific columns.
* Uses a transaction to ensure data integrity during the migration process, with error handling (rollback in case of failure).

## SQL Script Breakdown

### 1. Drop the Existing Table (if it exists)

```sql
drop table if exists employeemigration;
go
```

This part of the script ensures that any existing `employeemigration` table is dropped before creating a new one.

### 2. Create the `employeemigration` Table

```sql
create table employeemigration (
    employeeid int not null,
    nationalidnumber nvarchar(40) not null,
    jobtitle nvarchar(200),
    department nvarchar(50),
    shift nvarchar(20),
    hiredate datetime,
    modifieddate datetime
);
```

This statement creates the `employeemigration` table with the following columns:

* `employeeid`: A unique identifier for each employee (Primary Key is implied).
* `nationalidnumber`: A unique national ID number for each employee.
* `jobtitle`: The employee’s job title.
* `department`: The department the employee belongs to.
* `shift`: The work shift the employee works in.
* `hiredate`: The date the employee was hired.
* `modifieddate`: The date when the employee’s record was last modified.

### 3. Create Non-Clustered Index on `jobtitle`

```sql
create nonclustered index ix_jobtitle on employeemigration (jobtitle);
```

This creates a non-clustered index on the `jobtitle` column to improve query performance when filtering or sorting by `jobtitle`.

### 4. Begin Transaction and Data Insertion

```sql
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
    e.hiredate >= '2008-01-01';
  commit transaction;
end try
begin catch
  rollback transaction;
  throw;
end catch;
```

This block handles the data insertion inside a transaction to ensure atomicity. It does the following:

* Starts a transaction.
* Performs an `INSERT` operation to migrate data from multiple source tables (`employee`, `employeedepartmenthistory`, `department`, and `shift`) into the `employeemigration` table.
* The query filters employee data based on a hire date (`e.hiredate >= '2008-01-01'`).
* If the `INSERT` operation is successful, the transaction is committed.
* If an error occurs, the transaction is rolled back and the error is thrown.

### 5. Query the Data

```sql
select * from employeemigration;
```

Finally, the script queries the `employeemigration` table to display all the records that have been inserted into the table.

## How to Use the Script

1. **Ensure Prerequisite Tables Exist:**

   * Ensure that the `humanresources.employee`, `humanresources.employeedepartmenthistory`, `humanresources.department`, and `humanresources.shift` tables exist in your database and contain the relevant data.
2. **Run the Script:**

   * Execute the script in your SQL Server Management Studio (SSMS) or another SQL client tool that supports T-SQL.
   * The script will first drop the existing `employeemigration` table (if it exists), create a new table, create an index, and then insert employee data based on the provided criteria.
3. **Verify Results:**

   * After the script runs, you can query the `employeemigration` table to verify that the data has been successfully migrated:

     ```sql
     select * from employeemigration;
     ```

## Error Handling

* The script uses a `TRY...CATCH` block to ensure any errors during the insertion process will roll back the transaction and preserve the integrity of the data. If an error occurs, the transaction is rolled back, and the error is re-thrown for troubleshooting.

## Future Enhancements

* **Logging:** Add logging to track any errors during data migration.
* **Parameterization:** The script can be enhanced to accept dynamic parameters for filtering data (such as hire date).
* **Database Backup:** Before running the script in a production environment, consider creating a backup of the database to avoid data loss.
This script is open-source and free to use. It is licensed under the MIT License.

---
