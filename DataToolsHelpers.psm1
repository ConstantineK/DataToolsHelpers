
function Start-InternalProcess {
    # https://stackoverflow.com/a/14061481/695726
    # Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
    # Changed variable names, made it a function
    param
    (
        $FilePath,
        $ArgumentList
    )
    $psi = New-object System.Diagnostics.ProcessStartInfo
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.FileName = $FilePath
    $psi.Arguments = $ArgumentList
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    [void]$process.Start()
    $output = $process.StandardOutput.ReadToEnd()
    $process.WaitForExit()
    $output
}
function Get-BCPExecutableLocation {
    # This might be slow on crap systems
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

function Build-FormatFile {
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

function Sync-DataFile
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

# These two will need Invoke-SqlCmd, which comes with these tools anyway and is also xplat
# With that I can get a pretty close create statement, create the table, and go

function Get-CreateStatement {}
function Sync-Table {}

# Alternately I can export/import the dacpacs with sqlpackage, I will do both
function Build-DatabaseSchema {}
function Sync-DatabaseSchema {}

Export-ModuleMember -Function Build-FormatFile, Build-DataFile, Sync-DataFile
