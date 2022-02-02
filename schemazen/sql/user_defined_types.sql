 select
    s.name as 'Type_Schema',
    t.name as 'Type_Name',
    tt.name as 'Base_Type_Name',
    t.max_length as 'Max_Length',
    t.is_nullable as 'Nullable'
from sys.types t
inner join sys.schemas s on s.schema_id = t.schema_id
inner join sys.types tt on t.system_type_id = tt.user_type_id
where
    t.is_user_defined = 1
    and t.is_table_type = 0
order by
    s.name,
    t.name,
    tt.name,
    t.max_length,
    t.is_nullable
