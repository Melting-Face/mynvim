<#
.SYNOPSIS
    mynvim 설치 스크립트 (Windows 네이티브, winget 사용)

.DESCRIPTION
    필수 패키지(Neovim, Git, ripgrep, Node.js LTS, Python 3.12, zig, PowerShell 7)와 선택 항목을 winget으로 설치하고,
    %LOCALAPPDATA%\nvim 을 이 레포로 향하는 디렉터리 정션으로 연결한 뒤 플러그인을 동기화한다.
    관리자 권한이 필요하지 않다 (winget의 UAC 창은 뜰 수 있음). Windows PowerShell 5.1에서 동작한다.

.PARAMETER With
    선택 항목 (go, rust, java, lua). 'rust,lua' 같은 쉼표 목록과 배열을 모두 받는다.
    tmux는 더 이상 설치하지 않으므로(WezTerm 멀티플렉서 사용) 경고 후 건너뛴다.

.PARAMETER All
    모든 선택 항목 설치

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

# 명령줄 인자에 -NonInteractive(약어 -noni 등 포함, 대소문자 무시)가 있는지 확인한다
# -File/-Command 뒤의 인자는 스크립트에 넘어가는 값이므로 보지 않는다
function Test-NonInteractiveArgument {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]]$Arguments
    )
    foreach ($argument in @($Arguments)) {
        if ([string]::IsNullOrEmpty($argument) -or $argument -notmatch '^[-/]') {
            continue
        }
        $name = $argument.TrimStart('-', '/').ToLowerInvariant()
        if (@('file', 'f', 'command', 'c') -contains $name) {
            break
        }
        # PowerShell은 고유한 접두어를 허용한다 (-noni ~ -noninteractive)
        if ($name.Length -ge 4 -and 'noninteractive'.StartsWith($name, [System.StringComparison]::Ordinal)) {
            return $true
        }
    }
    return $false
}

# 대화형 세션인지 확인한다 (입력이 리다이렉트되지 않고, 호스트가 -NonInteractive로 실행되지 않은 경우만)
# -NonInteractive 호스트에서 Read-Host는 실패하므로 묻지 않고 필수만 설치한다
function Test-InteractiveSession {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    if (-not [Environment]::UserInteractive -or [Console]::IsInputRedirected) {
        return $false
    }
    return (-not (Test-NonInteractiveArgument -Arguments ([Environment]::GetCommandLineArgs())))
}

# 선택 항목 이름 목록
function Get-KnownComponent {
    [CmdletBinding()]
    [OutputType([string[]])]
    param()
    return @('go', 'rust', 'java', 'lua')
}

# -With 값(쉼표 목록·배열)을 이름 배열로 풀고 검증만 한다 (묻지 않는 순수 함수: Main이 사전 점검 전에 호출)
# 알 수 없는 이름은 종료 오류(throw)를 낸다. exit 대신 throw를 쓰는 이유: dot-source한 Pester 세션을 죽이지 않기 위해
function Get-RequestedComponent {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [string[]]$With
    )
    $known = Get-KnownComponent
    $requested = @()
    foreach ($entry in @($With)) {
        if ([string]::IsNullOrEmpty($entry)) {
            continue
        }
        foreach ($part in ($entry -split ',')) {
            $name = $part.Trim()
            if ($name -eq '') {
                continue
            }
            # tmux는 예전 선택 항목이라 오류로 끝내지 않고 Resolve-Components가 경고 후 뺀다
            if ($name -cne 'tmux' -and $known -cnotcontains $name) {
                throw "알 수 없는 항목: $name (사용 가능: $($known -join ' '))"
            }
            $requested += $name
        }
    }
    return $requested
}

