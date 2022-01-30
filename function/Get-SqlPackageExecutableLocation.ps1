function Get-SqlPackageExecutableLocation {
    # This might be slow on crap systems
    param
    (
        $SqlPackageRootLocation = 'C:\Program Files\Microsoft SQL Server'
    )
    $SqlPackageExe = Get-ChildItem $SqlPackageRootLocation -Filter "sqlpackage.exe" -Recurse -ErrorAction SilentlyContinue |
    Sort-Object -Property LastWriteTime -Descending |
    Select-Object -First 1 -ExpandProperty FullName
    if ($null -eq $SqlPackageExe) {
        Read-Host -Prompt "Cannot find your sqlpackage file in your $SqlPackageRootLocation folder, what folder shall I search?"
    }
    return $SqlPackageExe
}
