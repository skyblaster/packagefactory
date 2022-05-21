<#
    .SYNOPSIS
    Uninstalls the application
#>
[CmdletBinding()]
Param ()

#region Restart if running in a 32-bit session
If (!([System.Environment]::Is64BitProcess)) {
    If ([System.Environment]::Is64BitOperatingSystem) {
        $Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($MyInvocation.MyCommand.Definition)`""
        $ProcessPath = $(Join-Path -Path $Env:SystemRoot -ChildPath "\Sysnative\WindowsPowerShell\v1.0\powershell.exe")
        Write-Verbose -Message "Restarting in 64-bit PowerShell."
        Write-Verbose -Message "FilePath: $ProcessPath."
        Write-Verbose -Message "Arguments: $Arguments."
        $params = @{
            FilePath     = $ProcessPath
            ArgumentList = $Arguments
            Wait         = $True
            WindowStyle  = "Hidden"
        }
        Start-Process @params
        Exit 0
    }
}
#endregion

try {
    $Path = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{7f0d7424-d132-4aaf-baa9-5d7d436f0feb}"
    $Command = Get-ItemProperty -Path $Path -ErrorAction "SilentlyContinue" | Select-Object -ExpandProperty "QuietUninstallString" -First 1
    $Executable = ($Command -split "/")[0]
    $params = @{
        FilePath     = $Executable
        ArgumentList = "/uninstall /quiet /norestart"
        NoNewWindow  = $True
        PassThru     = $True
        Wait         = $True
    }
    $result = Start-Process @params
}
catch {
    throw "Failed to uninstall Microsoft PowerToys."
}
finally {
    exit $result.ExitCode
}
