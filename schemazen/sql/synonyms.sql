select object_schema_name(object_id) as schema_name,
       name                          as synonym_name,
       base_object_name
from sys.synonyms
order by
    object_schema_name(object_id),
    name,
    base_object_name