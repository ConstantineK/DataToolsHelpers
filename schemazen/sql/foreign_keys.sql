select TABLE_SCHEMA,
       TABLE_NAME,
       CONSTRAINT_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_TYPE = 'FOREIGN KEY'

select CONSTRAINT_NAME,
       OBJECT_SCHEMA_NAME(fk.parent_object_id) as TABLE_SCHEMA,
       UPDATE_RULE,
       DELETE_RULE,
       fk.is_disabled,
       fk.is_system_named
from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
         inner join sys.foreign_keys fk
                    on rc.CONSTRAINT_NAME = fk.name and rc.CONSTRAINT_SCHEMA = OBJECT_SCHEMA_NAME(fk.parent_object_id)

select fk.name                                     as CONSTRAINT_NAME,
       OBJECT_SCHEMA_NAME(fk.parent_object_id)     as TABLE_SCHEMA,
       c1.name                                     as COLUMN_NAME,
       OBJECT_SCHEMA_NAME(fk.referenced_object_id) as REF_TABLE_SCHEMA,
       OBJECT_NAME(fk.referenced_object_id)        as REF_TABLE_NAME,
       c2.name                                     as REF_COLUMN_NAME
from sys.foreign_keys fk
         inner join sys.foreign_key_columns fkc
                    on fkc.constraint_object_id = fk.object_id
         inner join sys.columns c1
                    on fkc.parent_column_id = c1.column_id
                        and fkc.parent_object_id = c1.object_id
         inner join sys.columns c2
                    on fkc.referenced_column_id = c2.column_id
                        and fkc.referenced_object_id = c2.object_id
order by fk.name, fkc.constraint_column_id