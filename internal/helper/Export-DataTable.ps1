function Export-DataTable {
    param ($SqlBatch, $SqlConnection)

    $SqlCmd = $SqlConnection.CreateCommand()
    $SqlCmd.CommandText = $Sqlbatch

    $ds = New-Object System.Data.DataSet
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
    #$adapter | gm | out-default
    $null = $adapter.Fill($ds)


    # So its going to each row to figure it out, which is not what I want
    return , $ds.Tables
}