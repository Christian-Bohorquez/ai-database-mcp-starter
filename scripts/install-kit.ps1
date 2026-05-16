param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    Write-Error "TargetPath does not exist or is not a directory: $TargetPath"
    exit 1
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$kitRoot = Split-Path -Parent $scriptRoot

# Safe, reusable starter files only. Runtime files are intentionally excluded.
$relativeFiles = @(
    ".env.example",
    ".gitignore",
    "README.md",
    ".codex/config.toml.example",
    "mcp/database/README.md",
    "mcp/database/dbhub.local.example.toml",
    "mcp/database/dbhub.production-readonly.example.toml",
    "mcp/database/dbhub.multi-environment.example.toml",
    "agents/database-architect.md",
    "agents/database-safe-sql-reviewer.md",
    "agents/mcp-integration-reviewer.md",
    "skills/database-safe-sql/SKILL.md",
    "docs/AI_DATABASE_MCP_POLICY.md",
    "docs/DATABASE_MCP_SETUP_GUIDE.md",
    "docs/DATABASE_SAFE_SQL_WORKFLOW.md",
    "docs/DATABASE_MCP_PORTABILITY_GUIDE.md",
    "templates/gitignore-snippet.txt",
    "templates/opencode.json.example",
    "templates/claude-desktop-config.example.json",
    "scripts/install-kit.ps1"
)

$copied = New-Object System.Collections.Generic.List[string]
$skipped = New-Object System.Collections.Generic.List[string]
$missing = New-Object System.Collections.Generic.List[string]

foreach ($relative in $relativeFiles) {
    $source = Join-Path $kitRoot $relative
    $destination = Join-Path $TargetPath $relative

    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        $missing.Add($relative)
        continue
    }

    $destinationDir = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $destinationDir -PathType Container)) {
        New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    }

    if ((Test-Path -LiteralPath $destination -PathType Leaf) -and (-not $Force)) {
        $skipped.Add($relative)
        continue
    }

    Copy-Item -LiteralPath $source -Destination $destination -Force:$Force
    $copied.Add($relative)
}

Write-Output ""
Write-Output "Install Summary"
Write-Output "---------------"
Write-Output ("TargetPath: {0}" -f (Resolve-Path -LiteralPath $TargetPath))
Write-Output ("Force: {0}" -f [bool]$Force)
Write-Output ("Copied: {0}" -f $copied.Count)
Write-Output ("Skipped (exists): {0}" -f $skipped.Count)
Write-Output ("Missing in kit: {0}" -f $missing.Count)

if ($copied.Count -gt 0) {
    Write-Output ""
    Write-Output "Copied files:"
    $copied | ForEach-Object { Write-Output (" - {0}" -f $_) }
}

if ($skipped.Count -gt 0) {
    Write-Output ""
    Write-Output "Skipped files:"
    $skipped | ForEach-Object { Write-Output (" - {0}" -f $_) }
}

if ($missing.Count -gt 0) {
    Write-Output ""
    Write-Output "Missing files in starter:"
    $missing | ForEach-Object { Write-Output (" - {0}" -f $_) }
}

Write-Output ""
Write-Output "No database connections were executed by this script."
