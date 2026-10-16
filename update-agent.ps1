# update-agent.ps1 - Antigravity Agent Framework Rule Sync & Upgrade Tool
[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$TargetDir = (Get-Location).Path,

    [string]$RepoUrl = "https://github.com/mlgbz523/agent-framework-v2.git",
    [switch]$Check = $false,
    [switch]$Apply = $false,
    [switch]$Json = $false,
    [string[]]$Files = @(),
    [switch]$Offline = $false,
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ResolvedTarget = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetDir)
if (!(Test-Path $ResolvedTarget)) {
    if ($Json) {
        $errObj = @{ success = $false; error = "Target directory does not exist: $ResolvedTarget" }
        $errObj | ConvertTo-Json -Compress
    } else {
        Write-Error "Target directory does not exist: $ResolvedTarget"
    }
    exit 1
}

function Get-FileSha256([string]$filePath) {
    if (!(Test-Path $filePath)) { return "" }
    $h = Get-FileHash -Path $filePath -Algorithm SHA256
    return $h.Hash
}

function Get-DiffInfo([string]$oldPath, [string]$newPath) {
    if (!(Test-Path $oldPath) -or !(Test-Path $newPath)) {
        return @{ added = 0; deleted = 0; snippet = "" }
    }
    $oldContent = Get-Content -Path $oldPath -Encoding UTF8
    $newContent = Get-Content -Path $newPath -Encoding UTF8

    $diff = Compare-Object -ReferenceObject $oldContent -DifferenceObject $newContent
    if (!$diff) {
        return @{ added = 0; deleted = 0; snippet = "" }
    }

    $addCount = @($diff | Where-Object { $_.SideIndicator -eq "=>" }).Count
    $delCount = @($diff | Where-Object { $_.SideIndicator -eq "<=" }).Count

    $lines = New-Object System.Collections.Generic.List[string]
    $count = 0
    foreach ($item in $diff) {
        if ($count -ge 20) {
            $lines.Add("... (diff truncated)")
            break
        }
        $prefix = if ($item.SideIndicator -eq "=>") { "+ " } else { "- " }
        $lines.Add($prefix + $item.InputObject)
        $count++
    }

    return @{
        added = $addCount
        deleted = $delCount
        snippet = ($lines -join "`n")
    }
}

$SourceDir = $null
$TempDir = $null

