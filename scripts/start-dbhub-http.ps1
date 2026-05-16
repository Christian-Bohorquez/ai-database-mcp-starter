[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host $Message
}

function Write-ErrorLine {
    param([string]$Message)
    [Console]::Error.WriteLine($Message)
}

function Load-EnvFile {
    param([string]$EnvFilePath)

    if (-not (Test-Path -LiteralPath $EnvFilePath)) {
        return
    }

    Write-Info ("Loading environment from " + (Split-Path -Leaf $EnvFilePath))

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
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $projectRoot = Split-Path -Parent $scriptDirectory
    Set-Location -LiteralPath $projectRoot

    Write-Info ("Project root: " + $projectRoot)

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
        Write-ErrorLine "Missing required local database environment variables."
        Write-ErrorLine "Provide a complete LOCAL_POSTGRES_* or LOCAL_MYSQL_* group in .env/.env.local."
        exit 1
    }

    if (-not $hasPostgres) {
        Write-Info "LOCAL_POSTGRES_* group is incomplete; PostgreSQL source may be unavailable."
    }
    if (-not $hasMySql) {
        Write-Info "LOCAL_MYSQL_* group is incomplete; MySQL/MariaDB sources may be unavailable."
    }

    Write-Info "Starting DBHub MCP over HTTP at http://localhost:5678/mcp"
    Write-Info "Keep this terminal open while using MCP clients. Press Ctrl+C to stop."

    & npx -y @bytebase/dbhub@latest --transport http --port 5678 --config mcp/database/dbhub.local.toml
    exit $LASTEXITCODE
}
catch {
    Write-ErrorLine $_.Exception.Message
    exit 1
}