function Invoke-Query {
    <#
# Why script instead of query? Because we actually go out of our way to support
# Arbitrary TSQL scripts, with GO commands and all that jazz
#>
    Param(
        [parameter(ValueFromPipeline, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerInstance,
        [parameter(ValueFromPipeline, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Database,
        [string]$Script,
        [string]$Filename,
        [string]$Username,
        [string]$Password,
        [int]$Timeout = 300
    )
    if (-not $Script -and -not $Filename) {
        Write-Error "You must provide either a script or a filename to run".
    }

    Write-Debug "Invoke-Query"
    Write-Debug "$ServerInstance $Database $Username $Timeout"

    if (-not $Script -and $filename) {
        $script = Get-Content $filename -Raw
    }

    $batches = Expand-SqlScript -DocumentString $Script
    $ConnectParams = @{
        ServerInstance = $ServerInstance
        Database = $Database
        Timeout = $Timeout
    }

    if ($Password) {
        $ConnectParams['Username'] = $Username
        $ConnectParams['Password'] = $Password
    }

    $SqlConnection = Get-SqlConnection @ConnectParams

    $stopWatch = New-Timer
    $batch_counter = 0
    $DataTables = @()
    # Because GO is used as a batch separator, we perform each query in the context of the same connection
    foreach ($batch in $batches) {
        if ($batch.Trim() -ne "") {
            $batch_counter += 1
            $stopWatch.Start()
            $DataTables+= @(Export-DataTable -Sqlbatch $Batch -SqlConnection $SqlConnection)

            Write-Debug "Last batch: $($stopWatch.TimeElapsed() )"
            Write-Debug "Total Batches $batch_counter"

            $len = 50
            if ($batch.length -lt 50) {
                $len = $batch.length
            }
            Write-Information $batch.Substring(0, $len)
        }
    }
    $null = $SqlConnection.Close()

    return , $DataTables
}