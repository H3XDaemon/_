$script = {
    function Set-RegistryValue {
        param (
            [string]$Path,
            [string]$Name,
            [int]$Value
        )
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type Dword -Force
    }

    function Set-ChromeExtension {
        param (
            [string]$ExtensionID
        )
        $key_path = "Software\Policies\Google\Chrome\ExtensionInstallForcelist"
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($key_path, $true)
        if($null -eq $registry){
            $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($key_path, $true)
            $registry.SetValue("1", $ExtensionID)
        }
        else{
            $values = $registry.GetValueNames().ForEach({$registry.GetValue($_)})
            if($ExtensionID -notin $values){
                $maximum = $registry.GetValueNames().Where({$_ -match '\d'}) | measure -maximum | select -expand maximum
                $maximum += 1
                $registry.SetValue($maximum, $ExtensionID)
            }
        }
        $registry.Dispose()
    }

    try {
        $extensions = 'cjpalhdlnbpafiamejdnhcphjbkeiagm','eimadpbcbfnmbkopoojfekhnkhdbieeh','ddkjiahejlhfcafbddmgiahcphecmpfh'
        $extensions | %{ Set-ChromeExtension -ExtensionID $_ }

        Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion/Themes/Personalize" -Name SystemUsesLightTheme -Value 0
        Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft/Windows/CurrentVersion/Themes/Personalize" -Name AppsUseLightTheme -Value 0
    }
    catch {
        Write-Output $_.Exception.Message
    }
}

$encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script))

Start-Process PowerShell -ArgumentList "-NoExit -EncodedCommand $encodedScript" -Verb RunAs
