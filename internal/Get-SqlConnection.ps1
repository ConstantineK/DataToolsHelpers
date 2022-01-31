function Get-SqlConnection {
  <#
    Currently support windows and sql authentication
    If you use username/password it will switch to sql mode
  #>
  param(
    [parameter(ValueFromPipeline, Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$ServerInstance,
      [parameter(ValueFromPipeline, Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Database,
      [string]$Username,
      [string]$Password,
      [int]$Timeout = 300
    )
  begin {
    Write-Debug "Get-SqlConnection"
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
  }
  process {
    if($Password){
      $SqlConnection.ConnectionString = "Server=$ServerInstance;Database=$Database;User Id=$Username;Password=$Password;Trusted_Connection=False;Connection Timeout=$Timeout;"
    }
    else {
      $SqlConnection.ConnectionString = "Server=$ServerInstance;Database=$Database;Trusted_Connection=True;Connection Timeout=$Timeout;"
    }
    $handler = Get-SqlErrorHandler
    $SqlConnection.add_InfoMessage($handler)
    $SqlConnection.FireInfoMessageEventOnUserErrors = $true
    $SqlConnection.Open()
  }
  end {
    return $SqlConnection
  }
}
