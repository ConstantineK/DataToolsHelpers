function Export-BCPFormatFile {
    param(
        [Parameter(Mandatory = $true)] $FormatFileLocation,
        [Parameter(Mandatory = $true)] $ObjectName,
        [Parameter(Mandatory = $true)] $ServerName,
        [Parameter(Mandatory = $true)] $DatabaseName,
        $AuthType = 'Trusted',
        $Username,
        $Password,
        $Quiet = $True
    )
    Write-Debug "Writing Format File to $FormatFileLocation"
    $bcplocation = Get-BCPExecutableLocation

    if ($FormatFileLocation -notlike "*fmt"){
        Write-Warning "Specifying a format file without a .fmt extension can be confusing. You might have done this in error."
    }

    $Arguments = @(
        "$ObjectName",
        "format nul -f `"$FormatFileLocation`" -N -x",
        "-d $DatabaseName",
        "-S $ServerName"
    )
    if ($AuthType -eq 'Trusted') {
        $Arguments += ('-T')
    }
    elseif ($AuthType -eq 'sql') {
        $Arguments += ("-U $Username -P $Password ")
    }
    elseif ($AuthType -eq 'Azure') {
        $Arguments += ('-G')
    }
    # Bcp can throw a bunch of errors around connections and the like, add more useful management of these.

    $Output = Start-InternalProcess -FilePath $bcplocation -ArgumentList $arguments
    if ($Quiet -eq $false){
        $output
    }
}
