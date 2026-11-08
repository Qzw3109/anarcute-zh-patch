param(
    [string]$GameDir = ''
)

$ErrorActionPreference = 'Stop'

function Find-Game([string]$explicit) {
    if ($explicit) { return $explicit }
    $roots = @()
    foreach ($reg in @('HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam')) {
        try {
            $p = Get-ItemProperty $reg -ErrorAction Stop
            $v = if ($p.SteamPath) { $p.SteamPath } elseif ($p.InstallPath) { $p.InstallPath } else { $null }
            if ($v) { $roots += $v }
        } catch {}
    }
    $libs = @()
    foreach ($root in ($roots | Select-Object -Unique)) {
        $libs += $root
        $lf = Join-Path $root 'steamapps\libraryfolders.vdf'
        if (Test-Path $lf) {
            foreach ($m in [regex]::Matches((Get-Content $lf -Raw), '"path"\s+"([^"]+)"')) {
                $libs += ($m.Groups[1].Value -replace '\\\\', '\')
            }
        }
    }
    foreach ($lib in ($libs | Select-Object -Unique)) {
        $g = Join-Path $lib 'steamapps\common\Anarcute'
        if (Test-Path (Join-Path $g 'anarcute.exe')) { return $g }
    }
    return $null
}

$GameDir = Find-Game $GameDir
if (-not $GameDir) { throw '找不到 Anarcute，请用 -GameDir 指定目录。' }

$assets = Join-Path (Join-Path $GameDir 'anarcute_Data') 'resources.assets'
$bak = "$assets.zhbak"
Get-Process anarcute -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1
if (-not (Test-Path $bak)) { throw "没有备份文件：$bak（可在 Steam 里对游戏执行“验证文件完整性”）" }
Copy-Item $bak $assets -Force
Write-Host '已还原 resources.assets'