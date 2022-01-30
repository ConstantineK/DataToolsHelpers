SELECT
					OBJECT_NAME(o.OBJECT_ID) AS CONSTRAINT_NAME,
					SCHEMA_NAME(t.schema_id) AS TABLE_SCHEMA,
					OBJECT_NAME(o.parent_object_id) AS TABLE_NAME,
					CAST(0 AS bit) AS IS_TYPE,
					objectproperty(o.object_id, 'CnstIsNotRepl') AS NotForReplication,
					'CHECK' AS ConstraintType,
					cc.definition as CHECK_CLAUSE,
					cc.is_system_named
				FROM sys.objects o
					inner join sys.check_constraints cc on cc.object_id = o.object_id
					inner join sys.tables t on t.object_id = o.parent_object_id
					WHERE o.type_desc = 'CHECK_CONSTRAINT'
				UNION ALL
				SELECT
					OBJECT_NAME(o.OBJECT_ID) AS CONSTRAINT_NAME,
					SCHEMA_NAME(tt.schema_id) AS TABLE_SCHEMA,
					tt.name AS TABLE_NAME,
					CAST(1 AS bit) AS IS_TYPE,
					objectproperty(o.object_id, 'CnstIsNotRepl') AS NotForReplication,
					'CHECK' AS ConstraintType,
					cc.definition as CHECK_CLAUSE,
					cc.is_system_named
				FROM sys.objects o
					inner join sys.check_constraints cc on cc.object_id = o.object_id
					inner join sys.table_types tt on tt.type_table_object_id = o.parent_object_id
					WHERE o.type_desc = 'CHECK_CONSTRAINT'
				ORDER BY TABLE_SCHEMA, TABLE_NAME, CONSTRAINT_NAME