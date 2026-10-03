#!/usr/bin/env pwsh
# BSW.DevSpark - (c) 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com
# Next-step router context script.
# Detects the current lifecycle state locally (git + filesystem, best-effort gh)
# and recommends the single next DevSpark command to run.

param(
    [Parameter(Position = 0, ValueFromRemainingArguments)]
    [string[]]$Arguments,
    [switch]$Json
)

. (Join-Path $PSScriptRoot 'common.ps1')

$repoRoot = Get-RepoRoot
$hasGit = [bool](Test-HasGit)
$currentBranch = Get-CurrentBranch
$assistantName = Get-AssistantName
$gitUser = Get-GitUser

# Orientation facts ("where am I"): repo name + host platform, from config or remote.
$devsparkConfig = Get-DevSparkConfig
if ($devsparkConfig -and $devsparkConfig.repository) { $repoName = "$($devsparkConfig.repository)" } else { $repoName = Split-Path $repoRoot -Leaf }
if ($devsparkConfig -and $devsparkConfig.platform) {
    $platform = "$($devsparkConfig.platform)"
} else {
    $platform = 'unknown'
    if ($hasGit) {
        try {
            $remoteUrl = git remote get-url origin 2>$null
            if ($remoteUrl -match 'dev\.azure\.com|visualstudio\.com') { $platform = 'azdo' }
            elseif ($remoteUrl -match 'github\.com') { $platform = 'github' }
            elseif ($remoteUrl -match 'gitlab') { $platform = 'gitlab' }
        } catch { $platform = 'unknown' }
    }
}

# Constitution
$constitutionPath = Join-Path $repoRoot ".knowledge/governance/constitution.md"
$constitutionExists = Test-Path $constitutionPath

# Default (target) branch detection
$defaultBranch = "main"
if ($hasGit) {
    try {
        $head = git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>$null
        if ($head) {
            $defaultBranch = ($head -replace '^origin/', '')
        }
        else {
            git show-ref --verify --quiet refs/heads/master 2>$null
            if ($LASTEXITCODE -eq 0) { $defaultBranch = "master" }
        }
    } catch { $defaultBranch = "main" }
}
$isDefaultBranch = ($currentBranch -eq $defaultBranch -or $currentBranch -eq "main" -or $currentBranch -eq "master")

# Git state
$dirty = $false
$hasRemote = $false
$branchPushed = $false
$behindTarget = $false
if ($hasGit) {
    try { $dirty = [bool]((git status --porcelain 2>$null) | Where-Object { $_ }) } catch { $dirty = $false }
    try { $hasRemote = [bool]((git remote 2>$null) | Where-Object { $_ -and $_.Trim() }) } catch { $hasRemote = $false }
    if ($hasRemote) {
        try {
            git rev-parse --verify --quiet "refs/remotes/origin/$currentBranch" 2>$null | Out-Null
            $branchPushed = ($LASTEXITCODE -eq 0)
        } catch { $branchPushed = $false }
        try {
            $behindCount = git rev-list --count "HEAD..origin/$defaultBranch" 2>$null
            $behindTarget = ($behindCount -and [int]$behindCount -gt 0)
        } catch { $behindTarget = $false }
    }
}

# Spec / quickfix detection for the current branch
$specDir = Join-Path $repoRoot (".devspark.work/specs/" + $currentBranch)
$specExists = Test-Path (Join-Path $specDir "spec.md")

