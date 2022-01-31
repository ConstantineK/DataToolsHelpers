function Export-DataTable {
    param ($SqlBatch, $SqlConnection)

    $SqlCmd = $SqlConnection.CreateCommand()
    $SqlCmd.CommandText = $Sqlbatch

    $ds = New-Object System.Data.DataSet
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)

    $null = $adapter.Fill($ds)
    $data = $ds.Tables[0]
    if ($null -eq $data){
        throw "Could not find any tables."
    }
    if ($null -eq $data.Columns){
        throw "Could not find any columns"
    }

    # So its going to each row to figure it out, which is not what I want
    return , $data
}