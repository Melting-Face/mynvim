<#
.SYNOPSIS
    mynvim 설치 스크립트 (Windows 네이티브, winget 사용)

.DESCRIPTION
    필수 패키지(Neovim, Git, ripgrep, Node.js LTS, Python 3.12, zig)와 선택 항목을 winget으로 설치하고,
    %LOCALAPPDATA%\nvim 을 이 레포로 향하는 디렉터리 정션으로 연결한 뒤 플러그인을 동기화한다.
    관리자 권한이 필요하지 않다 (winget의 UAC 창은 뜰 수 있음). Windows PowerShell 5.1에서 동작한다.

.PARAMETER With
    선택 항목 (go, rust, java, lua). 'rust,lua' 같은 쉼표 목록과 배열을 모두 받는다.
    tmux는 Windows에서 지원하지 않으므로 경고 후 건너뛴다.

.PARAMETER All
    모든 선택 항목 설치 (tmux 제외)

.PARAMETER Yes
    대화형 질문 없이 진행 (선택 항목 미지정 시 필수만 설치)

.PARAMETER DryRun
    실행할 명령만 출력하고 아무것도 변경하지 않음

.EXAMPLE
    .\install.ps1 -With rust,lua -DryRun
#>
#Requires -Version 5.1
[CmdletBinding()]
param(
    [string[]]$With,
    [switch]$All,
    [switch]$Yes,
    [switch]$DryRun
)

# DryRun이면 '+ <명령>'만 출력하고, 아니면 Action을 실행한다
function Invoke-Step {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action,
        [switch]$DryRun
    )
    if ($DryRun) {
        Write-Output "+ $Command"
        return
    }
    & $Action
}

# 명령이 PATH에 있는지 확인한다 (테스트에서 Mock 하기 위한 래퍼)
function Test-CommandAvailable {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

# 대화형 세션인지 확인한다 (입력이 리다이렉트되지 않은 경우만)
function Test-InteractiveSession {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    return ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected)
}

# 선택 항목을 정해진 순서(go, rust, java, lua)의 배열로 정리한다
# 알 수 없는 이름은 종료 오류(throw)를 낸다. exit 대신 throw를 쓰는 이유: dot-source한 Pester 세션을 죽이지 않기 위해
function Resolve-Components {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = '작업 명세에 정해진 함수 이름')]
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [string[]]$With,
        [switch]$All,
        [switch]$Yes
    )
    $known = @('tmux', 'go', 'rust', 'java', 'lua')
    $requested = New-Object System.Collections.Generic.List[string]

    foreach ($entry in @($With)) {
        if ([string]::IsNullOrEmpty($entry)) {
            continue
        }
        foreach ($part in ($entry -split ',')) {
            $name = $part.Trim()
            if ($name -eq '') {
                continue
            }
            if ($known -cnotcontains $name) {
                throw "알 수 없는 항목: $name (사용 가능: $($known -join ' '))"
            }
            $requested.Add($name)
        }
    }
    $hasWith = $requested.Count -gt 0

    if ($All) {
        foreach ($name in $known) {
            if ($name -ne 'tmux') {
                $requested.Add($name)
            }
        }
    }

    # 선택 항목이 없고 대화형일 때만 항목별로 y/N을 묻는다
    if (-not $hasWith -and -not $All -and -not $Yes -and (Test-InteractiveSession)) {
        foreach ($name in $known) {
            if ($name -eq 'tmux') {
                continue
            }
            $answer = Read-Host -Prompt "$name 을(를) 설치할까요? [y/N]"
            if ($answer -match '^(y|yes)$') {
                $requested.Add($name)
            }
        }
    }

    if ($requested -ccontains 'tmux') {
        Write-Warning 'tmux는 Windows에서 지원하지 않아 건너뜁니다'
    }

    $result = @()
    foreach ($name in $known) {
        if ($name -ne 'tmux' -and $requested -ccontains $name) {
            $result += $name
        }
    }
    return $result
}

# 필수 패키지의 winget ID 목록
function Get-CorePackageId {
    [CmdletBinding()]
    [OutputType([string[]])]
    param()
    return @(
        'Neovim.Neovim',
        'Git.Git',
        'BurntSushi.ripgrep.MSVC',
        'OpenJS.NodeJS.LTS',
        'Python.Python.3.12',
        'zig.zig'
    )
}

# 선택 항목 이름을 winget ID로 바꾼다
function Get-OptionalPackageId {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Component
    )
    switch -CaseSensitive ($Component) {
        'go' { return 'GoLang.Go' }
        'rust' { return 'Rustlang.Rustup' }
        'java' { return 'EclipseAdoptium.Temurin.21.JDK' }
        'lua' { return 'DEVCOM.Lua' }
    }
    throw "winget ID가 정의되지 않은 항목: $Component"
}

