select
    s.name as schemaName,
    o.name as routineName,
    o.type_desc,
    m.definition,
    m.uses_ansi_nulls,
    m.uses_quoted_identifier,
    isnull(s2.name, s3.name) as tableSchema,
    isnull(t.name, v.name) as tableName,
    tr.is_disabled as trigger_disabled
from sys.sql_modules m
join sys.objects o on
        m.object_id = o.object_id
join sys.schemas s on
        s.schema_id = o.schema_id
left join sys.triggers tr on
        m.object_id = tr.object_id
left join sys.tables t on
        tr.parent_id = t.object_id
left join sys.views v on
        tr.parent_id = v.object_id
left join sys.schemas s2 on
        s2.schema_id = t.schema_id
left join sys.schemas s3 on
        s3.schema_id = v.schema_id
where
    objectproperty(o.object_id, 'IsMSShipped') = 0
order by
    s.name,
    o.name