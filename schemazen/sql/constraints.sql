select s.name                           as schemaName,
       t.name                           as tableName,
       t.baseType,
       i.name                           as indexName,
       c.name                           as columnName,
       i.is_primary_key,
       i.is_unique_constraint,
       i.is_unique,
       i.type_desc,
       i.filter_definition,
       isnull(ic.is_included_column, 0) as is_included_column,
       ic.is_descending_key,
       i.type
from (
         select object_id, name, schema_id, 'T' as baseType
         from sys.tables
         union
         select object_id, name, schema_id, 'V' as baseType
         from sys.views
         union
         select type_table_object_id, name, schema_id, 'TVT' as baseType
         from sys.table_types
     ) t
         inner join sys.indexes i on i.object_id = t.object_id
         inner join sys.index_columns ic on ic.object_id = t.object_id
    and ic.index_id = i.index_id
         inner join sys.columns c on c.object_id = t.object_id
    and c.column_id = ic.column_id
         inner join sys.schemas s on s.schema_id = t.schema_id
where i.type_desc != 'HEAP'
order by s.name, t.name, i.name, ic.key_ordinal, ic.index_column_id