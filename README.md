# ✿ Terminal Config

One-click Windows terminal setup: an oh-my-posh prompt, a fastfetch display
and a matching Windows Terminal look — pink → violet all the way.

## files

| file | purpose |
| --- | --- |
| `install.ps1` | installer — installs fastfetch + oh-my-posh and deploys config + logo + readme |
| `install.bat` | double-click launcher for `install.ps1` (handles execution policy) |
| `config.jsonc` | fastfetch theme config (keys, palette, modules) |
| `logo.txt` | braille art logo with the pink → violet gradient |
| `catppuccin-mocha.omp.json` | oh-my-posh prompt theme — Catppuccin Mocha |
| `regen-logo.ps1` | rebuilds `logo.txt` from a raw braille art file |
| `README.md` | this file |

## quick start

Double-click `install.bat` — it runs `install.ps1` with the execution policy
bypassed, so nothing else is needed. The installer walks you through setup
slowly and asks first at every install point — answer `y` or `n` at each
prompt; saying no just skips that piece and everything else still runs.

```
: the easy ways
double-click install.bat
right-click install.ps1 → Run with PowerShell

: from an existing terminal
powershell -ExecutionPolicy Bypass -File install.ps1
```

## what the installer does

1. checks for winget and reports the environment
2. detects a JetBrainsMono Nerd Font — if missing, it asks first:
   - `y` downloads the family from the
     [nerd-fonts releases](https://github.com/ryanoasis/nerd-fonts/releases)
     and installs it **per-user** (no admin): Regular / Bold / Italic /
     BoldItalic for both `JetBrainsMono Nerd Font` and
     `JetBrainsMono Nerd Font Mono`, into
     `%LOCALAPPDATA%\Microsoft\Windows\Fonts` + HKCU registration
   - `n` skips it — the rest of the setup continues, glyphs stay as boxes
     until you set a Nerd Font yourself
3. detects oh-my-posh — if missing, it asks first:
   - `y` installs it via winget (`JanDeDobbeleer.OhMyPosh`), retrying
     elevated with admin rights if the install needs it
   - `n` skips — prompt and terminal look stay untouched
4. deploys `catppuccin-mocha.omp.json` into `%USERPROFILE%\.config\oh-my-posh`,
   points every existing PowerShell profile (Windows PowerShell + PowerShell
   7) at the **local** theme instead of the GitHub raw URL, and asks before
   applying the terminal look to Windows Terminal (`settings.json` — color
   scheme `Catppuccin Mocha`, JetBrainsMono Nerd Font Mono extra-black,
   opacity/acrylic/padding/cursor); a `settings.json.bak` backup is written
   next to it before any change
5. detects fastfetch — if missing, it asks first:
   - `y` installs it via winget (`Fastfetch.cli.Fastfetch`), retrying
     elevated with admin rights if the install needs it
   - `n` skips it — config still deploys, preview is skipped
6. copies `config.jsonc`, `logo.txt` and `README.md` into
   `%USERPROFILE%\.config\fastfetch`
7. rewrites the logo `source` path in the deployed config so it always points
   at the deployed logo
8. runs fastfetch once as a preview

Files that already match are diffed by hash and reported as `unchanged`, so
re-running the installer is always safe.

## requirements

- Windows 10/11 with winget — otherwise grab fastfetch manually from
  <https://github.com/fastfetch-cli/fastfetch/releases>
- a Nerd Font for the glyph keys — the installer detects JetBrainsMono Nerd
  Font and offers to install it for you (per-user, admin-free); missing
  fonts render the module keys as boxes
- Windows Terminal recommended: full 24-bit colors and VT output

## theming

fastfetch auto-loads `%USERPROFILE%\.config\fastfetch\config.jsonc`.

- keys + title: pink `#ff8fd0`
- separator: violet `#7a6bf2`
- modules: OS · Kernel · Uptime · Shell · Terminal · TerminalFont · Colors

The PowerShell prompt uses the Catppuccin Mocha oh-my-posh theme from
`~\.config\oh-my-posh`, loaded locally (works offline). Windows Terminal gets
the same look: Catppuccin Mocha scheme, JetBrainsMono Nerd Font Mono at
10pt extra-black, 1.2 line spacing, 80% acrylic opacity, filledBox cursor.
To try a different prompt theme: replace `catppuccin-mocha.omp.json` in this
folder with another theme file and rerun the installer — the profiles are
re-pointed automatically.

## regenerating the logo

1. point the two paths at the top of `regen-logo.ps1` at your raw braille art
   file and the deployed `logo.txt`
2. run `regen-logo.ps1`
3. re-run the installer to redeploy `logo.txt` (it hashes to `unchanged` /
   `deployed` honestly)

## uninstall

```
winget uninstall Fastfetch.cli.Fastfetch
```

and delete `%USERPROFILE%\.config\fastfetch` if you want the theme gone too.
