function Get-Hash
{
    param($String)

    $SHA256 = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
    # Supririse, its exactly the same we did it right!
    $Hash = $SHA256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))
    $HashString = [System.BitConverter]::ToString($Hash)

    return $HashString.Replace('-', '')
}