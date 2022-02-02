function Get-DatabaseHashes {
    param(
        [Parameter(Mandatory, ParameterSetName = "Folder")]
        $Folder,

        [Parameter(Mandatory, ParameterSetName = "Server")]
        $ServerInstance,
        [Parameter(Mandatory, ParameterSetName ="Server")]
        $Database,
        [Parameter(ParameterSetName = "Server")]
        $Username,
        [Parameter(ParameterSetName ="Server")]
        $Password,

        [Parameter(Mandatory, ParameterSetName = "ConnectionString")]
        $ConnectionString
    )
    begin {
        $FileHashList = @{}
    }
    process {
        # If its a server, run the queries and JUST output the hashes
        # If It's a folder, just read the files
        # Just use parameter bindings for server stuff
        if ($Folder){
            # We just want to do this with csv files fo rnow
            foreach ($file in Get-ChildItem $Folder -filter "*.csv"){
                # Let's start by hashing the file entirely
                # Take in the csv file
                $key = [System.IO.Path]::GetFileNameWithoutExtension($file)
                $FileHashList[$key] = @{
                    FileHash = (Get-Hash (Get-Content $file -raw))
                    HashLines = New-Object System.Collections.ArrayList
                }

                foreach ($line in Get-Content $file){
                    $null = $FileHashList[$key]['HashLines'].Add((Get-Hash $line))
                }
            }
        }

        if ($ServerInstance){
            # Server/user/password combo
            If ($Username){
                # Sql Auth
            }
            else {
                # Trusted Auth
            }
        }

        if ($ConnectionString){
            $ConString = Get-sqlConnection -ConnectionString $ConnectionString
            # Need a command to run our command into hashes with us
            # We have the queries we just dont need to write it to files
        }
    }
    end {
        $FileHashList
    }
}