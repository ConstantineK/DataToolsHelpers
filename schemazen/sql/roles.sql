select
	name
from sys.database_principals
where type = 'R'
	and name not in (
	-- Ignore default roles, just look for custom ones
		'db_accessadmin'
	,	'db_backupoperator'
	,	'db_datareader'
	,	'db_datawriter'
	,	'db_ddladmin'
	,	'db_denydatareader'
	,	'db_denydatawriter'
	,	'db_owner'
	,	'db_securityadmin'
	,	'public'
	)