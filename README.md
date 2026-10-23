# ✿ Terminal Config

the windows terminal setup that follows me between reinstall dates —
fastfetch, oh-my-posh, the font, the window — all Catppuccin Mocha, all
pink-to-violet, all asking before it touches a thing. one double-click.

<div align="center">
  <img src="Screenshots/fastfetch.png" alt="fastfetch — braille cat tinted pink to violet, pink module keys" width="55%"/><br/>
  <img src="Screenshots/prompt.png" alt="oh-my-posh prompt — blue user, pink path, lavender git branch" width="55%"/>
</div>

<div align="center">
  <a href="https://github.com/RandomCatUser/terminal-config/archive/refs/heads/main.zip"><img src="https://img.shields.io/badge/%E2%AC%87%EF%B8%8F%20download-zip-ff8fd0?style=for-the-badge" alt="download zip"></a>
  <a href="https://RandomCatUser.github.io/terminal-config/"><img src="https://img.shields.io/badge/%F0%9F%8C%90%20open-the-site-7a6bf2?style=for-the-badge" alt="open the site"></a>
</div>

## index

- [contents](#contents) — what every file in here is for
- [installing](#installing) — double-click, and the questions it'll ask you
- [the look](#the-look) — the exact colors and settings you end up with
- [customizing](#customizing) — swap the theme, swap the logo
- [leaving](#leaving) — undoing all of it
- [thanks](#thanks-thanks) — where this comes from

## contents

| file | what it does |
| --- | --- |
| `install.bat` | double-click launcher — handles execution policy for you |
| `install.ps1` | the brain — takes you step by step, asks permission |
| `config.jsonc` | fastfetch — what you see when you open a terminal |
| `logo.txt` | the braille cat, pre-tinted pink → violet |
| `catppuccin-mocha.omp.json` | the prompt's theme, served locally |
| `regen-logo.ps1` | repaints `logo.txt` from raw braille art |
| `Screenshots/` | what the terminal actually looks like |
| `index.html` | a tiny landing page for all of it |

## installing

double-click `install.bat`. if anything needs installing, you get a question
first: `y` for yes, `n` for no, and pressing enter just means yes. saying `n`
skips that one piece — the rest of the setup carries on without it.

### the questions it asks

| # | it asks about | `y` does | `n` does |
| --- | --- | --- | --- |
| 1 | **JetBrainsMono Nerd Font** | downloads from the [nerd-fonts release](https://github.com/ryanoasis/nerd-fonts/releases) and installs *per-user* — no admin window | glyphs sit as boxes until you pick a Nerd Font yourself |
| 2 | **oh-my-posh** | winget-installs it, then matches your Windows Terminal to this theme | nothing changes |
| 3 | **Windows Terminal styling** | applies Catppuccin Mocha colors, JetBrainsMono NFM 10pt, acrylic, a filled box cursor — and writes `settings.json.bak` next to `settings.json` first | skips the glass |
| 4 | **fastfetch** | winget-installs it, copies the config + logo into `%USERPROFILE%\.config\fastfetch` | just the config preview |

### good to know

- everything is **hash-checked** — reruns do nothing to files that already
  match and report them as `unchanged`.
- the prompt theme is **served from disk**: all your PowerShell profiles
  (Windows PowerShell and PowerShell 7) point at a local `.omp.json`, so the
  prompt works even with no internet.
- before it touches Windows Terminal, a **`settings.json.bak`** copy is
  already on disk — there's always an undo.

### more of a manual type?

```
right-click install.ps1 → Run with PowerShell
powershell -ExecutionPolicy Bypass -File install.ps1
```

## the look

fastfetch reads `%USERPROFILE%\.config\fastfetch\config.jsonc` by default.

| piece | details |
| --- | --- |
| fastfetch keys + title | pink `#ff8fd0` |
| fastfetch separator | violet `#7a6bf2` |
| shown modules | OS · Kernel · Uptime · Shell · Terminal · TerminalFont · Colors |
| prompt | Catppuccin Mocha, from `~\.config\oh-my-posh` |
| terminal scheme | Catppuccin Mocha |
| terminal font | JetBrainsMono NFM, 10pt extra-black |
| terminal glass | line height 1.2 · acrylic · 80% opacity · `filledBox` cursor |

## customizing

- **theme** — drop any `*.omp.json` over `catppuccin-mocha.omp.json`, rerun
  the installer; the profiles get re-pointed for you.
- **logo** — point the two paths at the top of `regen-logo.ps1` at your raw
  braille art and your deployed `logo.txt`, run it, then rerun the installer.
  the `unchanged` / `deployed` readout tells you if anything actually moved.

## leaving

```
winget uninstall Fastfetch.cli.Fastfetch
```

…along with `%USERPROFILE%\.config\fastfetch` and `~\.config\oh-my-posh` if
you want the pastels gone completely. Windows Terminal keeps its own backups,
so nothing there should surprise you.

## thanks ❤

- [SleepyCatHey — Ultimate-Win11-Setup](https://github.com/SleepyCatHey/Ultimate-Win11-Setup)
  · the reason this looks the way it does. my terminal style and the
  Catppuccin Mocha oh-my-posh theme come straight out of that guide — if this
  repo made your terminal nicer, the sleepy cat deserves a star for it 😺
- [fastfetch](https://github.com/fastfetch-cli/fastfetch) · the fetch
- [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh) · the prompt
- [Catppuccin](https://catppuccin.com) · the palette this whole thing sits on
- [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) · the glyphs
- [Windows Terminal](https://github.com/microsoft/terminal) · the glass wall
  these colors live on
