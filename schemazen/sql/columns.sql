select t.TABLE_SCHEMA,
       c.TABLE_NAME,
       c.COLUMN_NAME,
       c.DATA_TYPE,
       c.ORDINAL_POSITION,
       c.IS_NULLABLE,
       c.CHARACTER_MAXIMUM_LENGTH,
       c.NUMERIC_PRECISION,
       c.NUMERIC_SCALE,
       CASE
           WHEN COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsRowGuidCol') = 1
               THEN 'YES'
           ELSE 'NO' END AS IS_ROW_GUID_COL
from INFORMATION_SCHEMA.COLUMNS c
         inner join INFORMATION_SCHEMA.TABLES t
                    on t.TABLE_NAME = c.TABLE_NAME
                        and t.TABLE_SCHEMA = c.TABLE_SCHEMA
                        and t.TABLE_CATALOG = c.TABLE_CATALOG
where t.TABLE_TYPE = 'BASE TABLE'
order by t.TABLE_SCHEMA, c.TABLE_NAME, c.ORDINAL_POSITION