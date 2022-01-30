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