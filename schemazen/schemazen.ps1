# We need the ability to run queires in parallel
# We need the ability to easily and safely persist data
# We need the ability to read from memory or that data to efficiently export state
# let's just start with the queries I have and just running them
# Invoke-SqlCmd2 seems good but atuin might have a better option
# I could also depend on a pwsh module lol no
# For TSQL we also have the problem of non-queries, batch stuff, GO

# a simple and easy way to export data
# we assume all queries will export data
# So what's it like to call this function in parallel?

$ModuleRoot = ([System.IO.Path]::GetDirectoryName($PSScriptRoot))
Write-Host $PSScriptRoot
Write-Host $ModuleRoot
#Import-Module (Join-Path $ModuleRoot "DataToolsHelpers.psd1")

# Let's do a naive approach and test it
#foreach($script in join-path ( $PsModuleRoot "schemazen" "sql")){
#
#}
#Invoke-Query -ServerInstance -Database -Script



# Runs the various queries in the sql folder to export the state needed
# We can either return hash table named results (probably simplest) or just write files directly
# We need to maximize the amount of queries and files running at the same time
#Export-SqlState

# Once we've exported the state, we need to effectively model (like SZ did) the exported objects
# If we can set them up as references from existing sets we can just assemble them from various query sets
# Even with a lot of objects this shouldnt slow down too much if we order things

