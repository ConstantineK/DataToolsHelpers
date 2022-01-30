select
							u.name as user_name,
							object_schema_name(o.id) as object_owner,
							o.name as object_name,
							p.permission_name as permission
					from sys.database_permissions p
					join sys.sysusers u on p.grantee_principal_id = u.uid
					join sys.sysobjects o on p.major_id = o.id