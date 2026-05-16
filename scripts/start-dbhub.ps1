[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CliArgs
)

# Optional fallback launcher.
# HTTP local is recommended for Windows + Codex:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1
# STDIO may fail on some Windows environments due to handshake/startup timing.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Stderr {
    param([string]$Message)
    [Console]::Error.WriteLine($Message)
}

function Show-Help {
    Write-Stderr "Usage: start-dbhub.ps1 [--transport stdio|http] [--port <number>] [--help]"
    Write-Stderr "Loads .env and .env.local, validates local DB vars, then starts DBHub."
    Write-Stderr "Tip: Prefer HTTP transport on Windows + Codex if STDIO handshake fails."
}

function Parse-Args {
    param([string[]]$ArgsToParse)

    $options = @{
        Transport = "stdio"
        Port = 5678
        Help = $false
    }

    $i = 0
    while ($i -lt $ArgsToParse.Count) {
        $arg = $ArgsToParse[$i]
        switch ($arg) {
            "--help" { $options.Help = $true; $i += 1; continue }
            "-h" { $options.Help = $true; $i += 1; continue }
            "/?" { $options.Help = $true; $i += 1; continue }
            "--transport" {
                if ($i + 1 -ge $ArgsToParse.Count) {
                    throw "Missing value for --transport."
                }
                $value = $ArgsToParse[$i + 1]
                if ($value -ne "stdio" -and $value -ne "http") {
                    throw "Invalid --transport value '$value'. Use 'stdio' or 'http'."
                }
                $options.Transport = $value
                $i += 2
                continue
            }
            "--port" {
                if ($i + 1 -ge $ArgsToParse.Count) {
                    throw "Missing value for --port."
                }
                $rawPort = $ArgsToParse[$i + 1]
                $parsed = 0
                if (-not [int]::TryParse($rawPort, [ref]$parsed) -or $parsed -le 0) {
                    throw "Invalid --port value '$rawPort'. Use a positive integer."
                }
                $options.Port = $parsed
                $i += 2
                continue
            }
            default {
                throw "Unsupported argument '$arg'. Use --help for usage."
            }
        }
    }

    return $options
}

function Load-EnvFile {
    param([string]$EnvFilePath)

    if (-not (Test-Path -LiteralPath $EnvFilePath)) {
        return
    }

    foreach ($line in Get-Content -LiteralPath $EnvFilePath) {
        if ($null -eq $line) { continue }

        $trimmedLine = $line.Trim()
        if ($trimmedLine.Length -eq 0) { continue }
        if ($trimmedLine.StartsWith("#")) { continue }

        $separatorIndex = $trimmedLine.IndexOf("=")
        if ($separatorIndex -lt 1) { continue }

        $key = $trimmedLine.Substring(0, $separatorIndex).Trim()
        if ($key.StartsWith("export ")) {
            $key = $key.Substring(7).Trim()
        }
        if ([string]::IsNullOrWhiteSpace($key)) { continue }

        $value = $trimmedLine.Substring($separatorIndex + 1).Trim()
        if ($value.Length -ge 2) {
            $firstChar = $value[0]
            $lastChar = $value[$value.Length - 1]
            if (($firstChar -eq '"' -and $lastChar -eq '"') -or ($firstChar -eq "'" -and $lastChar -eq "'")) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }

        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

function Test-EnvGroup {
    param([string[]]$Names)

    foreach ($name in $Names) {
        $currentValue = [Environment]::GetEnvironmentVariable($name, "Process")
        if ([string]::IsNullOrWhiteSpace($currentValue)) {
            return $false
        }
    }

    return $true
}

try {
    $parsedOptions = Parse-Args -ArgsToParse $CliArgs
    if ($parsedOptions.Help) {
        Show-Help
        exit 0
    }

    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $projectRoot = Split-Path -Parent $scriptDirectory
    Set-Location -LiteralPath $projectRoot

    Load-EnvFile -EnvFilePath (Join-Path $projectRoot ".env")
    Load-EnvFile -EnvFilePath (Join-Path $projectRoot ".env.local")

    $postgresGroup = @(
        "LOCAL_POSTGRES_HOST",
        "LOCAL_POSTGRES_PORT",
        "LOCAL_POSTGRES_DB",
        "LOCAL_POSTGRES_USER",
        "LOCAL_POSTGRES_PASSWORD"
    )

    $mysqlGroup = @(
        "LOCAL_MYSQL_HOST",
        "LOCAL_MYSQL_PORT",
        "LOCAL_MYSQL_DB",
        "LOCAL_MYSQL_USER",
        "LOCAL_MYSQL_PASSWORD"
    )

    $hasPostgres = Test-EnvGroup -Names $postgresGroup
    $hasMySql = Test-EnvGroup -Names $mysqlGroup

    if (-not ($hasPostgres -or $hasMySql)) {
        Write-Stderr "Missing required local database environment variables."
        Write-Stderr "Provide a complete LOCAL_POSTGRES_* or LOCAL_MYSQL_* group in .env/.env.local."
        exit 1
    }

    $dbhubArgs = @(
        "-y",
        "@bytebase/dbhub@latest",
        "--transport",
        $parsedOptions.Transport,
        "--config",
        "mcp/database/dbhub.local.toml"
    )

    if ($parsedOptions.Transport -eq "http") {
        $dbhubArgs += @("--port", [string]$parsedOptions.Port)
    }

    & npx $dbhubArgs
    exit $LASTEXITCODE
}
catch {
    Write-Stderr $_.Exception.Message
    exit 1
}