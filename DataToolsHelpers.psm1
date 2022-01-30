# Lazy mode for the rest of the module
$PSModuleRoot = $PSScriptRoot


# Cant easily dot source in a function, yay
foreach ($function in Get-ChildItem (Join-Path $PSModuleRoot "function") -filter "*.ps1" -Recurse){
    Write-Information "Adding $($function.FullName) to the module."
    . $function.FullName
}

# Cant easily dot source in a function, yay
foreach ($function in Get-ChildItem (Join-Path $PSModuleRoot "internal") -filter "*.ps1" -Recurse){
    Write-Information "Adding $($function.FullName) to the module."
    . $function.FullName
}