# 선택 항목을 정해진 순서(go, rust, java, lua)의 배열로 정리한다
# 검증은 Get-RequestedComponent가 하고, 선택 항목이 없고 대화형이면 여기서 y/N을 묻는다
function Resolve-Components {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = '작업 명세에 정해진 함수 이름')]
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [string[]]$With,
        [switch]$All,
        [switch]$Yes
    )
    $known = Get-KnownComponent
    $requested = New-Object System.Collections.Generic.List[string]

    foreach ($name in @(Get-RequestedComponent -With $With)) {
        $requested.Add($name)
    }
    $hasWith = $requested.Count -gt 0

    if ($All) {
        foreach ($name in $known) {
            $requested.Add($name)
        }
    }

    # 선택 항목이 없고 대화형일 때만 항목별로 y/N을 묻는다
    if (-not $hasWith -and -not $All -and -not $Yes -and (Test-InteractiveSession)) {
        foreach ($name in $known) {
            $answer = Read-Host -Prompt "$name 을(를) 설치할까요? [y/N]"
            if ($answer -match '^(y|yes)$') {
                $requested.Add($name)
            }
        }
    }

    if ($requested -ccontains 'tmux') {
        Write-Warning 'tmux는 더 이상 설치하지 않아 건너뜁니다 (WezTerm 멀티플렉서를 씁니다. docs/wezterm.md 참고)'
    }

    $result = @()
    foreach ($name in $known) {
        if ($requested -ccontains $name) {
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
        'zig.zig',
        # wezterm.lua의 Windows 기본 셸이 pwsh.exe이므로 PowerShell 7도 필수로 설치한다
        'Microsoft.PowerShell'
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
        'java' { return 'EclipseAdoptium.Temurin.25.JDK' } # jdtls 1.62부터 Java 25 필요
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

# 'nvim --version' 첫 줄("NVIM v0.10.2")을 [version]으로 바꾼다. 형식이 다르면 $null
function ConvertTo-NvimVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Text
    )
    if ($Text -match '^NVIM v(\d+)\.(\d+)\.(\d+)') {
        return [version]('{0}.{1}.{2}' -f $Matches[1], $Matches[2], $Matches[3])
    }
    return $null
}

# 설치된 nvim 버전을 돌려준다. nvim이 없으면 $null (테스트에서 Mock 하기 위한 래퍼)
function Get-NvimVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param()
    if (-not (Test-CommandAvailable -Name 'nvim')) {
        return $null
    }
    $firstLine = @(& nvim --version)[0]
    return (ConvertTo-NvimVersion -Text $firstLine)
}

# nvim이 0.11 미만이면 winget으로 업그레이드하고 PATH를 다시 반영한다
function Update-OutdatedNvim {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = '-DryRun으로 변경 여부를 제어한다')]
    [CmdletBinding()]
    param(
        [switch]$DryRun
    )
    $minimum = [version]'0.11.0'
    $current = Get-NvimVersion
    if ($null -eq $current) {
        Write-Output 'nvim을 PATH에서 찾지 못해 버전 확인을 건너뜀'
        return
    }
    if ($current -ge $minimum) {
        Write-Output "nvim $current 확인됨 (0.11 이상)"
        return
    }
    Write-Output "nvim 0.11 이상이 필요합니다 (현재: $current)"
    $wingetArgs = @('upgrade', '--id', 'Neovim.Neovim', '-e', '--accept-source-agreements', '--accept-package-agreements')
    Invoke-Step -DryRun:$DryRun -Command ('winget ' + ($wingetArgs -join ' ')) -Action {
        Invoke-Winget -Arguments $wingetArgs
        $exitCode = $LASTEXITCODE
        # 0: 성공, -1978335189(0x8A15002B): 적용할 업데이트 없음
        # 그 밖(예: -1978335212(0x8A150014), winget 밖에서 설치한 nvim)은 중단하지 않고 경고만 한다
        if (@(0, -1978335189) -notcontains $exitCode) {
            Write-Warning "nvim 업그레이드 실패 (exit code $exitCode). winget 밖에서 설치한 nvim일 수 있습니다. 'winget upgrade --id Neovim.Neovim'으로 확인하거나, 직접 0.11 이상으로 올리세요"
        }
    }
    Update-SessionPath -DryRun:$DryRun
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

# Path가 Parent 디렉터리의 하위 경로인지 대소문자 구분 없이 확인한다 (같은 경로는 하위가 아님)
function Test-PathInside {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Path,
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Parent
    )
    if ([string]::IsNullOrEmpty($Path) -or [string]::IsNullOrEmpty($Parent)) {
        return $false
    }
    # 구분자를 '\'로 통일해 비교한다
    $normalizedPath = $Path.Replace('/', '\')
    $prefix = $Parent.Replace('/', '\').TrimEnd('\') + '\'
    return ($normalizedPath.Length -gt $prefix.Length) -and $normalizedPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
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
    # Target 읽기나 경로 변환이 실패하면(권한, 형식이 다른 재분석 지점 등) 링크 대상을 모르는 것으로 본다
    try {
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
    } catch {
        return $null
    }
}

# 경로 항목(깨진 정션 포함)이 디렉터리면 'Directory', 아니면 'File'을 돌려준다. 링크를 따라가지 않는다
function Get-PathEntryKind {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    $attributes = [System.IO.File]::GetAttributes($Path)
    if ($attributes.HasFlag([System.IO.FileAttributes]::Directory)) {
        return 'Directory'
    }
    return 'File'
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
    if ((Get-PathEntryKind -Path $Path) -eq 'Directory') {
        [System.IO.Directory]::Move($Path, $Destination)
    } else {
        [System.IO.File]::Move($Path, $Destination)
    }
}

# 레포(Source)가 연결 대상(Target)의 하위 경로이면 $true (같은 경로는 하위가 아님)
function Test-RepoInsideTarget {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Target
    )
    return (Test-PathInside -Path (Resolve-FullPath -Path $Source) -Parent (Resolve-FullPath -Path $Target))
}