try {
    # 1. Fetch from remote repo if not offline
    if ($RepoUrl -and (!$Offline)) {
        $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("agent-update-" + [System.Guid]::NewGuid().ToString("N"))
        try {
            & git clone --depth 1 $RepoUrl $TempDir 2>&1 | Out-Null
            $remoteAgentsMd = Join-Path $TempDir "AGENTS.md"
            $remoteAgentsDir = Join-Path $TempDir ".agents"
            if ($LASTEXITCODE -eq 0 -and (Test-Path $remoteAgentsMd) -and (Test-Path $remoteAgentsDir)) {
                $SourceDir = $TempDir
            } else {
                if ($TempDir -and (Test-Path $TempDir)) {
                    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
                    $TempDir = $null
                }
            }
        } catch {
            if ($TempDir -and (Test-Path $TempDir)) {
                Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
                $TempDir = $null
            }
        }
    }

    # 2. Fallback to local template cache
    if (!$SourceDir) {
        $CandidatePaths = @(
            (Join-Path $env:USERPROFILE ".gemini\config\templates\agent-framework-v2"),
            "C:\Users\15770\.gemini\config\templates\agent-framework-v2",
            "D:\Downloads\新建文件夹 (4)\agent-framework-v2"
        )
        foreach ($cand in $CandidatePaths) {
            if ($cand -and (Test-Path (Join-Path $cand "AGENTS.md")) -and (Test-Path (Join-Path $cand ".agents"))) {
                $SourceDir = $cand
                break
            }
        }
    }

    if (!$SourceDir) {
        $msg = "Unable to locate template source (remote clone failed and no local cache found)."
        if ($Json) {
            @{ success = $false; error = $msg } | ConvertTo-Json -Compress
        } else {
            Write-Error $msg
        }
        exit 1
    }

    # 3. Collect managed files from source template
    $managedFiles = New-Object System.Collections.Generic.List[string]
    $managedFiles.Add("AGENTS.md")

    $srcAgents = Join-Path $SourceDir ".agents"
    if (Test-Path $srcAgents) {
        Get-ChildItem -Path $srcAgents -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($SourceDir.Length).TrimStart("\", "/").Replace("\", "/")
            # 保护本地配置文件不被随意冲刷
            if ($rel -ne ".agents/mcp_config.json") {
                $managedFiles.Add($rel)
            }
        }
    }

    # Identify custom local files that should be protected
    $customProtected = New-Object System.Collections.Generic.List[string]
    $tgtAgents = Join-Path $ResolvedTarget ".agents"
    if (Test-Path $tgtAgents) {
        Get-ChildItem -Path $tgtAgents -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($ResolvedTarget.Length).TrimStart("\", "/").Replace("\", "/")
            if ($rel -notlike ".agents/.backup*" -and $rel -notlike "*/.backup*") {
                $srcCheck = Join-Path $SourceDir $rel
                if (!(Test-Path $srcCheck)) {
                    $customProtected.Add($rel)
                }
            }
        }
    }

    # 4. Compare files
    $changeList = New-Object System.Collections.Generic.List[PSObject]
    $unchangedCount = 0

    foreach ($relPath in $managedFiles) {
        $srcPath = Join-Path $SourceDir $relPath
        $tgtPath = Join-Path $ResolvedTarget $relPath

        if (!(Test-Path $tgtPath)) {
            $lines = Get-Content -Path $srcPath -Encoding UTF8 -ErrorAction SilentlyContinue
            $preview = ""
            if ($lines) {
                if ($lines.Count -gt 10) {
                    $preview = ($lines[0..9] -join "`n") + "`n... (truncated)"
                } else {
                    $preview = $lines -join "`n"
                }
            }
            $changeList.Add([PSCustomObject]@{
                file = $relPath
                status = "added"
                diff_summary = "+$($lines.Count) lines"
                diff_snippet = $preview
                source_path = $srcPath
                target_path = $tgtPath
            })
        } else {
            $srcHash = Get-FileSha256 $srcPath
            $tgtHash = Get-FileSha256 $tgtPath

            if ($srcHash -ne $tgtHash) {
                $diff = Get-DiffInfo -oldPath $tgtPath -newPath $srcPath
                $changeList.Add([PSCustomObject]@{
                    file = $relPath
                    status = "modified"
                    diff_summary = "+$($diff.added), -$($diff.deleted) lines"
                    diff_snippet = $diff.snippet
                    source_path = $srcPath
                    target_path = $tgtPath
                })
            } else {
                $unchangedCount++
            }
        }
    }

    $hasChanges = ($changeList.Count -gt 0)
    $modifiedCount = @($changeList | Where-Object { $_.status -eq "modified" }).Count
    $addedCount = @($changeList | Where-Object { $_.status -eq "added" }).Count

    # 5. Apply Mode
    if ($Apply) {
        if (!$hasChanges) {
            if ($Json) {
                @{ success = $true; message = "All rules are up to date."; updated_count = 0 } | ConvertTo-Json -Compress
            } else {
                Write-Host "[OK] All rules are already up to date." -ForegroundColor Green
            }
            exit 0
        }

        $applyTargets = $changeList
        if ($Files -and $Files.Count -gt 0) {
            $applyTargets = $changeList | Where-Object {
                $targetFile = $_.file
                $Files | Where-Object { $targetFile -like "*$_*" }
            }
        }

        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupDir = Join-Path $ResolvedTarget (".agents\.backup_" + $timestamp)
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

        $updatedFiles = New-Object System.Collections.Generic.List[string]

        foreach ($item in $applyTargets) {
            $dest = $item.target_path
            $parent = Split-Path -Path $dest -Parent
            if (!(Test-Path $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }

            if (Test-Path $dest) {
                $bDest = Join-Path $backupDir $item.file
                $bParent = Split-Path -Path $bDest -Parent
                if (!(Test-Path $bParent)) { New-Item -ItemType Directory -Path $bParent -Force | Out-Null }
                Copy-Item -Path $dest -Destination $bDest -Force
            }

            Copy-Item -Path $item.source_path -Destination $dest -Force
            $updatedFiles.Add($item.file)
        }

        if ($Json) {
            [PSCustomObject]@{
                success = $true
                backup_path = $backupDir
                updated_count = $updatedFiles.Count
                updated_files = $updatedFiles
                restore_hint = "To roll back, restore files from $backupDir"
            } | ConvertTo-Json -Depth 3
            exit 0
        } else {
            Write-Host "[OK] Updated $($updatedFiles.Count) files successfully." -ForegroundColor Green
            Write-Host "[*] Safe snapshot backed up to: $backupDir" -ForegroundColor Cyan
            exit 0
        }
    }

    # 6. Check or Json Diagnostic Mode
    if ($Check -or $Json) {
        $result = [PSCustomObject]@{
            success = $true
            has_changes = $hasChanges
            source_used = $SourceDir
            summary = [PSCustomObject]@{
                modified = $modifiedCount
                added = $addedCount
                unchanged = $unchangedCount
                custom_protected = $customProtected.Count
            }
            changes = $changeList
            custom_files = $customProtected
        }

        if ($Json) {
            $result | ConvertTo-Json -Depth 5
            exit 0
        }

        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "  Antigravity Framework Update Diagnostic" -ForegroundColor Cyan
        Write-Host "  Source: $SourceDir" -ForegroundColor Yellow
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "Modified: $modifiedCount | Added: $addedCount | Unchanged: $unchangedCount | Protected: $($customProtected.Count)" -ForegroundColor Green

        foreach ($c in $changeList) {
            $col = if ($c.status -eq "added") { "Green" } else { "Yellow" }
            Write-Host "[$($c.status.ToUpper())] $($c.file) ($($c.diff_summary))" -ForegroundColor $col
        }
        exit 0
    }

    # 7. Interactive CLI Mode
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  Antigravity Framework Rule Sync & Upgrade" -ForegroundColor Cyan
    Write-Host "  Workspace: $ResolvedTarget" -ForegroundColor Yellow
    Write-Host "  Template Source: $SourceDir" -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan

    if (!$hasChanges) {
        Write-Host "[OK] All local rules are already up to date." -ForegroundColor Green
        exit 0
    }

    Write-Host "`n[Diagnostic Summary] Modified: $modifiedCount | Added: $addedCount | Unchanged: $unchangedCount | Protected: $($customProtected.Count)" -ForegroundColor White
    Write-Host "`nChange list:"
    foreach ($c in $changeList) {
        $col = if ($c.status -eq "added") { "Green" } else { "Yellow" }
        Write-Host "  [$($c.status.ToUpper())] $($c.file) ($($c.diff_summary))" -ForegroundColor $col
    }

    if ($customProtected.Count -gt 0) {
        Write-Host "`nProtected custom local files (will NOT be touched):" -ForegroundColor DarkGray
        foreach ($cp in $customProtected) {
            Write-Host "  [PROTECTED] $cp" -ForegroundColor DarkGray
        }
    }

    Write-Host "`nPlease choose action:" -ForegroundColor Cyan
    Write-Host "  [1] Show line-by-line diffs (Diff)"
    Write-Host "  [2] Update all changes immediately (All - with auto-backup)"
    Write-Host "  [3] Review files interactively (Interactive)"
    Write-Host "  [Q] Cancel (Quit)"

    $choice = Read-Host "`nEnter option [1/2/3/Q]"

    switch ($choice) {
        "1" {
            foreach ($c in $changeList) {
                Write-Host "`n----------------------------------------" -ForegroundColor DarkCyan
                Write-Host "File: $($c.file) ($($c.status))" -ForegroundColor Yellow
                Write-Host "----------------------------------------" -ForegroundColor DarkCyan
                Write-Host $c.diff_snippet
            }
            Write-Host "`nDiff review completed. Run update-agent.cmd again to apply." -ForegroundColor Cyan
        }
        "2" {
            & $PSCommandPath -TargetDir $ResolvedTarget -Apply
        }
        "3" {
            $confirmed = New-Object System.Collections.Generic.List[string]
            foreach ($c in $changeList) {
                Write-Host "`n[$($c.status.ToUpper())] $($c.file) ($($c.diff_summary))" -ForegroundColor Yellow
                $ans = Read-Host "Update this file? [Y/N/D (view diff)]"
                if ($ans -eq "D" -or $ans -eq "d") {
                    Write-Host $c.diff_snippet -ForegroundColor DarkCyan
                    $ans = Read-Host "Confirm update for this file? [Y/N]"
                }
                if ($ans -eq "Y" -or $ans -eq "y") {
                    $confirmed.Add($c.file)
                }
            }
            if ($confirmed.Count -gt 0) {
                & $PSCommandPath -TargetDir $ResolvedTarget -Apply -Files $confirmed
            } else {
                Write-Host "No files selected. Operation cancelled." -ForegroundColor Gray
            }
        }
        Default {
            Write-Host "Operation cancelled. No changes made." -ForegroundColor Gray
        }
    }

} finally {
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
