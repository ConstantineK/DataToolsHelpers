# DataToolsHelpers

## What is this?

This is a powershell module that can -

* Copy data out of a newer edition of SQL Server into an older one.
* Copy data in and out of AWS RDS or Azure SQL DB and On-Premises data stores.
* Make easy the transportation of data in and out of SQL Server everywhere.

If you have backups, log shipping, replication, or other options available to you, you probably want to use them.
This is for when you dont care about transactional consistency and you just want to copy data from one place to another.

## How to use this stuff?

You might be someone whose not super familiar with PowerShell or BCP, and I linked you here.
If so, here's everything you need to get off the ground.

* This repository (just download the zip)
* bcp - data [https://docs.microsoft.com/en-us/sql/tools/bcp-utility?view=sql-server-ver15]
* sqlpackage - schemas - [https://docs.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download]

Once they are installed on your system, just run the following in your PS Console:

``` powershell
Import-Module DataToolsHelpers.ps1
```

Check what commands are availab with:

``` powershell
Get-Command -Module DataToolsHelpers
```

Today you should see Build-FormatFile, Build-DataFile, and Sync-DataFile available to you.

I am still working on the schema migration bits from either sqlpackage or pure sql, but if you can make sure your skeleton is there you should be good to go.
I want to enable a friend of mine to do parallel diffs of the database structure and the stored procedure and view text 
Scripting out all the objects in a db can take awhile and be incomplete - dbatools does some, etc. 

What if I fork schemazen and see if I can merge all the PRs? 
It looks like people are no longer maintaining it 

Some portions of this code are licensed under the MIT license, but this is GPLv2 licensed. 

While Schemazen is nice, it makes it hard to do the thing and there's not much time to maintain it
What if we just use its models and then evolve it ourselves?

It looks like a decent set of things to compare, but if we enable the obvious ones (like not asssemblies) most people would be happy
So what does he have? 


## Schemazen Code Forking and Usage
Portions of this code base are directly taken from a project called Schemazen, which has fallen into disuse because of course, nobody is paying Seth to work on it.
I really like the queries and approach it uses, so I am looking at grabbing the code and modifying it.

His original approach is to have a model for each thing we query, which is a sane approach

Assembly.cs
Column.cs
ColumnList.cs
Constraint.cs
ConstraintColumn.cs
Database.cs
DatabaseDiff.cs
DbProperty.cs
Default.cs
Exceptions.cs
ForeignKey.cs
Identity.cs
Interfaces.cs
Permission.cs
Role.cs
Routine.cs
Schema.cs
SqlUser.cs
Synonym.cs
Table.cs
UserDefinedType.cs 

For now I will have a query per model and an associated object 
Let's start with the critical ones, everything to make normal objects.

Column, ColumnList, Constraint, ConstraintColumn, Database, Default, ForeignKey, Identity, Routine, Schema, Synonym, Table, UserDefinedype

The queries are all in Database.cs 
https://github.com/sethreno/schemazen/blob/efba832c8f4fbb0fd0987b64b62934a300dd7b55/Library/Models/Database.cs#L368

I also need to review the existing PRs and see how that would apply to my code base
The important thing is we 

query all the data in the views
emit the files in a parallel and sane fashion
consider storing the output of the data in the views in a local folder "cache" so we can just operate on the files

need some unit and behavioral tests
add pester in and we've got a good set of things

Pester Setup
Install-Module Pester -Force
