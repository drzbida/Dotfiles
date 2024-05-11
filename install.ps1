$DotfilesDir = "$env:USERPROFILE\Dotfiles"

$Links = @{
  "$DotfilesDir\.wezterm.lua" = "$env:USERPROFILE\.wezterm.lua"
  "$DotfilesDir\Microsoft.PowerShell_profile.ps1" = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
  "$DotfilesDir\nvim" = "$env:LOCALAPPDATA\nvim"
}

foreach ($src in $Links.Keys) {
  $dst = $Links[$src]

  if (Test-Path $dst) {
    Remove-Item $dst -Recurse -Force
  }

  New-Item -ItemType SymbolicLink -Path $dst -Target $src
  Write-Output "Symlinked $dst to $src"
}
