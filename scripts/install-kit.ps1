param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,
    [switch]$Force,
    [switch]$DryRun,
    [switch]$CreateOpenCodeConfig
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    Write-Error "TargetPath does not exist or is not a directory: $TargetPath"
    exit 1
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$kitRoot = Split-Path -Parent $scriptRoot

# Safe, reusable starter files only. Runtime files and secrets are intentionally excluded.
$relativeFiles = @(
    "AGENTS.md",
    ".env.example",
    ".gitignore",
    "README.md",
    ".codex/config.toml.example",
    "opencode.json.example",
    "mcp/database/README.md",
    "mcp/database/dbhub.local.example.toml",
    "mcp/database/dbhub.production-readonly.example.toml",
    "mcp/database/dbhub.multi-environment.example.toml",
    "agents/database-mcp/database-architect.md",
    "agents/database-mcp/database-safe-sql-reviewer.md",
    "agents/database-mcp/mcp-integration-reviewer.md",
    "skills/database-safe-sql/SKILL.md",
    "docs/AI_DATABASE_MCP_POLICY.md",
    "docs/DATABASE_MCP_SETUP_GUIDE.md",
    "docs/DATABASE_SAFE_SQL_WORKFLOW.md",
    "docs/DATABASE_MCP_PORTABILITY_GUIDE.md",
    "docs/INSTALLATION_CONFLICT_STRATEGY.md",
    "templates/gitignore-snippet.txt",
    "templates/opencode.json.example",
    "templates/claude-desktop-config.example.json",
    "templates/claude-skill-database-safe-sql/SKILL.md",
    ".opencode/agents/database-safe-sql-reviewer.md",
    ".opencode/agents/mcp-integration-reviewer.md",
    ".opencode/skills/database-safe-sql/SKILL.md",
    ".opencode/commands/validate-db-mcp.md",
    "scripts/start-dbhub-http.ps1",
    "scripts/start-dbhub.ps1",
    "scripts/install-kit.ps1"
)

$copied = New-Object System.Collections.Generic.List[string]
$skipped = New-Object System.Collections.Generic.List[string]
$missing = New-Object System.Collections.Generic.List[string]
$planned = New-Object System.Collections.Generic.List[string]

function Ensure-Directory {
    param([string]$DirectoryPath)

    if (Test-Path -LiteralPath $DirectoryPath -PathType Container) {
        return
    }

    if ($DryRun) {
        return
    }

    New-Item -ItemType Directory -Path $DirectoryPath -Force | Out-Null
}

foreach ($relative in $relativeFiles) {
    $source = Join-Path $kitRoot $relative
    $destination = Join-Path $TargetPath $relative

    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        $missing.Add($relative)
        continue
    }

    $destinationDir = Split-Path -Parent $destination
    Ensure-Directory -DirectoryPath $destinationDir

    if ((Test-Path -LiteralPath $destination -PathType Leaf) -and (-not $Force)) {
        $skipped.Add($relative)
        continue
    }

    if ($DryRun) {
        $planned.Add($relative)
        continue
    }

    Copy-Item -LiteralPath $source -Destination $destination -Force:$Force
    $copied.Add($relative)
}

if ($CreateOpenCodeConfig) {
    $source = Join-Path $kitRoot "opencode.json.example"
    $destination = Join-Path $TargetPath "opencode.json"

    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        $missing.Add("opencode.json.example")
    }
    elseif (Test-Path -LiteralPath $destination -PathType Leaf) {
        if (-not $Force) {
            $skipped.Add("opencode.json")
        }
        elseif ($DryRun) {
            $planned.Add("opencode.json")
        }
        else {
            Copy-Item -LiteralPath $source -Destination $destination -Force
            $copied.Add("opencode.json")
        }
    }
    elseif ($DryRun) {
        $planned.Add("opencode.json")
    }
    else {
        Copy-Item -LiteralPath $source -Destination $destination
        $copied.Add("opencode.json")
    }
}

Write-Output ""
Write-Output "Install Summary"
Write-Output "---------------"
Write-Output ("TargetPath: {0}" -f (Resolve-Path -LiteralPath $TargetPath))
Write-Output ("Force: {0}" -f [bool]$Force)
Write-Output ("DryRun: {0}" -f [bool]$DryRun)
Write-Output ("CreateOpenCodeConfig: {0}" -f [bool]$CreateOpenCodeConfig)
Write-Output ("Copied: {0}" -f $copied.Count)
Write-Output ("Planned (dry run): {0}" -f $planned.Count)
Write-Output ("Skipped (exists): {0}" -f $skipped.Count)
Write-Output ("Missing in kit: {0}" -f $missing.Count)

if ($copied.Count -gt 0) {
    Write-Output ""
    Write-Output "Copied files:"
    $copied | ForEach-Object { Write-Output (" - {0}" -f $_) }
}

if ($planned.Count -gt 0) {
    Write-Output ""
    Write-Output "Planned files (dry run):"
    $planned | ForEach-Object { Write-Output (" - {0}" -f $_) }
}

if ($skipped.Count -gt 0) {
    Write-Output ""
    Write-Output "Skipped files:"
    $skipped | ForEach-Object { Write-Output (" - {0}" -f $_) }
}

if ($missing.Count -gt 0) {
    Write-Output ""
    Write-Output "Missing files in starter:"
    $missing | Sort-Object -Unique | ForEach-Object { Write-Output (" - {0}" -f $_) }
}

Write-Output ""
Write-Output "No database connections were executed by this script."
Write-Output "No SQL was executed by this script."