# 레포가 연결 대상 안에 있을 때의 오류 메시지
function Get-RepoInsideTargetMessage {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Target
    )
    return "레포($Source)가 연결 대상($Target) 안에 있습니다. 레포를 다른 곳(예: `$HOME\mynvim)에 clone한 뒤 다시 실행하세요"
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

    # 레포가 대상 안에 clone된 경우: 대상을 백업(이동)하면 레포 경로가 바뀌므로 아무것도 바꾸지 않고 중단한다
    # (Main의 사전 점검과 같은 검사를 한 번 더 하는 방어 코드)
    if (Test-RepoInsideTarget -Source $sourceFull -Target $targetFull) {
        throw (Get-RepoInsideTargetMessage -Source $sourceFull -Target $targetFull)
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
        # 대상 종류(파일/디렉터리)는 실제로 옮길 때만 Move-PathEntry가 읽는다. DryRun은 읽지 않고 중립적인 형식으로 출력한다
        Invoke-Step -DryRun:$DryRun -Command "move `"$targetFull`" -> `"$backup`"" -Action {
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

# 스크립트를 종료 코드와 함께 끝낸다 (테스트에서 Mock 하기 위한 래퍼: exit는 Pester 세션까지 끝내므로)
function Exit-Script {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Code
    )
    exit $Code
}

# 이 레포 경로 (테스트에서 Mock 하기 위한 래퍼)
function Get-RepoDir {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    return $PSScriptRoot
}

# nvim 설정 연결 대상 경로 (%LOCALAPPDATA%\nvim)
# LOCALAPPDATA가 비어 있으면 Join-Path 바인딩 오류 대신 알기 쉬운 오류를 낸다 (Main이 'install.ps1:'을 붙여 exit 1)
function Get-NvimConfigTarget {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    if ([string]::IsNullOrEmpty($env:LOCALAPPDATA)) {
        throw 'LOCALAPPDATA 환경변수가 비어 있어 nvim 설정 경로(%LOCALAPPDATA%\nvim)를 정할 수 없습니다. LOCALAPPDATA를 설정한 뒤 다시 실행하세요'
    }
    return (Join-Path -Path $env:LOCALAPPDATA -ChildPath 'nvim')
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

    # 인자 검증: install.sh와 같이 알 수 없는 항목(exit 2)을 사전 점검(exit 1)보다 먼저 확인한다 (묻지 않음)
    try {
        [void](Get-RequestedComponent -With $With)
    } catch {
        [Console]::Error.WriteLine("install.ps1: $($_.Exception.Message)")
        Exit-Script -Code 2
    }

    # 사전 점검: 묻거나 설치하기 전에, 레포가 nvim 설정 대상 안에 clone되었으면 바로 중단한다
    $repoDir = Get-RepoDir
    try {
        $nvimTarget = Get-NvimConfigTarget
    } catch {
        [Console]::Error.WriteLine("install.ps1: $($_.Exception.Message)")
        Exit-Script -Code 1
    }
    if (Test-RepoInsideTarget -Source $repoDir -Target $nvimTarget) {
        [Console]::Error.WriteLine("install.ps1: $(Get-RepoInsideTargetMessage -Source (Resolve-FullPath -Path $repoDir) -Target (Resolve-FullPath -Path $nvimTarget))")
        Exit-Script -Code 1
    }

    # 대화형 질문은 사전 점검 뒤에 한다 (질문을 다 받은 뒤 거절하지 않도록)
    try {
        $components = @(Resolve-Components -With $With -All:$All -Yes:$Yes)
    } catch {
        [Console]::Error.WriteLine("install.ps1: $($_.Exception.Message)")
        Exit-Script -Code 2
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
        Exit-Script -Code 1
    }

    try {
        # 1) 패키지 설치
        foreach ($id in (Get-CorePackageId)) {
            Install-WingetPackage -Id $id -DryRun:$DryRun
        }
        foreach ($component in $components) {
            Install-WingetPackage -Id (Get-OptionalPackageId -Component $component) -DryRun:$DryRun
        }
        Update-SessionPath -DryRun:$DryRun
        Update-OutdatedNvim -DryRun:$DryRun

        # 2) 설정 연결 (기존 대상은 백업)
        Set-ConfigLink -Source $repoDir -Target $nvimTarget -DryRun:$DryRun
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
        Exit-Script -Code 1
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Main -With $With -All:$All -Yes:$Yes -DryRun:$DryRun
}
