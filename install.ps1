param(
    [string]$GameDir = ''
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$appId = '390720'
$patch = Join-Path $here 'resources.assets'
if (-not (Test-Path $patch)) { throw "补丁文件缺失：$patch" }
$patchLen = (Get-Item $patch).Length

function Get-SteamLibraryRoots {
    $roots = @()
    foreach ($reg in @('HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam')) {
        try {
            $p = Get-ItemProperty $reg -ErrorAction Stop
            $v = if ($p.SteamPath) { $p.SteamPath } elseif ($p.InstallPath) { $p.InstallPath } else { $null }
            if ($v -and (Test-Path $v)) { $roots += $v }
        } catch {}
    }
    $out = @()
    foreach ($root in ($roots | Select-Object -Unique)) {
        $out += $root
        $lf = Join-Path $root 'steamapps\libraryfolders.vdf'
        if (Test-Path $lf) {
            $txt = Get-Content $lf -Raw
            foreach ($m in [regex]::Matches($txt, '"path"\s+"([^"]+)"')) {
                $out += ($m.Groups[1].Value -replace '\\\\', '\')
            }
        }
    }
    # 去重（大小写不敏感）
    $seen = @{}
    $uniq = @()
    foreach ($r in $out) {
        if (-not $r) { continue }
        $k = $r.TrimEnd('\').ToLower()
        if (-not $seen.ContainsKey($k)) { $seen[$k] = 1; $uniq += $r.TrimEnd('\') }
    }
    return $uniq
}

function Find-AnarcuteDirs {
    $libs = @(Get-SteamLibraryRoots)
    $found = @()
    foreach ($lib in $libs) {
        $g = Join-Path $lib 'steamapps\common\Anarcute'
        if (Test-Path (Join-Path $g 'anarcute.exe')) { $found += $g }
    }
    return $found
}

function Find-AppManifest([string]$game) {
    $steamapps = Split-Path -Parent (Split-Path -Parent $game)   # <lib>\steamapps
    $acf = Join-Path $steamapps "appmanifest_$appId.acf"
    if (Test-Path $acf) { return $acf }
    return $null
}

if (-not $GameDir) {
    $all = @(Find-AnarcuteDirs)
    if ($all.Count -eq 0) { throw '没有在 Steam 库里找到 Anarcute。请先安装游戏，或用 -GameDir 指定目录。' }
    $GameDir = $all[0]
    Write-Host "自动找到游戏目录：$GameDir"
} else {
    Write-Host "使用指定目录：$GameDir"
}

$data = Join-Path $GameDir 'anarcute_Data'
$assets = Join-Path $data 'resources.assets'
if (-not (Test-Path $assets)) { throw "找不到游戏文件：$assets" }

Write-Host '关闭游戏和 Steam ...'
Get-Process anarcute -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

$bak = "$assets.zhbak"
if (-not (Test-Path $bak)) {
    if ((Get-Item $assets).Length -eq $patchLen) {
        Write-Host '当前已是补丁版且没有原始备份：跳过备份（卸载请用 Steam 验证文件完整性）。'
    } else {
        Copy-Item $assets $bak
        Write-Host "已备份原始文件 -> $bak"
    }
} else {
    Write-Host "已有备份，保留：$bak"
}

Copy-Item $patch $assets -Force
if ((Get-Item $assets).Length -ne $patchLen) { throw '复制校验失败' }
Write-Host ("已安装 resources.assets（{0:N1} MB）" -f ($patchLen / 1MB))

$acf = Find-AppManifest $GameDir
if ($acf) {
    $text = Get-Content $acf -Raw
    $new = $text -replace '"language"\s+"english"', '"language"		"schinese"'
    if ($new -ne $text) {
        [System.IO.File]::WriteAllText($acf, $new, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host '已把 appmanifest 的语言从 english 改为 schinese'
    } else {
        Write-Host 'appmanifest 语言已是 schinese，无需修改'
    }
} else {
    Write-Host '未找到 appmanifest；如游戏仍为英文，请在 Steam 属性里把语言改成简体中文。'
}

Write-Host ''
Write-Host '安装完成。请先启动 Steam，再启动游戏。'