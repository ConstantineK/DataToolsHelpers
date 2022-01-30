function Build-DataFile {
    # Output batch data reports every 1k row regardless...
    # Might want to supress that.
    param
    (
        [Parameter(Mandatory = $true)] $FileLocation,
        [Parameter(Mandatory = $true)] $FormatFileLocation,
        [Parameter(Mandatory = $true)] $ObjectName,
        [Parameter(Mandatory = $true)] $ServerName,
        [Parameter(Mandatory = $true)] $DatabaseName,
        $AuthType = 'Trusted',
        $Username,
        $Password,
        $BatchSize = 100000,
        $Quiet = $True
    )
    Write-Debug "Creating $FileLocation."
    $bcplocation = Get-BCPExecutableLocation

    $Arguments = @(
        "`"$ObjectName`" out `"$FileLocation`"",
        "-f `"$FormatFileLocation`"",
        "-d $DatabaseName",
        "-S $ServerName",
        "-b `"$BatchSize`"" # I cant tell if this does anything
    )
    if ($AuthType -eq 'Trusted') {
        $Arguments += ('-T')
    }
    elseif ($AuthType -eq 'sql') {
        $Arguments += ("-U $Username -P $password ")
    }
    elseif ($AuthType -eq 'Azure') {
        $Arguments += ('-G')
    }

    $Output = Start-InternalProcess -FilePath $bcplocation -ArgumentList $arguments
    if ($Quiet -eq $false){
        $output
    }
}
