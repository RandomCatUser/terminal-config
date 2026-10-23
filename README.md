# ✿ Terminal Config

hi, this is my entire Windows terminal personality in one folder: **fastfetch**
with a hand-tinted braille logo, an **oh-my-posh** prompt in Catppuccin Mocha,
and a **Windows Terminal** look to match — pink fading into violet, glyphs
from a Nerd Font, subtle acrylic. It installs itself. You just double-click
and pick a file (or gap) apart later — nothing is forced on you.

## files

| file | purpose |
| --- | --- |
| `install.ps1` | the installer — walks through everything, asks before it touches anything |
| `install.bat` | double-click launcher for `install.ps1` (no execution-policy drama) |
| `config.jsonc` | fastfetch theme — keys, palette, modules |
| `logo.txt` | the braille art logo, tinted pink → violet |
| `catppuccin-mocha.omp.json` | oh-my-posh prompt theme — Catppuccin Mocha |
| `regen-logo.ps1` | rebuilds `logo.txt` from raw braille art |
| `README.md` | you are here |

## quick start

Double-click `install.bat`. That's it. It runs `install.ps1` with the
execution policy bypassed and walks you through everything, one small step at
a time, asking `y` or `n` before each install. Saying **no never breaks
anything** — it just skips that piece and carries on.

Prefer doing it by hand?

```
double-click install.bat
right-click install.ps1 → Run with PowerShell
powershell -ExecutionPolicy Bypass -File install.ps1
```

## the walk-through, step by step

1. checks the environment — winget, PowerShell version, admin status
2. **JetBrainsMono Nerd Font** — already installed? green check. If not, it
   asks first:
   - `y` downloads the family from the
     [nerd-fonts releases](https://github.com/ryanoasis/nerd-fonts/releases)
     and installs it **per-user, no admin needed** — Regular / Bold / Italic /
     BoldItalic for both `JetBrainsMono Nerd Font` and
     `JetBrainsMono Nerd Font Mono`
   - `n` skip, and the glyphs will politely stay as boxes until you set a
     Nerd Font yourself
3. **oh-my-posh** — same deal, asked first:
   - `y` installs via winget (`JanDeDobbeleer.OhMyPosh`), retrying elevated
     only if the installer truly needs it
   - `n` prompt and terminal look stay untouched
4. **prompt + terminal look** — drops `catppuccin-mocha.omp.json` into
   `%USERPROFILE%\.config\oh-my-posh` and re-points every PowerShell profile
   (Windows PowerShell and PowerShell 7) at the **local copy**, so the prompt
   works offline. It then asks before touching Windows Terminal's
   `settings.json`: Catppuccin Mocha scheme, JetBrainsMono Nerd Font Mono at
   10pt extra-black, 1.2 line height, 80% acrylic, `filledBox` cursor. A
   `settings.json.bak` lands next to your settings before a single character
   changes.
5. **fastfetch** — asked first:
   - `y` winget (`Fastfetch.cli.Fastfetch`), elevation retry if needed
   - `n` config still deploys, only the preview gets skipped
6. deploys `config.jsonc`, `logo.txt` and `README.md` into
   `%USERPROFILE%\.config\fastfetch`, and rewrites the logo `source` path so
   it always points at the deployed logo — the whole thing stays portable
7. runs fastfetch once so you can admire it immediately

Everything is hash-compared on rerun: `unchanged` beats `deployed` when files
already match, so **rerunning is always safe**.

## theming

fastfetch auto-loads `%USERPROFILE%\.config\fastfetch\config.jsonc`.

- keys + title: pink `#ff8fd0`
- separator: violet `#7a6bf2`
- modules: OS · Kernel · Uptime · Shell · Terminal · TerminalFont · Colors

The prompt reads the Catppuccin Mocha theme from
`~\.config\oh-my-posh` locally — no network needed after install. Want to try
another theme? Drop any `*.omp.json` replacing `catppuccin-mocha.omp.json`
here, rerun the installer, and every profile gets re-pointed automatically.

## regenerating the logo

1. point the two paths at the top of `regen-logo.ps1` at your raw braille
   art file and the deployed `logo.txt`
2. run `regen-logo.ps1`
3. rerun the installer to redeploy — `unchanged` / `deployed` tells you
   honestly whether anything moved

## uninstall

```
winget uninstall Fastfetch.cli.Fastfetch
```

and delete `%USERPROFILE%\.config\fastfetch` (plus `~\.config\oh-my-posh`)
if you want the theme gone too. Windows Terminal keeps its own backups.

## credits ❤

- **[SleepyCatHey → Ultimate-Win11-Setup](https://github.com/SleepyCatHey/Ultimate-Win11-Setup)**
  — the tastemaker behind all of this. The terminal styling and the
  Catppuccin Mocha **oh-my-posh** theme are lifted from that wonderful
  Windows 11 setup guide. If this repo prettified your terminal, go give the
  sleepy cat a star, it earned it 😺
- [fastfetch](https://github.com/fastfetch-cli/fastfetch) — the fetch
- [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh) — the prompt
- [Catppuccin](https://catppuccin.com) — the pastel palette
- [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) — the glyphs
- [Windows Terminal](https://github.com/microsoft/terminal) — the window that
  makes all the colors possible
