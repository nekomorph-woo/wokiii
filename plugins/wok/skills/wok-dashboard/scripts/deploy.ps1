# deploy.ps1 - Deploy wok dashboard + start local HTTP server (PowerShell)
# Usage: deploy.ps1 <system-name> [-Restart]
#
# Multi-feature architecture: server binds .wok-plans/ parent directory,
# features accessed via URL path /<feature>/. Switching features does not
# require server restart — just deploy assets to the feature directory.

param(
    [Parameter(Position=0)][string]$SystemName,
    [switch]$Restart
)

$ErrorActionPreference = 'Stop'

if (-not $SystemName) {
    Write-Host "错误: 缺少系统名称" -ForegroundColor Red
    Write-Host "用法: deploy.ps1 <system-name> [-Restart]"
    exit 1
}

# ── Paths ──

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AssetsDir = Join-Path $ScriptDir '..\assets'
$gitRoot = git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -eq 0 -and $gitRoot) { $WokRoot = $gitRoot } else { $WokRoot = $PWD.Path }
$DashboardDir = Join-Path $HOME '.claude\wok-dashboard'
$WokDir = Join-Path $HOME '.claude\wok'
$ServerState = Join-Path $DashboardDir 'server.json'
$ServerScript = Join-Path $DashboardDir '_server.py'
$SystemDir = Join-Path $WokRoot ".wok-plans\$SystemName"

if (-not (Test-Path $SystemDir)) {
    Write-Host "错误: 系统目录不存在: $SystemDir" -ForegroundColor Red
    exit 1
}

# ── Python detection ──

$Python = 'python3'
if (-not (Get-Command $Python -ErrorAction SilentlyContinue)) {
    $Python = 'python'
}
if (-not (Get-Command $Python -ErrorAction SilentlyContinue)) {
    Write-Host "错误: 未找到 python3 或 python" -ForegroundColor Red
    exit 1
}

# ── 1. Deploy assets to feature directory ──

$ServerPort = 18730

New-Item -ItemType Directory -Force -Path $DashboardDir | Out-Null

Copy-Item -Force (Join-Path $AssetsDir 'dashboard.html') (Join-Path $SystemDir '_dashboard.html')
Copy-Item -Force (Join-Path $AssetsDir 'render.js') (Join-Path $SystemDir '_render.js')
Copy-Item -Force (Join-Path $AssetsDir 'style.css') (Join-Path $SystemDir '_style.css')
Copy-Item -Force (Join-Path $ScriptDir '_server.py') $ServerScript

# Replace {{SYSTEM_NAME}} template
$dashboardHtml = Join-Path $SystemDir '_dashboard.html'
$renderJs = Join-Path $SystemDir '_render.js'
(Get-Content $dashboardHtml -Raw -Encoding UTF8) -replace '\{\{SYSTEM_NAME\}\}', $SystemName | Set-Content $dashboardHtml -NoNewline -Encoding UTF8
(Get-Content $renderJs -Raw -Encoding UTF8) -replace '\{\{SYSTEM_NAME\}\}', $SystemName | Set-Content $renderJs -NoNewline -Encoding UTF8

Write-Host "✓ 三件套已部署到: $SystemDir"

# ── 1.5 Deploy shared tools to ~/.claude/wok/ ──

$resolveSrc = Join-Path $ScriptDir '..\..\scripts\resolve-system-name.sh'
$resolveDoc = Join-Path $ScriptDir '..\..\scripts\resolve-system-name.md'
if (Test-Path $resolveSrc) {
    New-Item -ItemType Directory -Force -Path $WokDir | Out-Null
    Copy-Item -Force $resolveSrc (Join-Path $WokDir 'resolve-system-name.sh')
    Copy-Item -Force $resolveDoc (Join-Path $WokDir 'resolve-system-name.md')
    Write-Host "✓ resolve-system-name 已部署到: $WokDir"
}

# ── 2. Server lifecycle management ──

$PlansDir = Join-Path $WokRoot '.wok-plans'

function Ensure-Server {
    param([bool]$ForceRestart)

    # Check existing server
    if (Test-Path $ServerState) {
        $state = Get-Content $ServerState | ConvertFrom-Json
        $oldPid = $state.pid
        $oldPort = $state.port

        $proc = Get-Process -Id $oldPid -ErrorAction SilentlyContinue
        if ($proc) {
            if (-not $ForceRestart) {
                Write-Host "✓ Server 已在运行: http://127.0.0.1:$oldPort"
                return
            }
            Stop-Process -Id $oldPid -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 500
        }
        Remove-Item -Force $ServerState
    }

    # Start server (binds .wok-plans/ parent directory)
    $port = $ServerPort
    $serverArgs = "`"$ServerScript`" --port $port --directory `"$PlansDir`""
    $procInfo = Start-Process -FilePath $Python -ArgumentList $serverArgs -WindowStyle Hidden -PassThru
    $serverPid = $procInfo.Id

    # Write state file
    @{pid = $serverPid; port = $port} | ConvertTo-Json | Set-Content $ServerState

    # Verify server started
    $verifyAttempts = 0
    while ($verifyAttempts -lt 10) {
        try {
            $null = Invoke-RestMethod -Uri "http://127.0.0.1:$port/$SystemName/api/files" -TimeoutSec 2
            Write-Host "✓ Server 已启动: http://127.0.0.1:$port"
            return
        } catch {
            Start-Sleep -Milliseconds 300
            $verifyAttempts++
        }
    }

    # Startup failed — cleanup
    Stop-Process -Id $serverPid -ErrorAction SilentlyContinue
    Remove-Item -Force $ServerState -ErrorAction SilentlyContinue
    Write-Host "错误: Server 启动失败（端口 $port）" -ForegroundColor Red
    exit 1
}

Ensure-Server -ForceRestart $Restart.IsPresent

Write-Host ""
Write-Host "Dashboard URL: http://127.0.0.1:$ServerPort/$SystemName/_dashboard.html"
