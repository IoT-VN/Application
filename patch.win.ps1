function patchHosts() {
    $hostPath = "$env:windir\System32\drivers\etc\hosts"
    sp $hostPath IsReadOnly $false
    $c = Get-Content $hostPath
    $newLines = @()
    foreach ($line in $c) {
        $bits = [regex]::Split($line, "\s+")
        if ($bits.count -eq 2) {
            if ($bits[1] -NotLike "*multilogin*") {
                $newLines += $line
            }
        } else {
            $newLines += $line
        }
    }
    $newLines += "165.154.225.151`tmultiloginapp.com"
    $newLines += "165.154.225.151`tapp.multiloginapp.com"
    $newLines += "165.154.225.151`tapp-hk.multiloginapp.com"
    $newLines += "165.154.225.151`tapp-fr.multiloginapp.com"
    $newLines += "165.154.225.151`tapp-nl.multiloginapp.com"
    $newLines += "165.154.225.151`tapp-de.multiloginapp.com"
    $newLines += "165.154.225.151`ts3-spaces-app.multiloginapp.com"        
    $newLines += "::ffff:a59a:e197`tmultiloginapp.com"
    $newLines += "::ffff:a59a:e197`tapp.multiloginapp.com"
    $newLines += "::ffff:a59a:e197`tapp-hk.multiloginapp.com"
    $newLines += "::ffff:a59a:e197`tapp-fr.multiloginapp.com"
    $newLines += "::ffff:a59a:e197`tapp-nl.multiloginapp.com"
    $newLines += "::ffff:a59a:e197`tapp-de.multiloginapp.com"
    # Write file
    Clear-Content $hostPath
    foreach ($line in $newLines) {
        $line | Out-File -encoding ASCII -append $hostPath
    }
}

function patchCerts() {
  $check = dir cert: -Recurse | Where-Object { $_.Subject -like "*multilogin.com*" }
  if ($check.count -eq 0) {
    $certBytes = [Convert]::FromBase64String("MIID9TCCAt2gAwIBAgIUR2dN+in8JdS0hKYrFtMjYw5baVEwDQYJKoZIhvcNAQELBQAwgYkxCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJDQTETMBEGA1UEBwwKV2FzaGluZ3RvbjEMMAoGA1UECgwDQ1RPMQ0wCwYDVQQLDARyb290MRcwFQYDVQQDDA5tdWx0aWxvZ2luLmNvbTEiMCAGCSqGSIb3DQEJARYTaW5mb0BtdWx0aWxvZ2luLmNvbTAeFw0yMTA0MTUyMTU2MTRaFw00MTA0MTAyMTU2MTRaMIGJMQswCQYDVQQGEwJVUzELMAkGA1UECAwCQ0ExEzARBgNVBAcMCldhc2hpbmd0b24xDDAKBgNVBAoMA0NUTzENMAsGA1UECwwEcm9vdDEXMBUGA1UEAwwObXVsdGlsb2dpbi5jb20xIjAgBgkqhkiG9w0BCQEWE2luZm9AbXVsdGlsb2dpbi5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC+pVNjQBqhtUTfvoKucf0irH3WGRprMD1vDffQ8IGT+giLbXCfn9KStZsWKgJ0C8DPKRgp0Pd+45B6HiLhVmBLWyudSJ2wbEt85QplbmvjvGI1o3QUjOZayHX6ncnaknguhgpTro10AvtuBxjsLlQ7/4/BmjbCYF0MDJnEJZ/IoOLcO0PtElmRI38mtOJHykyjUgXuqWdERM4d6+XHRh3opowV1RUZcPV3jEOJnYjwA+Qypm+IRopGDJJfh2aWFwOHCxHKIpU92Lutcjb0UXKVPhKfqaQpvP7fH/T3yI6H6UZ3xaiKgUExvEVjjqSqT1u7UEbhCnfWAYtA4+eHuoR9AgMBAAGjUzBRMB0GA1UdDgQWBBRdFM3Eo6pDCEjkCFtm/CpEsQau/jAfBgNVHSMEGDAWgBRdFM3Eo6pDCEjkCFtm/CpEsQau/jAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQC8D0ufY9/eYdyIccfrPa05e2dDTzorlZamKlvtRnYn/md7mWV/4Rw1STRgEp8BEXv/6wwh03ykuDscK5k3M2M7rUeRq59dxbnKAKO3hQXuKwJOcO9aZ5Dkm/pjOKvt56fH/OrUXs9+N99pb2pTsVXns0FaIp+ncYcQN61rcfmx+lh83VPOUXP7ynTQWSPJ5P4K7gLjbpqBj1HQnI9CJ/bBfXMbB2uqXQHK9QqDmzrGbr3+CO+PBF1dLdT1HiRa1BbfUspdqFRyKMUxPaxsMkps4eWt4xQB3JeUlKaCj3GOa6JlXL9StXHD4D6MlZ2Td/ihH4/BMlTCQ6w7zjPVOzDg")
    $cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import($certBytes);
    $store = new-object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]"ReadWrite")
    $store.Add($cert);
    $store.Close()
  }
}
$ProgressPreference = 'SilentlyContinue'
function patchMulti() {
  $mlPath = Read-Host -Prompt 'Input Your Multilogin Path [C:\Program Files (x86)\Multilogin]'
    $p = $mlPath + "\rt\lib\security\cacerts"
    iwr -Uri "https://files.x7c.club/cacerts.win" -OutFile $p
}
function patchNow() {
  Write-Host "Hello, I'm x2e and I patching multilogin"
  patchHosts
  patchCerts
  patchMulti
  Write-Host "Done !"
}
patchNow
