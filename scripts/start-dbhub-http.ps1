[CmdletBinding()]
param(
    [string]$Config = "mcp/database/dbhub.local.toml",
    [ValidateRange(1, 65535)]
    [int]$Port = 5678,
    [string]$HostAddress = "localhost",
    [string]$Profile
)

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

function Resolve-AbsolutePath {
    param(
        [string]$Path,
        [string]$BaseDirectory
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $Path))
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

function Get-RequiredVariablesFromToml {
    param([string]$TomlPath)

    $content = Get-Content -LiteralPath $TomlPath -Raw
    $regex = [regex]'\$\{([A-Za-z0-9_]+)\}'
    $found = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::Ordinal)

    foreach ($match in $regex.Matches($content)) {
        $varName = $match.Groups[1].Value
        if (-not [string]::IsNullOrWhiteSpace($varName)) {
            [void]$found.Add($varName)
        }
    }

    $result = @($found)
    [Array]::Sort($result, [System.StringComparer]::Ordinal)
    return $result
}

try {
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $projectRoot = Split-Path -Parent $scriptDirectory
    Set-Location -LiteralPath $projectRoot

    Write-Info ("Project root: " + $projectRoot)

    Load-EnvFile -EnvFilePath (Join-Path $projectRoot ".env")
    Load-EnvFile -EnvFilePath (Join-Path $projectRoot ".env.local")

    $resolvedConfigPath = Resolve-AbsolutePath -Path $Config -BaseDirectory $projectRoot
    if (-not (Test-Path -LiteralPath $resolvedConfigPath -PathType Leaf)) {
        Write-ErrorLine ("Config file not found: " + $resolvedConfigPath)
        exit 1
    }

    $requiredVariables = Get-RequiredVariablesFromToml -TomlPath $resolvedConfigPath
    $missingVariables = New-Object "System.Collections.Generic.List[string]"

    foreach ($name in $requiredVariables) {
        $currentValue = [Environment]::GetEnvironmentVariable($name, "Process")
        if ([string]::IsNullOrWhiteSpace($currentValue)) {
            $missingVariables.Add($name)
        }
    }

    if ($missingVariables.Count -gt 0) {
        Write-ErrorLine "Missing required environment variables referenced by the selected config:"
        foreach ($name in $missingVariables) {
            Write-ErrorLine (" - " + $name)
        }
        exit 1
    }

    $profileText = if ([string]::IsNullOrWhiteSpace($Profile)) { "default" } else { $Profile }
    $configDisplayPath = $resolvedConfigPath
    $localhostEndpoint = "http://localhost:{0}/mcp" -f $Port
    $selectedEndpoint = "http://{0}:{1}/mcp" -f $HostAddress, $Port

    Write-Info ("DBHub profile: " + $profileText)
    Write-Info ("Selected config: " + $configDisplayPath)
    Write-Info ("Selected port: " + $Port)
    Write-Info ("Expected endpoint: " + $localhostEndpoint)
    if ($HostAddress -ne "localhost") {
        Write-Info ("Selected host address endpoint: " + $selectedEndpoint)
    }
    if ($requiredVariables.Count -eq 0) {
        Write-Info 'No ${VAR_NAME} placeholders found in selected config; variable validation skipped.'
    }
    Write-Info "HostAddress is used for endpoint guidance. DBHub host binding follows DBHub defaults."
    Write-Info "Keep this terminal open while using MCP clients. Press Ctrl+C to stop."

    & npx -y @bytebase/dbhub@latest --transport http --port $Port --config $resolvedConfigPath
    exit $LASTEXITCODE
}
catch {
    Write-ErrorLine $_.Exception.Message
    exit 1
}
