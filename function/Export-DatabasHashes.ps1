function Export-DatabaseHashes {
    param(
        [Parameter(Mandatory, ParameterSetName = "Folder")]
        $Folder,

        [Parameter(Mandatory, ParameterSetName = "Server")]
        $ServerInstance,
        [Parameter(Mandatory, ParameterSetName ="Server")]
        $Database,
        [Parameter(ParameterSetName = "Server")]
        $Username,
        [Parameter(ParameterSetName ="Server")]
        $Password,

        [Parameter(Mandatory, ParameterSetName = "ConnectionString")]
        $ConnectionString,

        $Path
    )

    $HashSettings = $PSBoundParameters.Remove($Path)
    Get-DatabaseHashes @HashSettings |
        ConvertTo-Json -Depth 5 |
        Set-Content $Path -Encoding "utf8"
}
