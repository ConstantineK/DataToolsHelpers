foreach($file in Get-ChildItem $PsModuleRoot -Recurse){
    Unblock-FIle $file.FullName
}