function Convert-DataTableToCsv {
    param($DataTables, $Filename)
    $counter = $null
    $columns = $null
    foreach ($table in $DataTables){
        # First, get the columns and append it to the file
        # then iterate over all the rows
        if ($table.columns){
            $columns = $table.columns -join ","
            Write-Debug "Found $columns"
        } else {
            throw "Could not find columns in the tables"
        }
        if ($table.Rows.Count -gt 0){
            Write-Debug "Found rows"
            $table | Export-Csv "$filename$counter.csv"
        } else {
            Write-Debug "Writing columns only"
            $columns | Out-File "$filename$counter.csv"
        }

        $counter += 1
    }
}