# Spec authoring sub-state (plan -> tasks -> analyze -> critic -> implement -> verify)
$planExists = $false
$tasksExists = $false
$tasksTotal = 0
$tasksDone = 0
$tasksComplete = $false
$classification = ""
$specStatus = ""
$isFullSpec = $false
$requireAnalyze = $false
$requireCritic = $false
$requireChecklist = $false
$analyzeGate = $false
$criticGate = $false
$checklistGate = $false
$verifyRequired = $false
$verifyPassed = $false
$closeoutDecision = ""
if ($specExists) {
    $planExists = Test-Path (Join-Path $specDir "plan.md")
    $tasksPath = Join-Path $specDir "tasks.md"
    $tasksExists = Test-Path $tasksPath
    if ($tasksExists) {
        try {
            $tasksText = Get-Content $tasksPath -Raw -ErrorAction SilentlyContinue
            $tasksTotal = ([regex]::Matches($tasksText, '(?m)^\s*[-*]\s*\[[ xX]\]')).Count
            $tasksDone = ([regex]::Matches($tasksText, '(?m)^\s*[-*]\s*\[[xX]\]')).Count
            $tasksComplete = ($tasksTotal -gt 0 -and $tasksDone -ge $tasksTotal)
        } catch { $tasksComplete = $false }
    }
    try {
        $specText = Get-Content (Join-Path $specDir "spec.md") -Raw -ErrorAction SilentlyContinue
        if ($specText -match '(?m)^classification:\s*(.+)$') { $classification = $matches[1].Trim() }
        if ($specText -match '(?m)^\*\*Status\*\*:\s*([^<\r\n]+)') { $specStatus = $matches[1].Trim() }
        $reqGates = ""
        if ($specText -match '(?m)^required_gates:\s*(.+)$') { $reqGates = $matches[1] }
        if ($reqGates -match 'verify:') { $verifyRequired = $true }
        if ($reqGates -match 'analyze') { $requireAnalyze = $true }
        if ($reqGates -match 'critic') { $requireCritic = $true }
        if ($reqGates -match 'checklist') { $requireChecklist = $true }
    } catch { }
    $isFullSpec = ($classification -match 'full-spec') -or ($classification -eq '' -and ($planExists -or $tasksExists))
    $analyzeGate = Test-Path (Join-Path $specDir "gates/analyze.md")
    $criticGate = Test-Path (Join-Path $specDir "gates/critic.md")
    $checklistGate = Test-Path (Join-Path $specDir "gates/checklist.md")
    $verifyGate = Join-Path $specDir "gates/verify.md"
    if (Test-Path $verifyGate) {
        try {
            $vt = Get-Content $verifyGate -Raw -ErrorAction SilentlyContinue
            if ($vt -match '(?m)^status:\s*pass') { $verifyPassed = $true }
        } catch { $verifyPassed = $false }
    }
    $closeoutGate = Join-Path $specDir "gates/closeout.md"
    if (Test-Path $closeoutGate) {
        try {
            $ct = Get-Content $closeoutGate -Raw -ErrorAction SilentlyContinue
            if ($ct -match '(?m)^decision:\s*(\S+)') { $closeoutDecision = $matches[1].Trim() }
        } catch { $closeoutDecision = "" }
    }
}

# Advisory gates that are required but whose artifact is missing/unmet (never block progress)
$pendingGates = @()
if ($specExists) {
    if ($requireChecklist -and -not $checklistGate) { $pendingGates += "checklist" }
    if ($requireAnalyze -and -not $analyzeGate) { $pendingGates += "analyze" }
    if ($requireCritic -and -not $criticGate) { $pendingGates += "critic" }
    if ($verifyRequired -and -not $verifyPassed) { $pendingGates += "verify" }
    if ($closeoutDecision -eq "not-complete") { $pendingGates += "closeout (blocking defects open)" }
}
$pendingGatesStr = ($pendingGates -join ", ")

$quickfixDir = Join-Path $repoRoot ".devspark.work/quickfixes"
$quickfixExists = $false
$quickfixComplete = $false
if ($currentBranch -match '^QF-' -or $currentBranch -match '^\d{3}-fix-') {
    $quickfixRecord = Join-Path $quickfixDir ("$currentBranch.md")
    $quickfixExists = Test-Path $quickfixRecord
    if ($quickfixExists) {
        try {
            $qf = Get-Content $quickfixRecord -Raw -ErrorAction SilentlyContinue
            if ($qf -match '(?m)^\s*-\s*\*\*Completed\*\*:\s*\S') { $quickfixComplete = $true }
        } catch { $quickfixComplete = $false }
    }
}

# Best-effort PR + review detection (platform-aware)
$prExists = $false
$prNumber = ""
$prState = ""
if ($hasGit) {
    if ($platform -eq 'azdo' -and (Get-Command az -ErrorAction SilentlyContinue)) {
        try {
            $azctx = Get-AzdoRepoContext
            $azList = az repos pr list --organization "https://dev.azure.com/$($azctx.Org)" --project $azctx.Project --repository $azctx.Repo --source-branch $currentBranch --status active --top 1 --output json 2>$null | ConvertFrom-Json
            $pr = @($azList)[0]
            if ($pr -and $pr.pullRequestId) {
                $prExists = $true
                $prNumber = "$($pr.pullRequestId)"
                $prState = "$($pr.status)"
            }
        } catch { $prExists = $false }
    }
    elseif (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            $prJson = gh pr view --json number,state 2>$null | ConvertFrom-Json
            if ($prJson -and $prJson.number) {
                $prExists = $true
                $prNumber = "$($prJson.number)"
                $prState = "$($prJson.state)"
            }
        } catch { $prExists = $false }
    }
}

