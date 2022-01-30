select a.name as AssemblyName, a.permission_set_desc, af.name as FileName, af.content
from sys.assemblies a
         inner join sys.assembly_files af on a.assembly_id = af.assembly_id
where a.is_user_defined = 1
order by a.name, af.file_id