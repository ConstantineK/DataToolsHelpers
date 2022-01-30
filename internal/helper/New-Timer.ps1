Set-StrictMode -Version 2

function New-Timer {
    # Make timers a little easier to manage in powershell
    Write-Debug "New-Timer"
    $stopWatch = new-object System.Diagnostics.Stopwatch;
    $stopWatch |
        Add-Member TimeElapsed -MemberType ScriptMethod {
            $this.Stop()
            $val = $this.Elapsed
            $this.Reset()
            return $val
        }
    return $stopWatch
}