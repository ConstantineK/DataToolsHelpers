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
    [parameter(ValueFromPipeline, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Script,
    [string]$Username,
    [string]$Password,
    [int]$Timeout = 300
  )
  Write-Debug "Invoke-Query"
  Write-Debug "$ServerInstance $Database $Username $Timeout"


  $batches = Expand-SqlScript -DocumentString $Script
  $SqlConnection = Get-SqlConnection @PSBoundParameters

  $stopWatch = New-Timer
  $batch_counter = 0
  $DataTables = [System.Collections.ArrayList]@()
  # Because GO is used as a batch separator, we perform each query in the context of the same connection
  foreach ($batch in $batches) {
    if ($batch.Trim() -ne "") {
      $batch_counter += 1
      $stopWatch.Start()
      $obj = Export-DataTable -Sqlbatch $Batch -SqlConnection $SqlCOnnection

      $null = $DataTables.Add($obj)

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

  return , $DataTables.ToArray()
}