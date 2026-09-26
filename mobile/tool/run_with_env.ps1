# Reads mobile/.env (or .env.local) and runs Flutter with --dart-define flags.
# Matches the existing HF_TOKEN String.fromEnvironment pattern — no extra packages.
#
# Usage (from mobile/):
#   .\tool\run_with_env.ps1
#   .\tool\run_with_env.ps1 -DeviceId emulator-5554
#   .\tool\run_with_env.ps1 -- --release

param(
    [string]$EnvFile = "",
    [string]$DeviceId = "",
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

$ErrorActionPreference = "Stop"
$mobileRoot = Split-Path -Parent $PSScriptRoot
Set-Location $mobileRoot

if (-not $EnvFile) {
    if (Test-Path (Join-Path $mobileRoot ".env.local")) {
        $EnvFile = Join-Path $mobileRoot ".env.local"
    } elseif (Test-Path (Join-Path $mobileRoot ".env")) {
        $EnvFile = Join-Path $mobileRoot ".env"
    } else {
        Write-Error "No .env or .env.local found in $mobileRoot. Copy .env.example to .env and fill placeholders."
    }
}

if (-not (Test-Path $EnvFile)) {
    Write-Error "Env file not found: $EnvFile"
}

$defines = @()
Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith("#")) { return }
    $eq = $line.IndexOf("=")
    if ($eq -lt 1) { return }
    $key = $line.Substring(0, $eq).Trim()
    $value = $line.Substring($eq + 1).Trim().Trim('"').Trim("'")
    if ($value) {
        $defines += "--dart-define=$key=$value"
    }
}

$cmd = @("flutter", "run") + $defines
if ($DeviceId) { $cmd += @("-d", $DeviceId) }
if ($FlutterArgs) { $cmd += $FlutterArgs }

Write-Host "Running (secrets not printed): flutter run + $($defines.Count) dart-define(s)"
& $cmd[0] $cmd[1..($cmd.Length - 1)]
