Import-Module PSReadLine

oh-my-posh init pwsh --config "$env:USERPROFILE/.oh-my-posh.json" | Invoke-Expression

# function prompt {
#     $p = $executionContext.SessionState.Path.CurrentLocation
#     $osc7 = ""
#
#     if ($p.Provider.Name -eq "FileSystem") {
#         $ansi_escape = [char]27
#         $provider_path = $p.ProviderPath -Replace "\\", "/"
#         $osc7 = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
#     }
#
#     $lastCommand = (Get-History -Count 1).CommandLine
#     $encodedValue = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($lastCommand))
#     $osc1337= "$ansi_escape]1337;SetUserVar=LAST_COMMAND=$encodedValue$ansi_escape\"
#     $osc1337 = ""  # Currently not used, so cleared
#
#     $ohMyPoshPrompt = oh-my-posh init pwsh --config "$env:USERPROFILE/.oh-my-posh.json" 
#     "${osc7}${osc1337} ";
#     $ohMyPoshPrompt | Invoke-Expression
# }

function OnViModeChange {
    if ($args[0] -eq 'Command') {
        Write-Host -NoNewLine "`e[1 q"
    } else {
        Write-Host -NoNewLine "`e[5 q"
    }
}
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
Set-PSReadLineOption -AddToHistoryHandler $Function:CommandAddedToHistoryHandler
Set-PSReadLineOption -BellStyle Visual
