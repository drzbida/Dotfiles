Import-Module PSReadLine

oh-my-posh init pwsh --config "$env:USERPROFILE/Dotfiles/.oh-my-posh.json" | Invoke-Expression

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
