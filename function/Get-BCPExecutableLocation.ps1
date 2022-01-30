function Get-BCPExecutableLocation {
    # This might be slow on crap systems
    # idgaf, dont use it
    param
    (
        $BcpRootLocation = 'C:\Program Files\Microsoft SQL Server\'
    )

    $Script:BcpExe = Get-ChildItem $BcpRootLocation -Filter "bcp.exe" -Recurse -ErrorAction SilentlyContinue |
    Sort-Object -Property LastWriteTime -Descending |
    Select-Object -First 1 -ExpandProperty FullName

    if ($null -eq $Script:BcpExe) {
        Read-Host -Prompt "Cannot find your sqlpackage file in your $SqlPackageRootLocation folder, what folder shall I search?"
    }
    return $Script:BcpExe
}
