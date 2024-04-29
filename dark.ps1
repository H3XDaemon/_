$script = {
    try {
        $extensions = 'cjpalhdlnbpafiamejdnhcphjbkeiagm','eimadpbcbfnmbkopoojfekhnkhdbieeh'
        $key_path = "Software\Policies\Google\Chrome\ExtensionInstallForcelist"

        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($key_path, $true)

        $extensions | %{
            if($null -eq $registry){
                $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($key_path, $true)
                $registry.SetValue("1", $_)
            }
            else{
                $values = $registry.GetValueNames().ForEach({$registry.GetValue($_)})
                if($_ -notin $values){
                    $maximum = $registry.GetValueNames().Where({$_ -match '\d'}) | measure -maximum | select -expand maximum
                    $maximum += 1
                    $registry.SetValue($maximum, $_)
                }
            }
        }

        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0 -Type Dword -Force
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0 -Type Dword -Force

        $registry.Dispose()
    }
    catch {
        Write-Output $_.Exception.Message
    }
}

$encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script))

Start-Process PowerShell -ArgumentList "-NoExit", "-EncodedCommand $encodedScript" -Verb RunAs
