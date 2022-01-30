Set-StrictMode -Version 2

function Get-SqlErrorHandler {
  <#
    So why does this exist?
    I couldnt find a way to capture the output of info message events without restoring to a global context, so I just say screw it
    I should consider switching this to module instead of global, but for sometime later

  #>

  return [System.Data.SqlClient.SqlInfoMessageEventHandler] {
    param($sender, [System.Data.SqlClient.SqlInfoMessageEventArgs]$event)
    # since each print statement raises an error, we need to know if this statement was related to a new statement or not
    # and then return the list under the statement that would be related
    # check each statement against the list of approved errors and filter those out

    function Add-Message {
      param($sender, $event)
      $Global:message_capture.Add(
        @{
          Database = $Sender.database
          ConnectionString = $Sender.ConnectionString
          Query = $Global:query_logger | Select-Object -Last 1
          LineNumber = $event.Errors.LineNumber
          Message = $event.Errors.Message
          Number = $event.Errors.Number
          Source = $event.Errors.Source
          Object = $event
        }
      )
    }

    $badlist = @(
      "Changed database context to*",
      "SQLServerAgent is not currently running*"
    )
    [bool]$clean = $true

    foreach ($bad in $badlist){
      foreach ($msg in $event){
        foreach ($error in $msg.Errors.Message){
          if ($error -like $bad){
           $clean = $false
          }
          else {
            Continue
          }
        }
      }
    }
    # lookup and see if that value exists
    if ($clean -eq $true){
      if (-not $Global:message_capture){
        # if not add it
        Add-Message -Sender $sender -Event $event
      }
      else {
        # if it does exist, we would have need to have run at least two queries
        # one created a message (and ran through this) and then one additional
        $querytext = $Global:query_logger[ $Global:query_logger.Count -1 ]
        $previousquery = $Global:query_logger[$Global:query_logger.Count -2]
        # if the last query is the same as the one before it
        if ($previousquery -and $querytext -eq $previousquery){
          # look up and see if we have any logged messages
          $existing = $Global:message_capture | Where-Object { $_.Query -eq $querytext }

          # if we do, log our additional information on top of the existing message
          if ($existing){
            $Global:message_capture |
              Select-Object -Last 1 |
              ForEach-Object {
                $_.Message = $_.Message + [System.Environment]::NewLine + "`t" + $event.Errors.Message
              }
          }
        } else {
          Add-Message -Sender $sender -Event $event
        }
      }
    }
  }
}