$reviewFileExists = $false
$reviewOpenFindings = $false
$reviewDir = Join-Path $repoRoot ".devspark.work/pr-review"
if (Test-Path $reviewDir) {
    $reviewFile = $null
    if ($prNumber) {
        $candidate = Join-Path $reviewDir ("pr-$prNumber.md")
        if (Test-Path $candidate) { $reviewFile = $candidate }
    }
    if (-not $reviewFile) {
        $reviewFile = (Get-ChildItem -Path $reviewDir -Filter "pr-*.md" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1)?.FullName
    }
    if ($reviewFile -and (Test-Path $reviewFile)) {
        $reviewFileExists = $true
        try {
            $reviewText = Get-Content $reviewFile -Raw -ErrorAction SilentlyContinue
            $reviewOpenFindings = ($reviewText -match 'Open')
        } catch { $reviewOpenFindings = $false }
    }
}

# ---- Recommendation ladder ----
$recommended = "/devspark.specify"
$state = "unknown"
$reason = "Describe the work to /devspark.specify and it will route you."

if (-not $constitutionExists) {
    $recommended = "/devspark.constitution"
    $state = "no-constitution"
    $reason = "No project constitution found. Create your principles first so every command has a validation baseline."
}
elseif ($isDefaultBranch -and -not $specExists -and -not $quickfixExists) {
    $recommended = "/devspark.specify"
    $state = "no-active-work"
    $reason = "You're on '$currentBranch' with no active spec or quickfix. Start with /devspark.specify (unsure of size) or /devspark.quickfix (small, contained fix)."
}
elseif ($specExists -and $isFullSpec -and -not $planExists) {
    $recommended = "/devspark.plan"
    $state = "spec-needs-plan"
    $reason = "Spec exists for '$currentBranch' but there's no plan yet. Run /devspark.plan to produce the technical design."
}
elseif ($specExists -and $isFullSpec -and $planExists -and -not $tasksExists) {
    $recommended = "/devspark.tasks"
    $state = "plan-needs-tasks"
    $reason = "Plan exists but there's no task breakdown. Run /devspark.tasks to generate the ordered task list."
}
elseif ($specExists -and $isFullSpec -and $tasksExists -and $tasksDone -eq 0 -and $requireAnalyze -and -not $analyzeGate) {
    $recommended = "/devspark.analyze"
    $state = "tasks-need-analyze"
    $reason = "Tasks are ready and this full-spec route requires an analysis gate. Run /devspark.analyze to check spec/plan/tasks consistency before implementing."
}
elseif ($specExists -and $isFullSpec -and $tasksExists -and $tasksDone -eq 0 -and $requireCritic -and -not $criticGate) {
    $recommended = "/devspark.critic"
    $state = "tasks-need-critic"
    $reason = "Analysis is done and this full-spec route requires a risk review. Run /devspark.critic for an adversarial pre-mortem before implementing."
}
elseif ($specExists -and $isFullSpec -and $tasksExists -and -not $tasksComplete) {
    $recommended = "/devspark.implement"
    $state = "tasks-incomplete"
    $reason = "Tasks are defined ($tasksDone/$tasksTotal complete) but not finished. Run /devspark.implement to execute the remaining tasks."
}
elseif ($specExists -and $isFullSpec -and $tasksComplete) {
    $recommended = "/devspark.implement"
    $state = "implementation-needs-finalization"
    $reason = "The task list is complete but the temporary planning bundle still exists. Run /devspark.implement to verify code, tests, and current knowledge, then delete the bundle."
}
elseif ($specExists -and -not $isFullSpec) {
    $recommended = "/devspark.implement"
    $state = "quickspec-needs-implement"
    $statusLabel = if ($specStatus) { $specStatus } else { "Draft" }
    $reason = "A temporary quick-spec exists for '$currentBranch' (Status: $statusLabel). Run /devspark.implement to finish its action plan, verify the durable result, and delete the bundle."
}
elseif ($quickfixExists -and -not $prExists) {
    $recommended = "/devspark.implement"
    $state = "quickfix-open"
    $reason = "A temporary quickfix record exists for '$currentBranch'. Run /devspark.implement to finish the change, verify code, tests, and current knowledge, and delete the record."
}
elseif ($dirty) {
    $recommended = "commit"
    $state = "uncommitted-changes"
    $reason = "You have uncommitted changes on '$currentBranch'. Commit your work (then re-run /devspark.next). If this is a spec route mid-implementation, continue with /devspark.implement."
}
elseif (-not $prExists) {
    $recommended = "/devspark.create-pr"
    $state = "ready-for-pr"
    $reason = "Work is committed on '$currentBranch' and no PR exists yet. Open one with /devspark.create-pr (it will publish the branch and let you optionally run /devspark.verify)."
}
elseif ($prExists -and -not $reviewFileExists) {
    $recommended = "/devspark.pr-review"
    $state = "pr-needs-review"
    $reason = "PR #$prNumber is open but has no review yet. Run /devspark.pr-review to review it against the constitution."
}
elseif ($reviewFileExists -and $reviewOpenFindings) {
    $recommended = "/devspark.address-pr-review"
    $state = "review-has-open-findings"
    $reason = "PR #$prNumber has open review findings. Run /devspark.address-pr-review to fix them, then re-review with /devspark.pr-review #$prNumber re-review."
}
elseif ($reviewFileExists -and $behindTarget) {
    $recommended = "sync"
    $state = "behind-target"
    $reason = "Review looks clear but '$currentBranch' is behind '$defaultBranch'. Sync it (merge origin/$defaultBranch in) before merging the PR."
}
elseif ($reviewFileExists) {
    $recommended = "merge"
    $state = "ready-to-merge"
    $reason = "PR #$prNumber is reviewed and the branch is in sync. Approve and merge it in your Git portal (GitHub / Azure DevOps)."
}

