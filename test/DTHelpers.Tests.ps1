BeforeAll {
    $ModuleRoot = ([System.IO.Path]::GetDirectoryName($PSScriptRoot))
    Write-Host "Import $( Join-Path $ModuleRoot "DataToolsHelpers.psd1" )"
    Remove-Module DataToolsHelpers -ErrorAction SilentlyContinue
    Import-Module (Join-Path $ModuleRoot "DataToolsHelpers.psd1")

    $ServerInstance = "localhost"
    $Database = "master"

}

Describe "The Module Setup" {
    It "Should be available in the current context" {
        $Objects = Get-Command -module "DataToolsHelpers"
        ($Objects).Count | Should -BeGreaterOrEqual 1
    }

    It "Should be able to Use the Query Command." {
        Get-Command -module "DataToolsHelpers" |
                Where-Object { $_.Name -eq "Invoke-Query" } |
                Should -Not -BeNullOrEmpty
    }
}

Describe "Export-DataSet" {
    BeforeAll {
        $SqlConnection = Get-SqlConnection -ServerInstance $ServerInstance -Database $Database
        $SqlBatch = "SELECT TOP (0) * FROM SYS.TABLES"
        $dt = Export-DataTable -SqlBatch $SqlBatch -SqlConnection $SqlConnection
    }
    It "Should be able to get metadata about the table even if there are no rows." {
        $dt.columns | Should -Not -BeNullOrEmpty
    }
}


Describe "Invoke-Query" {
    BeforeAll {
        $sqlfiles = Get-ChildItem (Join-Path $ModuleRoot "schemazen" "sql") -Filter "*.sql" |
                Select-Object -ExpandProperty FullName
    }
    It "Should be able to run a simple query and return data." {
        $results = $null
        $err = $null
        try {
            $Results = Invoke-Query -ServerInstance $ServerInstance -Database $Database -Script "SELECT * FROM sys.objects"
        }
        catch {
            $err = $_
            throw
        }

        $err | Should -BeNull
        $Results | Should -Not -BeNullOrEmpty
        # normal master is like 110
        # In general if we have only one data table it will unwrap it
        # In multi-query cases we'd expect a list of dt
        $Results.rows.Count | Should -BeGreaterOrEqual 100
    }

    It "Should witness all of our configuration queries." {
        foreach($file in $sqlfiles){
            Test-Path $file | Should -BeTrue
            Get-Content -Raw $file | Should -Not -BeNullOrEmpty -Because "$file was empty"
        }
    }

    It "Should be able to run every configuration query without an error." {
        foreach ($file in $sqlfiles) {
            Write-Debug "Testing $file"
            { Invoke-Query -ServerInstance $ServerInstance -Database $Database -Script (Get-Content $file -Raw) } |
                Should -Not -Throw
        }
    }

    It "Should able to handle multi-zero batch queries." {
        # If we have two queries with columns we'd expect two objects in the list (dts)
        # Both with no rows but cols
        # So somehow we get a 0, a 1, and then the acutal data
        $data = Invoke-Query -ServerInstance $ServerInstance -Database $Database -Script "
        SELECT TOP (0) * FROM sys.tables
GO
SELECT TOP 0 * FROM sys.columns"

        $data.count | Should -BeExactly 2
        $data[0].columns | Should -Not -BeNullOrEmpty
        $data[1].columns | Should -Not -BeNullOrEmpty


        # we should have nothing else

#        $data['result'][0] | Should -BeOfType System.Data.DataTable
#        $data['result'][1] | Should -BeOfType System.Data.DataTable
#
#        $data['result'][0].rows.count | Should -BeExactly 0
#        $data['result'][1].rows.count | Should -BeExactly 0
#
#        $data['result'][0].columns.count | Should -Not -BeExactly 0
#        $data['result'][1].columns.count | Should -Not -BeExactly 0
    }


}