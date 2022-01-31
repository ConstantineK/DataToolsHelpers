function Export-DataTable {
    param ($SqlBatch, $SqlConnection)



    $SqlCmd = $SqlConnection.CreateCommand()
    $SqlCmd.CommandText = $Sqlbatch

    $ds = New-Object System.Data.DataSet
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)

    #$adapter | gm | Out-Default

    $null = Register-ObjectEvent -InputObject $adapter -EventName "FillError" -Action {
        write-host "Got a fill error"
        Write-Output "Fill Error"
        write-error "Had a fill error"
    }
    $null = $adapter.Fill($ds)

    # So its going to each row to figure it out, which is not what I want
    return , $ds.Tables
}