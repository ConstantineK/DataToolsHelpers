select object_schema_name(t.object_id) as TABLE_SCHEMA,
       object_name(t.object_id)        as TABLE_NAME,
       cc.name                         as COLUMN_NAME,
       cc.definition                   as DEFINITION,
       cc.is_persisted                 as PERSISTED,
       cc.is_nullable                  as NULLABLE,
       cast(0 as bit)                  as IS_TYPE
from sys.computed_columns cc
         inner join sys.tables t on cc.object_id = t.object_id
UNION ALL
select SCHEMA_NAME(tt.schema_id) as TABLE_SCHEMA,
       tt.name                   as TABLE_NAME,
       cc.name                   as COLUMN_NAME,
       cc.definition             as DEFINITION,
       cc.is_persisted           as PERSISTED,
       cc.is_nullable            as NULLABLE,
       cast(1 as bit)            AS IS_TYPE
from sys.computed_columns cc
         inner join sys.table_types tt on cc.object_id = tt.type_table_object_id
