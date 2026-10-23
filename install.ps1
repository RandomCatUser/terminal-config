param([switch]$Elevated)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
try {
  $Host.UI.RawUI.WindowTitle = 'Terminal Config'
} catch {
}
try {
  Add-Type -Namespace 'Fastfetch.Setup' -Name 'ConsoleApi' -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
[DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, ref int m);
[DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, int m);
'@ | Out-Null
  $stdOutHandle = [Fastfetch.Setup.ConsoleApi]::GetStdHandle(-11)
  $consoleMode = 0
  [void][Fastfetch.Setup.ConsoleApi]::GetConsoleMode($stdOutHandle, [ref]$consoleMode)
  [void][Fastfetch.Setup.ConsoleApi]::SetConsoleMode($stdOutHandle, $consoleMode -bor 4)
} catch {
}

$esc = [char]27
$reset = "$esc" + '[0m'
$bold = "$esc" + '[1m'
$pink = "$esc" + '[38;2;255;143;208m'
$violet = "$esc" + '[38;2;122;107;242m'
$lav = "$esc" + '[38;2;208;188;244m'
$dim = "$esc" + '[38;2;152;138;192m'
$green = "$esc" + '[38;2;142;228;178m'
$amber = "$esc" + '[38;2;255;190;120m'

$repo = $PSScriptRoot
$dest = Join-Path $env:USERPROFILE '.config\fastfetch'
$ompThemeDir = Join-Path $env:USERPROFILE '.config\oh-my-posh'
$promptScheme = 'Catppuccin Mocha'
$stepIndex = 0
$stepsTotal = 6

function Show-Banner {
  Write-Host ''
  Write-Host "  $pink⣿⣿⣿⣿$lav⣿⣿⣿⣿$violet⣿⣿⣿⣿$reset  $bold✿ fastfetch — windows setup$reset"
  Write-Host "  ${dim}installer ⋅ font + prompt + binary + config + logo + readme$reset"
  Write-Host "  $violet$('─' * 60)$reset"
  Write-Host "  ${dim}repo  $reset$lav$repo$reset"
  Write-Host "  ${dim}dest  $reset$lav$dest$reset"
}

function Write-Step([string]$text) {
  $script:stepIndex++
  Start-Sleep -Milliseconds 400
  Write-Host ''
  Write-Host "  $dim▸$reset $pink[$script:stepIndex/$script:stepsTotal]$reset $bold$text$reset"
}

function Write-Sub([string]$text, [string]$color = $lav) {
  Write-Host "    $dim└─$reset $color$text$reset"
}

