param()
$raw  = 'C:\Users\cat\AppData\Local\Temp\opencode\art-raw.txt'
$out  = 'C:\Users\cat\.config\fastfetch\logo.txt'
$txt  = [IO.File]::ReadAllText($raw, [Text.UTF8Encoding]::new($false))
$lines = @($txt -split "`r?`n" | Where-Object { $_.Length -gt 0 })
$W = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
$H = $lines.Count

# Vertical hue: sakura pink (top) -> violet (bottom)
$top    = @(255, 158, 205)
$bottom = @(122, 107, 242)

function BitCount([int]$n) {
  $c = 0
  while ($n -ne 0) { $n = $n -band ($n - 1); $c++ }
  return $c
}

$sb = New-Object Text.StringBuilder
for ($r = 0; $r -lt $H; $r++) {
  if ($H -gt 1) { $yNorm = $r / ($H - 1) } else { $yNorm = 0.0 }
  # row base colour (hue drift)
  $base = @()
  for ($k = 0; $k -lt 3; $k++) { $base += ($top[$k] + ($bottom[$k] - $top[$k]) * $yNorm) }
  # light / dark variants: IRL shading
  $lightC = @()
  foreach ($v in $base) { $lightC += [math]::Min(255, [int]([math]::Round($v * 0.18 + 255 * 0.82))) }
  $darkC = @()
  foreach ($v in $base) { $darkC += [int][math]::Round($v * 0.46 + 30 * 0.04) }

  $line = $lines[$r].PadRight($W, ' ')
  for ($x = 0; $x -lt $line.Length; $x++) {
    $ch = $line[$x]
    $cp = [int][char]$ch
    if ($cp -ge 0x2800 -and $cp -le 0x28FF) {
      $dots = BitCount ($cp - 0x2800)
      if ($dots -eq 0) {
        # blank braille cell: no colour needed
        [void]$sb.Append($ch)
        continue
      }
      $t = $dots / 8.0
      $c = @()
      for ($k = 0; $k -lt 3; $k++) {
        $c += [int][math]::Round($lightC[$k] + ($darkC[$k] - $lightC[$k]) * $t)
      }
      [void]$sb.Append([char]27 + '[38;2;' + $c[0] + ';' + $c[1] + ';' + $c[2] + 'm' + $ch)
    } elseif ($ch -ne ' ') {
      # non-braille char: neutral soft lavender
      [void]$sb.Append([char]27 + '[38;2;170;160;230m' + $ch)
    } else {
      [void]$sb.Append($ch)
    }
  }
  [void]$sb.Append([char]27 + '[0m')
  if ($r -lt $H - 1) { [void]$sb.Append("`n") }
}
[IO.File]::WriteAllText($out, $sb.ToString(), [Text.UTF8Encoding]::new($false))
"wrote logo.txt: $H rows x $W cols, $((Get-Item $out).Length) bytes"
