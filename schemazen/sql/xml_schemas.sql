select s.name                               as DBSchemaName,
       x.name                               as XMLSchemaCollectionName,
       xml_schema_namespace(s.name, x.name) as definition
from sys.xml_schema_collections x
         join sys.schemas s on s.schema_id = x.schema_id
where s.name != 'sys'
order by s.name, x.name