# winget 실행 래퍼 (테스트에서 Mock 하기 위함)
function Invoke-Winget {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )
    & winget @Arguments
}

# winget에 이미 설치된 패키지인지 확인한다
function Test-WingetPackageInstalled {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id
    )
    Invoke-Winget -Arguments @('list', '--id', $Id, '-e', '--accept-source-agreements') | Out-Null
    return ($LASTEXITCODE -eq 0)
}

# winget 패키지를 설치한다. 이미 설치되어 있으면 건너뛴다 (DryRun은 확인 없이 명령만 출력)
function Install-WingetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,
        [switch]$DryRun
    )
    if (-not $DryRun -and (Test-WingetPackageInstalled -Id $Id)) {
        Write-Output "이미 설치됨: $Id"
        return
    }
    $wingetArgs = @('install', '--id', $Id, '-e', '--accept-source-agreements', '--accept-package-agreements')
    Invoke-Step -DryRun:$DryRun -Command ('winget ' + ($wingetArgs -join ' ')) -Action {
        Invoke-Winget -Arguments $wingetArgs
        $exitCode = $LASTEXITCODE
        # 0: 성공, -1978335135(0x8A150061): 이미 설치됨, -1978335189(0x8A15002B): 적용할 업데이트 없음
        if (@(0, -1978335135, -1978335189) -notcontains $exitCode) {
            throw "winget 설치 실패: $Id (exit code $exitCode)"
        }
    }
}

# 현재 세션의 PATH를 Machine·User 값으로 새로 고친다 (방금 설치한 명령을 찾기 위함)
function Update-SessionPath {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = '-DryRun으로 변경 여부를 제어한다')]
    [CmdletBinding()]
    param(
        [switch]$DryRun
    )
    Invoke-Step -DryRun:$DryRun -Command '$env:Path = <Machine Path>;<User Path>' -Action {
        $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        $env:Path = (@($machinePath, $userPath) | Where-Object { -not [string]::IsNullOrEmpty($_) }) -join ';'
    }
}

# 상대 경로를 현재 위치 기준 전체 경로로 바꾼다 (존재하지 않아도 됨, 끝의 구분자는 제거)
function Resolve-FullPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    $providerPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    return [System.IO.Path]::GetFullPath($providerPath).TrimEnd('\', '/')
}

# 두 경로가 같은지 대소문자 구분 없이 비교한다
function Test-SamePath {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Left,
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Right
    )
    if ([string]::IsNullOrEmpty($Left) -or [string]::IsNullOrEmpty($Right)) {
        return $false
    }
    return [string]::Equals($Left, $Right, [System.StringComparison]::OrdinalIgnoreCase)
}

# 경로에 무언가(깨진 정션 포함)가 있는지 확인한다. 링크를 따라가지 않는다
function Test-PathEntry {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    try {
        [void][System.IO.File]::GetAttributes($Path)
        return $true
    } catch {
        return $false
    }
}

# 정션/심볼릭 링크가 가리키는 전체 경로를 돌려준다. 링크가 아니면 $null
function Get-LinkTargetPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    try {
        $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    } catch {
        return $null
    }
    if ([string]::IsNullOrEmpty($item.LinkType)) {
        return $null
    }
    # PowerShell 5.1에서는 Target이 배열일 수 있으므로 첫 요소를 쓴다
    $rawTarget = @($item.Target)[0]
    if ([string]::IsNullOrEmpty($rawTarget)) {
        return $null
    }
    $rawTarget = $rawTarget -replace '^\\\?\?\\', ''
    if (-not [System.IO.Path]::IsPathRooted($rawTarget)) {
        $rawTarget = Join-Path -Path (Split-Path -Parent $Path) -ChildPath $rawTarget
    }
    return [System.IO.Path]::GetFullPath($rawTarget).TrimEnd('\', '/')
}

# 파일/디렉터리(깨진 정션 포함)를 링크를 따라가지 않고 이름만 바꾼다
function Move-PathEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )
    $attributes = [System.IO.File]::GetAttributes($Path)
    if ($attributes.HasFlag([System.IO.FileAttributes]::Directory)) {
        [System.IO.Directory]::Move($Path, $Destination)
    } else {
        [System.IO.File]::Move($Path, $Destination)
    }
}

