BeforeAll {
    $ModuleRoot = ([System.IO.Path]::GetDirectoryName($PSScriptRoot))
    Write-Host "Import $( Join-Path $ModuleRoot "DataToolsHelpers.psd1" )"
    Import-Module (Join-Path $ModuleRoot "DataToolsHelpers.psd1") -Force

    $ServerInstance = "localhost"
    $Database = "master"
    $PSDefaultParameterValues = @{
        "*:ServerInstance" = $ServerInstance
        "*:Database" = $Database
    }

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
        $SqlConnection = Get-SqlConnection
    }
    It "Should be able to get metadata about the table even if there are no rows." {
        $SqlBatch = "SELECT TOP (0) * FROM SYS.TABLES"
        $dt = Export-DataTable -SqlBatch $SqlBatch -SqlConnection $SqlConnection
        $dt.columns | Should -Not -BeNullOrEmpty
    }

    It "Should be able to throw an exception if the query is borked" {
        {
        $SqlBatch = "HIBBIDITY JIBBITDY"
        $dt = Export-DataTable -SqlBatch $SqlBatch -SqlConnection $SqlConnection
        } | Should -Throw
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
            $Results = Invoke-Query -Script "SELECT * FROM sys.objects"
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
        foreach ($file in $sqlfiles) {
            Test-Path $file | Should -BeTrue
            Get-Content -Raw $file | Should -Not -BeNullOrEmpty -Because "$file was empty"
        }
    }

    It "Should be able to run every configuration query without an error." {
        foreach ($file in $sqlfiles) {
            Write-Debug "Testing $file"
            { Invoke-Query -Script (Get-Content $file -Raw) } |
                    Should -Not -Throw
        }
    }

    It "Should able to handle multi-zero batch queries." {
        # If we have two queries with columns we'd expect two objects in the list (dts)
        # Both with no rows but cols
        # So somehow we get a 0, a 1, and then the acutal data
        $data = Invoke-Query -Script "
        SELECT TOP (0) * FROM sys.tables
GO
SELECT TOP 0 * FROM sys.columns"

        $data.count | Should -BeExactly 2
        $data[0].columns | Should -Not -BeNullOrEmpty
        $data[1].columns | Should -Not -BeNullOrEmpty


    }

    It "Should be able to processes queries MP" {

        {
            $sqlfiles | Foreach-Object  -ThrottleLimit 4 -Parallel {
                # Use the context of the sql file itself
                # This will be brittle and I just dont care
                $ModuleRoot = "C:\Users\ck\Desktop\pycharm\DataToolsHelpers"
                Import-Module (Join-Path $ModuleRoot "DataToolsHelpers.psd1")
                Invoke-Query -ServerInstance $using:ServerInstance -Database $using:Database -Filename $_
            }
        } | Should -Not -Throw
    }

    It "Should be able to write the output of queries to files" {
        # This is going to become a function in my shit

        $OutFolder = "out"
        Remove-Item "out" -Force -Recurse
        New-Item -Type Directory -Path "out" -ErrorAction SilentlyContinue

        # in the cas eof a zero row table we export and it fails
        # we need a custom method potentially
        # or we need to be ok with a blank file
        # if we say a file not existing means we dont have any data
        # it makes the comparison easier
        foreach ($file in $sqlfiles) {
            # we know the name of the sql file and we know they are all in a folder
            # so we assume if we change the extension we win
            # this way also we can bag of name/value stuff
            $data = Invoke-Query -Filename $file
            $filename = [System.IO.Path]::GetFileNameWithoutExtension($file)

            Convert-DataTableToCsv -DataTables $data -Filename (join-path $outfolder $filename)

        }
    }
}
