function Compare-DatabaseHashes {
    param($HashSetOne, $HashSetTwo, $CheckContents = $True)
    foreach ($section in $HashSetOne.Keys){
        if ($HashSetOne[$section].FileHash -ne $HashSetTwo[$section].FileHash){
            Write-Debug "File doesn't match for $section."
            if ($CheckContents -eq $True){
                Compare-Object -ReferenceObject $HashSetOne[$section].HashLines -DifferenceObject $HashSetTwo[$section].HashLines
            }
        }
    }
}