# Target을 Source로 향하는 디렉터리 정션으로 만든다. 기존 대상은 지우지 않고 백업한다
function Set-ConfigLink {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = '-DryRun으로 변경 여부를 제어한다')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Target,
        [switch]$DryRun
    )
    $sourceFull = Resolve-FullPath -Path $Source
    $targetFull = Resolve-FullPath -Path $Target
    if (-not (Test-Path -LiteralPath $sourceFull -PathType Container)) {
        throw "연결할 원본 디렉터리가 없습니다: $sourceFull"
    }

    # 이미 Source를 가리키는 링크이거나, 레포를 대상 위치에 직접 clone한 경우
    $linkTarget = Get-LinkTargetPath -Path $targetFull
    if ((Test-SamePath -Left $targetFull -Right $sourceFull) -or (Test-SamePath -Left $linkTarget -Right $sourceFull)) {
        Write-Output "already linked: $targetFull"
        return
    }

    $parent = Split-Path -Parent $targetFull
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        Invoke-Step -DryRun:$DryRun -Command "New-Item -ItemType Directory -Path `"$parent`"" -Action {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
    }

    if (Test-PathEntry -Path $targetFull) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = "$targetFull.bak.$stamp"
        $n = 0
        while (Test-PathEntry -Path $backup) {
            $n++
            $backup = "$targetFull.bak.$stamp-$n"
        }
        Write-Output "백업: $targetFull -> $backup"
        Invoke-Step -DryRun:$DryRun -Command "Move-Item -LiteralPath `"$targetFull`" -Destination `"$backup`"" -Action {
            Move-PathEntry -Path $targetFull -Destination $backup
        }
    }

    Invoke-Step -DryRun:$DryRun -Command "New-Item -ItemType Junction -Path `"$targetFull`" -Value `"$sourceFull`"" -Action {
        New-Item -ItemType Junction -Path $targetFull -Value $sourceFull | Out-Null
    }
}

# 사용자 범위 환경변수를 설정한다 (테스트에서 Mock 하기 위한 래퍼)
function Set-UserEnvironmentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = '호출하는 쪽에서 -DryRun으로 제어한다')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )
    [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
}

# WezTerm이 레포의 wezterm.lua를 읽도록 사용자 환경변수 WEZTERM_CONFIG_FILE을 설정한다
# (Windows에서 파일 심볼릭 링크는 개발자 모드가 필요하므로 링크 대신 환경변수를 쓴다)
function Set-WeztermConfig {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = '-DryRun으로 변경 여부를 제어한다')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [switch]$DryRun
    )
    Invoke-Step -DryRun:$DryRun -Command "[Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', '$Path', 'User')" -Action {
        Set-UserEnvironmentVariable -Name 'WEZTERM_CONFIG_FILE' -Value $Path
    }
}

function Main {
    [CmdletBinding()]
    param(
        [string[]]$With,
        [switch]$All,
        [switch]$Yes,
        [switch]$DryRun
    )
    $ErrorActionPreference = 'Stop'

    try {
        $components = @(Resolve-Components -With $With -All:$All -Yes:$Yes)
    } catch {
        [Console]::Error.WriteLine("install.ps1: $($_.Exception.Message)")
        exit 2
    }

    $selected = '없음 (필수만)'
    if ($components.Count -gt 0) {
        $selected = $components -join ' '
    }
    Write-Output '플랫폼: windows'
    Write-Output '패키지 관리자: winget'
    Write-Output "선택 항목: $selected"
    if ($DryRun) {
        Write-Output '(dry-run: 변경 없음)'
    }

    if (-not (Test-CommandAvailable -Name 'winget')) {
        [Console]::Error.WriteLine('install.ps1: winget이 필요합니다. Microsoft Store에서 App Installer를 설치하세요: https://aka.ms/getwinget')
        exit 1
    }

    $repoDir = $PSScriptRoot
    try {
        # 1) 패키지 설치
        foreach ($id in (Get-CorePackageId)) {
            Install-WingetPackage -Id $id -DryRun:$DryRun
        }
        foreach ($component in $components) {
            Install-WingetPackage -Id (Get-OptionalPackageId -Component $component) -DryRun:$DryRun
        }
        Update-SessionPath -DryRun:$DryRun

        # 2) 설정 연결 (기존 대상은 백업)
        Set-ConfigLink -Source $repoDir -Target (Join-Path -Path $env:LOCALAPPDATA -ChildPath 'nvim') -DryRun:$DryRun
        if (Test-CommandAvailable -Name 'wezterm') {
            Set-WeztermConfig -Path (Join-Path -Path $repoDir -ChildPath 'wezterm.lua') -DryRun:$DryRun
        } else {
            Write-Output 'WezTerm이 감지되지 않아 WEZTERM_CONFIG_FILE 설정을 건너뜀 (WezTerm 설치 후 다시 실행하세요)'
        }

        # 3) 플러그인 동기화
        Invoke-Step -DryRun:$DryRun -Command 'nvim --headless "+Lazy! sync" +qa' -Action {
            & nvim --headless '+Lazy! sync' +qa
            if ($LASTEXITCODE -ne 0) {
                throw "플러그인 동기화 실패 (exit code $LASTEXITCODE)"
            }
        }
    } catch {
        [Console]::Error.WriteLine("install.ps1: $($_.Exception.Message)")
        exit 1
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Main -With $With -All:$All -Yes:$Yes -DryRun:$DryRun
}
