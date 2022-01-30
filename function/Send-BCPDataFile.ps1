function Send-BCPDataFile
{
    param(
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
    Write-Debug "Uploading $FileLocation - $((Get-ChildItem $FileLocation).Length / (1024 * 1024))MB to $ServerName."
    $bcplocation = Get-BCPExecutableLocation

    if ($FormatFileLocation -notlike '*fmt'){
        Write-Warning "Specifying a format file without a .fmt extension can be confusing. You might have done this in error."
    }

    if ($FileLocation -notlike '*dat'){
        Write-Warning "Specifying a file without a .dat extension can be confusing. You might have done this in error."
    }

    $Arguments = @(
        "`"$objectname`" in `"$filelocation`"",
        "-f `"$FormatFileLocation`"",
        "-d `"$DatabaseName`"",
        "-S `"$ServerName`"",
        "-b `"$BatchSize`""
    )
    if ($AuthType -eq 'Trusted') {
        $Arguments += ('-T')
    }
    elseif ($AuthType -eq 'Azure') {
        $Arguments += ('-G')
    }
    elseif ($AuthType -eq 'Sql') {
        if ($null -eq $Username -or $null -eq $Password) {
            Write-Error "Missing username or password."
        }
        $Arguments += @(
            "-U $Username",
            "-P $Password"
        )
    }

    $Output = Start-InternalProcess -FilePath $bcplocation -ArgumentList $arguments
    if ($Quiet -eq $false){
        $output
    }
}
