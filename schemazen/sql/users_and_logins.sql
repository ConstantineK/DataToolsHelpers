select dp.name as UserName, USER_NAME(drm.role_principal_id) as AssociatedDBRole, default_schema_name
				from sys.database_principals dp
				left outer join sys.database_role_members drm on dp.principal_id = drm.member_principal_id
				where (dp.type_desc = 'SQL_USER' or dp.type_desc = 'WINDOWS_USER')
				and dp.sid not in (0x00, 0x01) and dp.name not in ('dbo', 'guest')
				and dp.is_fixed_role = 0
				order by dp.name

select sp.name,  sl.password_hash
					from sys.server_principals sp
					inner join sys.sql_logins sl on sp.principal_id = sl.principal_id and sp.type_desc = 'SQL_LOGIN'
					where sp.name not like '##%##'
					and sp.name != 'SA'
					order by sp.name