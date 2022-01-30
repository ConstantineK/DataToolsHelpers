select s.name            as TABLE_SCHEMA,
       t.name            as TABLE_NAME,
       c.name            as COLUMN_NAME,
       d.name            as DEFAULT_NAME,
       d.definition      as DEFAULT_VALUE,
       d.is_system_named as IS_SYSTEM_NAMED,
       cast(0 AS bit)    AS IS_TYPE
from sys.tables t
         inner join sys.columns c on c.object_id = t.object_id
         inner join sys.default_constraints d on c.column_id = d.parent_column_id
    and d.parent_object_id = c.object_id
         inner join sys.schemas s on s.schema_id = t.schema_id
UNION ALL
select s.name            as TABLE_SCHEMA,
       tt.name           as TABLE_NAME,
       c.name            as COLUMN_NAME,
       d.name            as DEFAULT_NAME,
       d.definition      as DEFAULT_VALUE,
       d.is_system_named as IS_SYSTEM_NAMED,
       cast(1 AS bit)    AS IS_TYPE
from sys.table_types tt
         inner join sys.columns c on c.object_id = tt.type_table_object_id
         inner join sys.default_constraints d on c.column_id = d.parent_column_id
    and d.parent_object_id = c.object_id
         inner join sys.schemas s on s.schema_id = tt.schema_id