function Test-Admin {
  $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
  $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Update-SessionPath {
  $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  $env:Path = "$machinePath;$userPath"
}

function Find-Fastfetch {
  $cmd = Get-Command fastfetch -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $candidates = @(
    (Join-Path $env:ProgramFiles 'fastfetch\fastfetch.exe'),
    "$env:LOCALAPPDATA\Microsoft\WinGet\Links\fastfetch.exe"
  )
  foreach ($candidate in $candidates) {
    if (Test-Path $candidate) { return $candidate }
  }
  return $null
}

function Confirm-Question([string]$question) {
  while ($true) {
    $answer = Read-Host "  $pink?$reset $bold$question [Y/n]$reset"
    if ([string]::IsNullOrWhiteSpace($answer)) { return $true }
    $clean = $answer.Trim().ToLowerInvariant()
    if ($clean -eq 'y' -or $clean -eq 'yes') { return $true }
    if ($clean -eq 'n' -or $clean -eq 'no') { return $false }
    Write-Host "    $amberplease answer y or n$reset"
  }
}

function Find-JetbrainsNerdFont {
  $hives = @('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts', 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts')
  foreach ($hive in $hives) {
    if (-not (Test-Path $hive)) { continue }
    $values = (Get-ItemProperty -Path $hive).PSObject.Properties.Name
    foreach ($value in $values) {
      if ($value -match 'JetBrains' -and $value -match 'Nerd|NFM|NF') { return $value }
    }
  }
  $dirs = @((Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'), (Join-Path $env:WINDIR 'Fonts'))
  foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) { continue }
    $fonts = Get-ChildItem -LiteralPath $dir -Filter 'JetBrains*' -ErrorAction SilentlyContinue
    foreach ($font in $fonts) {
      if ($font.Name -match 'Nerd|NFM|NF') { return $font.Name }
    }
  }
  return $null
}

function Install-JetbrainsNerdFont {
  $oldPreference = $ProgressPreference
  $ProgressPreference = 'SilentlyContinue'
  try {
    $zipFile = Join-Path $env:TEMP 'JetBrainsMonoNerdFont.zip'
    $unzipDir = Join-Path $env:TEMP 'JetBrainsMonoNerdFont'
    $userFonts = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    Write-Sub 'downloading latest JetBrainsMono Nerd Font from nerd-fonts releases…'
    Invoke-WebRequest -Uri 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip' -OutFile $zipFile -UseBasicParsing
    if (Test-Path $unzipDir) { Remove-Item -LiteralPath $unzipDir -Recurse -Force }
    Expand-Archive -LiteralPath $zipFile -DestinationPath $unzipDir -Force
    New-Item -ItemType Directory -Force -Path $userFonts | Out-Null
    $fontsKey = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    $familyNames = @{ JetBrainsMonoNerdFont = 'JetBrainsMono Nerd Font'; JetBrainsMonoNerdFontMono = 'JetBrainsMono Nerd Font Mono' }
    $installed = 0
    foreach ($family in @('JetBrainsMonoNerdFont', 'JetBrainsMonoNerdFontMono')) {
      foreach ($style in @('Regular', 'Bold', 'Italic', 'BoldItalic')) {
        $sourceTtf = Join-Path $unzipDir ($family + '-' + $style + '.ttf')
        if (-not (Test-Path -LiteralPath $sourceTtf)) { continue }
        $targetTtf = Join-Path $userFonts ($family + '-' + $style + '.ttf')
        Copy-Item -LiteralPath $sourceTtf -Destination $targetTtf -Force
        $registryName = ($familyNames[$family] + ' ' + $style + ' (TrueType)')
        New-ItemProperty -Path $fontsKey -Name $registryName -Value $targetTtf -PropertyType String -Force | Out-Null
        $installed++
      }
    }
    Remove-Item -LiteralPath $unzipDir -Recurse -Force
    Remove-Item -LiteralPath $zipFile -Force
    Write-Sub "registered $installed styles per-user (no admin needed)" $green
  } finally {
    $ProgressPreference = $oldPreference
  }
  $detected = Find-JetbrainsNerdFont
  if ($detected) {
    Write-Sub "font detected → $detected" $green
  } else {
    Write-Sub 'font may need a terminal restart to finish registering' $amber
  }
}

function Copy-RepoFile([string]$name, [string]$targetDir) {
  $src = Join-Path $repo $name
  $dst = Join-Path $targetDir $name
  if (-not (Test-Path $src)) { return 'missing' }
  $wasIdentical = (Test-Path $dst) -and ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash)
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
  Copy-Item -Path $src -Destination $dst -Force
  $state = 'deployed'
  if ($wasIdentical) { $state = 'unchanged' }
  return $state
}

function Deploy-File([string]$name) {
  $state = Copy-RepoFile $name $dest
  if ($state -eq 'missing') {
    Write-Sub "$name missing in repo — skipped" $amber
    return
  }
  Write-Sub "$name → $state"
}

function Find-OhMyPosh {
  $cmd = Get-Command oh-my-posh -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $candidates = @(
    "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe",
    "$env:LOCALAPPDATA\Programs\oh-my-posh\oh-my-posh.exe"
  )
  foreach ($candidate in $candidates) {
    if (Test-Path $candidate) { return $candidate }
  }
  return $null
}

function Find-MatchingBrace([string]$text, [int]$openIndex) {
  $depth = 0
  $inString = $false
  for ($i = $openIndex; $i -lt $text.Length; $i++) {
    $ch = $text[$i]
    if ($inString) {
      if ($ch -eq '\') { $i++ }
      elseif ($ch -eq '"') { $inString = $false }
      continue
    }
    if ($ch -eq '"') { $inString = $true; continue }
    if ($ch -eq '{') { $depth++ }
    elseif ($ch -eq '}') {
      $depth--
      if ($depth -eq 0) { return $i }
    }
  }
  return -1
}

function Ensure-TerminalScheme([string]$text) {
  if ($text -match ('"name"\s*:\s*"' + $promptScheme + '"')) {
    return $text
  }
  $block = @'
        {
            "background": "#1E1E2E",
            "black": "#45475A",
            "blue": "#89B4FA",
            "brightBlack": "#585B70",
            "brightBlue": "#89B4FA",
            "brightCyan": "#94E2D5",
            "brightGreen": "#A6E3A1",
            "brightPurple": "#F5C2E7",
            "brightRed": "#F38BA8",
            "brightWhite": "#A6ADC8",
            "brightYellow": "#F9E2AF",
            "cursorColor": "#F5E0DC",
            "cyan": "#94E2D5",
            "foreground": "#CDD6F4",
            "green": "#A6E3A1",
            "name": "Catppuccin Mocha",
            "purple": "#F5C2E7",
            "red": "#F38BA8",
            "selectionBackground": "#585B70",
            "white": "#BAC2DE",
            "yellow": "#F9E2AF"
        }
'@
  if ($text -match '"schemes"\s*:\s*\[') {
    return [regex]::Replace($text, '"schemes"\s*:\s*\[', ('$1' + "`n" + $block + ','))
  }
  $insertion = '  "schemes": [' + "`n" + $block + "`n" + '  ],' + "`n"
  return $text.Insert($text.LastIndexOf('}'), $insertion)
}

function Set-TerminalScalar([string]$slice, [string]$key, [string]$value) {
  $fullPattern = '("' + $key + '"\s*:\s*)("[^"]*"|[^,}\s]+)'
  if ($slice -match $fullPattern) {
    return [regex]::Replace($slice, $fullPattern, ('${1}' + $value))
  }
  if ($slice.Trim().Length -eq 0) { return '  "' + $key + '": ' + $value }
  return '  "' + $key + '": ' + $value + ', ' + $slice.TrimStart()
}

function Set-TerminalFont([string]$slice) {
  $fontObject = '{ "face": "JetBrainsMono Nerd Font Mono", "size": 10, "weight": "extra-black", "cellHeight": "1.2" }'
  $fontMatch = [regex]::Match($slice, '"font"\s*:\s*\{')
  if (-not $fontMatch.Success) {
    return (Set-TerminalScalar $slice 'font' $fontObject)
  }
  $openIndex = $fontMatch.Index + $fontMatch.Value.LastIndexOf('{')
  $closeIndex = Find-MatchingBrace $slice $openIndex
  if ($closeIndex -lt 0) { return $slice }
  return $slice.Remove($fontMatch.Index, $closeIndex - $fontMatch.Index + 1).Insert($fontMatch.Index, ('"font": ' + $fontObject))
}

function Update-TerminalDefaults([string]$text) {
  $defaultsMatch = [regex]::Match($text, '"defaults"\s*:\s*\{')
  if (-not $defaultsMatch.Success) { return $text }
  $openIndex = $defaultsMatch.Index + $defaultsMatch.Value.LastIndexOf('{')
  $closeIndex = Find-MatchingBrace $text $openIndex
  if ($closeIndex -lt 0) { return $text }
  $slice = $text.Substring($openIndex + 1, $closeIndex - $openIndex - 1)
  $newSlice = Set-TerminalScalar $slice 'colorScheme' ('"' + $promptScheme + '"')
  $newSlice = Set-TerminalScalar $newSlice 'cursorShape' '"filledBox"'
  $newSlice = Set-TerminalScalar $newSlice 'intenseTextStyle' '"all"'
  $newSlice = Set-TerminalScalar $newSlice 'opacity' '80'
  $newSlice = Set-TerminalScalar $newSlice 'padding' '"8"'
  $newSlice = Set-TerminalScalar $newSlice 'useAcrylic' 'true'
  $newSlice = Set-TerminalFont $newSlice
  if ($newSlice -eq $slice) { return $text }
  return $text.Remove($openIndex + 1, $closeIndex - $openIndex - 1).Insert($openIndex + 1, $newSlice)
}

function Update-TerminalLook {
  $packages = Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Packages') -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Microsoft.WindowsTerminal*' }
  foreach ($package in $packages) {
    $settingsPath = Join-Path (Join-Path $package.FullName 'LocalState') 'settings.json'
    if (-not (Test-Path $settingsPath)) { continue }
    $rawBytes = [IO.File]::ReadAllBytes($settingsPath)
    $hadBom = ($rawBytes.Length -ge 3 -and $rawBytes[0] -eq 0xEF -and $rawBytes[1] -eq 0xBB -and $rawBytes[2] -eq 0xBF)
    $text = [IO.File]::ReadAllText($settingsPath, [Text.UTF8Encoding]::new($false))
    $newText = Ensure-TerminalScheme $text
    $newText = Update-TerminalDefaults $newText
    if ($newText -ne $text) {
      Copy-Item -LiteralPath $settingsPath -Destination ($settingsPath + '.bak') -Force
      [IO.File]::WriteAllText($settingsPath, $newText, [Text.UTF8Encoding]::new($hadBom))
      Write-Sub ('terminal look updated in ' + $package.Name + ' (backup: settings.json.bak)') $green
    } else {
      Write-Sub ('terminal look already applied in ' + $package.Name)
    }
  }
}

function Update-PowerShellProfile {
  $deployedTheme = Join-Path $ompThemeDir 'catppuccin-mocha.omp.json'
  $initLine = 'oh-my-posh init pwsh --config "' + $deployedTheme + '" | Invoke-Expression'
  $documents = [Environment]::GetFolderPath('MyDocuments')
  $profilePaths = @((Join-Path $documents 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1'), (Join-Path $documents 'PowerShell\Microsoft.PowerShell_profile.ps1'))
  foreach ($profilePath in $profilePaths) {
    $hostLabel = 'PowerShell'
    if ($profilePath -like '*\WindowsPowerShell\*') { $hostLabel = 'Windows PowerShell' }
    elseif ($profilePath -like '*\PowerShell\*') { $hostLabel = 'PowerShell 7' }
    $existed = Test-Path $profilePath
    $text = ''
    if ($existed) {
      $text = [IO.File]::ReadAllText($profilePath, [Text.UTF8Encoding]::new($false))
    } else {
      New-Item -ItemType Directory -Force -Path (Split-Path $profilePath -Parent) | Out-Null
    }
    $original = $text
    if ($text -match 'oh-my-posh\s+init') {
      if ($text -notmatch '--config\s') {
        $text = ($text.TrimEnd() + "`r`n" + $initLine + "`r`n")
      } else {
        $text = [regex]::Replace($text, '--config\s+["''][^"'']*["'']', ('--config "' + $deployedTheme + '"'))
      }
    } else {
      if ($text.TrimEnd().Length -gt 0) {
        $text = ($text.TrimEnd() + "`r`n" + $initLine + "`r`n")
      } else {
        $text = ($initLine + "`r`n")
      }
    }
    if ($text -ne $original) {
      [IO.File]::WriteAllText($profilePath, $text, [Text.UTF8Encoding]::new($false))
      if ($existed) {
        Write-Sub ($hostLabel + ' profile → local theme') $green
      } else {
        Write-Sub ($hostLabel + ' profile created → local theme') $green
      }
    } else {
      Write-Sub ($hostLabel + ' profile unchanged')
    }
  }
}

function Update-LogoPath {
  $cfgPath = Join-Path $dest 'config.jsonc'
  if (-not (Test-Path $cfgPath)) {
    Write-Sub 'config.jsonc not deployed — logo path untouched' $amber
    return
  }
  $utf8 = [Text.UTF8Encoding]::new($false)
  $config = [IO.File]::ReadAllText($cfgPath, $utf8)
  $logoTarget = (Join-Path $dest 'logo.txt') -replace '\\', '/'
  $patched = [regex]::Replace($config, '("source"\s*:\s*)"[^"]*logo\.txt"', ('$1"' + $logoTarget + '"'))
  [IO.File]::WriteAllText($cfgPath, $patched, $utf8)
  Write-Sub "logo source → $logoTarget"
}

Show-Banner
$isAdmin = Test-Admin
$winget = Get-Command winget -ErrorAction SilentlyContinue

Write-Step 'environment'
if ($winget) {
  $wingetVersion = & winget --version
  Write-Sub "winget $wingetVersion"
} else {
  Write-Sub 'winget unavailable — installs may need manual download' $amber
}
Write-Sub "powershell $($PSVersionTable.PSVersion) ⋅ admin: $isAdmin"

Write-Step 'jetbrains mono nerd font'
$fontEntry = Find-JetbrainsNerdFont
if ($fontEntry) {
  Write-Sub "already installed → $fontEntry" $green
} elseif (-not (Confirm-Question 'install JetBrainsMono Nerd Font now? (the config glyphs need it)')) {
  Write-Sub 'skipping — saying no keeps the icons as boxes until a Nerd Font is set up' $amber
} else {
  try {
    Install-JetbrainsNerdFont
  } catch {
    Write-Sub "font install failed → $($_.Exception.Message)" $amber
    Write-Sub 'grab it manually: https://www.nerdfonts.com/font-downloads' $amber
  }
}

Write-Step 'oh-my-posh prompt'
$omp = Find-OhMyPosh
if ($omp) {
  $ompVersion = & $omp --version
  Write-Sub "already installed → oh-my-posh $ompVersion" $green
} elseif (-not $winget) {
  Write-Sub 'winget unavailable — install oh-my-posh manually' $amber
  Write-Sub 'https://ohmyposh.dev/docs/installation/windows' $amber
} elseif (-not (Confirm-Question 'install oh-my-posh via winget now? (colorful prompt)')) {
  Write-Sub 'skipping — prompt and terminal look stay untouched; rerun the installer later' $amber
} else {
  Write-Sub 'installing with winget…'
  winget install --id JanDeDobbeleer.OhMyPosh -e --accept-source-agreements --accept-package-agreements
  if ($LASTEXITCODE -eq 0) {
    Update-SessionPath
    $omp = Find-OhMyPosh
    if ($omp) {
      $ompVersion = & $omp --version
      Write-Sub "installed → oh-my-posh $ompVersion" $green
    } else {
      Write-Sub 'installed but not on PATH yet — reopen the terminal and rerun' $amber
    }
  } elseif (-not $Elevated) {
    try {
      Write-Sub 'retrying with administrator rights…' $amber
      Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Elevated') | Out-Null
      exit 0
    } catch {
      Write-Sub 'elevation refused — install manually: https://ohmyposh.dev/docs/installation/windows' $amber
    }
  } else {
    Write-Sub 'winget install failed — check the log above' $amber
  }
}

if ($omp) {
  $themeState = Copy-RepoFile 'catppuccin-mocha.omp.json' $ompThemeDir
  if ($themeState -eq 'missing') {
    Write-Sub 'theme catppuccin-mocha.omp.json missing in repo — skipped' $amber
  } else {
    Write-Sub "catppuccin-mocha.omp.json → $themeState"
  }
  Update-PowerShellProfile
  if (Confirm-Question 'apply the terminal look in Windows Terminal now? (Catppuccin Mocha + JetBrains Mono)') {
    Update-TerminalLook
  } else {
    Write-Sub 'windows terminal untouched' $amber
  }
}

Write-Step 'fastfetch binary'
$fastfetch = Find-Fastfetch
if ($fastfetch) {
  $installedVersion = & $fastfetch --version | Select-Object -First 1
  Write-Sub "already installed → $installedVersion" $green
} elseif (-not $winget) {
  Write-Sub 'winget unavailable — install fastfetch manually' $amber
  Write-Sub 'https://github.com/fastfetch-cli/fastfetch/releases' $amber
} elseif (-not (Confirm-Question 'install fastfetch via winget now?')) {
  Write-Sub 'skipping — saying no keeps fastfetch absent; rerun the installer later' $amber
} else {
  Write-Sub 'installing with winget…'
  winget install --id Fastfetch.cli.Fastfetch -e --accept-source-agreements --accept-package-agreements
  if ($LASTEXITCODE -eq 0) {
    Update-SessionPath
    $fastfetch = Find-Fastfetch
    if ($fastfetch) {
      $installedVersion = & $fastfetch --version | Select-Object -First 1
      Write-Sub "installed → $installedVersion" $green
    } else {
      Write-Sub 'installed but not on PATH yet — reopen the terminal to preview' $amber
    }
  } elseif (-not $Elevated) {
    try {
      Write-Sub 'retrying with administrator rights…' $amber
      Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Elevated') | Out-Null
      exit 0
    } catch {
      Write-Sub 'elevation refused — install manually: https://github.com/fastfetch-cli/fastfetch/releases' $amber
    }
  } else {
    Write-Sub 'winget install failed — check the log above' $amber
  }
}

Write-Step 'config'
Deploy-File 'config.jsonc'
Deploy-File 'logo.txt'
Deploy-File 'README.md'
Update-LogoPath

Write-Step 'preview'
if ($fastfetch) {
  & $fastfetch
} else {
  Write-Sub 'no preview — fastfetch is not installed yet' $amber
}

Write-Host ''
if ($fastfetch -and $omp) {
  Write-Host "  $green●$reset ${bold}setup complete$reset $dim— new terminals get the themed prompt, the terminal look and fastfetch$reset"
} else {
  Write-Host "  $amber●$reset ${bold}setup finished with gaps$reset $dim— rerun the installer to take care of the skipped pieces$reset"
}
Write-Host ''