# Surface still-open advisory gates without blocking the primary recommendation.
if ($pendingGatesStr -and $recommended -notmatch 'analyze|critic|checklist|verify|constitution') {
    $reason = "$reason Open advisory gates still recommended before merge: $pendingGatesStr."
}

$result = [ordered]@{
    REPO_ROOT           = $repoRoot
    REPO_NAME           = $repoName
    PLATFORM            = $platform
    ASSISTANT_NAME      = $assistantName
    GIT_USER            = $gitUser
    HAS_GIT             = $hasGit
    CONSTITUTION_EXISTS = $constitutionExists
    CURRENT_BRANCH      = $currentBranch
    DEFAULT_BRANCH      = $defaultBranch
    IS_DEFAULT_BRANCH   = $isDefaultBranch
    DIRTY               = $dirty
    HAS_REMOTE          = $hasRemote
    BRANCH_PUSHED       = $branchPushed
    BEHIND_TARGET       = $behindTarget
    SPEC_EXISTS         = $specExists
    IS_FULL_SPEC        = $isFullSpec
    SPEC_STATUS         = $specStatus
    PLAN_EXISTS         = $planExists
    TASKS_EXISTS        = $tasksExists
    TASKS_TOTAL         = $tasksTotal
    TASKS_DONE          = $tasksDone
    TASKS_COMPLETE      = $tasksComplete
    VERIFY_REQUIRED     = $verifyRequired
    VERIFY_PASSED       = $verifyPassed
    CLOSEOUT_DECISION   = $closeoutDecision
    PENDING_GATES       = $pendingGatesStr
    QUICKFIX_EXISTS     = $quickfixExists
    QUICKFIX_COMPLETE   = $quickfixComplete
    PR_EXISTS           = $prExists
    PR_NUMBER           = $prNumber
    PR_STATE            = $prState
    REVIEW_FILE_EXISTS  = $reviewFileExists
    REVIEW_OPEN         = $reviewOpenFindings
    RECOMMENDED_COMMAND = $recommended
    STATE               = $state
    REASON              = $reason
}

if ($Json) {
    $result | ConvertTo-Json
}
else {
    Write-Output "Next-Step Router"
    Write-Output "================"
    Write-Output "Assistant: $assistantName"
    Write-Output "Repo: $repoName ($platform)"
    Write-Output "Branch: $currentBranch (default: $defaultBranch)"
    Write-Output "State: $state"
    Write-Output "Recommended: $recommended"
    Write-Output "Reason: $reason"
}
