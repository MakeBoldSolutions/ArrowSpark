#!/usr/bin/env pwsh
# BSW.DevSpark - (c) 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com

param(
    [string]$RepoRoot = '',
    [string]$Output = '',
    [string]$GeneratedAt = '',
    [switch]$Stdout
)

. (Join-Path $PSScriptRoot 'common.ps1')

if (-not $RepoRoot) { $RepoRoot = Get-RepoRoot }
$engine = Join-Path $PSScriptRoot '../build_knowledge_index.py'
$arguments = @($engine, '--repo-root', $RepoRoot)
if ($Output) { $arguments += @('--output', $Output) }
if ($GeneratedAt) { $arguments += @('--generated-at', $GeneratedAt) }
if ($Stdout) { $arguments += '--stdout' }

& python @arguments
exit $LASTEXITCODE
