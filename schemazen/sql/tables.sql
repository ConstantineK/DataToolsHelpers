select
    TABLE_SCHEMA,
    TABLE_NAME
from INFORMATION_SCHEMA.TABLES
where
    TABLE_TYPE = 'BASE TABLE'
order by
    TABLE_SCHEMA,
    TABLE_NAME

select
    s.name as TABLE_SCHEMA,
    tt.name as TABLE_TYPE_NAME
from sys.table_types tt
join sys.schemas s on
    tt.schema_id = s.schema_id
where
    tt.is_user_defined = 1
order by
    s.name,
    tt.name