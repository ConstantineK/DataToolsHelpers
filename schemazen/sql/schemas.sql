select s.name as schemaName, p.name as principalName
from sys.schemas s
         inner join sys.database_principals p on s.principal_id = p.principal_id
where s.schema_id < 16384
  and s.name not in ('dbo', 'guest', 'sys', 'INFORMATION_SCHEMA')
order by schema_id