function Invoke-QueryWithoutResults {
  Param(
    [parameter(ValueFromPipeline, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerInstance,
    [parameter(ValueFromPipeline, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Database,
    [parameter(ValueFromPipeline, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Script,
    [string]$Username,
    [string]$Password,
    [int]$Timeout = 300
  )
  Write-Debug "Invoke-QueryWithoutResults"
  Write-Debug "$ServerInstance $Database $Username $Timeout"

  $Global:message_capture = New-Object System.Collections.ArrayList
  $Global:query_logger = New-Object System.Collections.ArrayList

  $batches = Expand-SqlScript -DocumentString $Script
  $SqlConnection = Get-SqlConnection @PSBoundParameters

  $stopWatch = New-Timer
  $batch_counter = 0

  # Because GO is used as a batch separator, we perform each query in the context of the same connection
  foreach($batch in $batches)
  {
      if ($batch.Trim() -ne ""){
        $batch_counter += 1
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand

        $null = $Global:query_logger.Add($batch)

        $SqlCmd.CommandText = $batch
        $SqlCmd.Connection = $SqlConnection

        $stopWatch.Start()
        $null = $SqlCmd.ExecuteNonQuery()

        Write-Debug "Last batch: $($stopWatch.TimeElapsed())"
        Write-Debug "Total Batches $batch_counter"

        $len = 50
        if ($batch.length -lt 50){
          $len = $batch.length
        }
        Write-Information $batch.Substring(0,$len)

      }
  }
  $SqlConnection.Close()
  return , $Global:message_capture # I want the list
}