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