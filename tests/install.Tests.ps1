# install.ps1 Pester 5 테스트
# 실행: Invoke-Pester tests/install.Tests.ps1
# 안전 규칙: 실제 winget 호출, 실제 %LOCALAPPDATA%\nvim, 사용자 환경변수 변경을 절대 하지 않는다.
#   - winget은 Invoke-Winget / Test-WingetPackageInstalled 래퍼를 Mock 한다
#   - 사용자 환경변수는 Set-UserEnvironmentVariable 래퍼를 Mock 한다
#   - 링크 대상은 모두 $TestDrive 아래 경로를 쓴다

BeforeDiscovery {
    # 정션 / 자식 프로세스 테스트는 Windows에서만 의미가 있다
    $NotWindows = [System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT
}

Describe 'install.ps1' {
    BeforeAll {
        $InstallScript = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath 'install.ps1'
        # dot-source: InvocationName이 '.'이므로 Main은 실행되지 않는다
        . $InstallScript

        # 자식 프로세스로 쓸 PowerShell 실행 파일 (현재 에디션과 동일하게)
        if ($PSVersionTable.PSEdition -eq 'Core') {
            $PowerShellExe = Join-Path -Path $PSHOME -ChildPath 'pwsh.exe'
        } else {
            $PowerShellExe = Join-Path -Path $PSHOME -ChildPath 'powershell.exe'
        }

        # 안전 가드: 아래 Mock은 모든 테스트에 적용된다 (개별 It에서 덮어쓸 수 있음)
        Mock Invoke-Winget { $global:LASTEXITCODE = 0 }
        Mock Test-WingetPackageInstalled { $false }
        Mock Set-UserEnvironmentVariable { }
        Mock Test-InteractiveSession { $false }
        Mock Get-NvimVersion { [version]'0.12.0' }

        # 테스트마다 겹치지 않는 작업 디렉터리를 만든다
        function New-TestBase {
            $base = Join-Path -Path $TestDrive -ChildPath ([guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $base -Force | Out-Null
            return $base
        }
    }

    Context 'Resolve-Components' {
        It 'unknown component throws' {
            { Resolve-Components -With 'foo' } | Should -Throw
            { Resolve-Components -With 'rust,foo' } | Should -Throw
        }

        It 'unknown component exits 2' -Skip:$NotWindows {
            # Windows PowerShell 5.1은 EAP=Stop일 때 2>&1로 받은 stderr 첫 줄을 종료 오류로 바꾸므로 이 블록에서만 Continue
            $ErrorActionPreference = 'Continue'
            $output = & $PowerShellExe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $InstallScript -With foo -DryRun 2>&1
            $LASTEXITCODE | Should -Be 2
            ($output | Out-String) | Should -Match 'foo'
        }

        It 'Get-RequestedComponent validates names without prompting' {
            Mock Test-InteractiveSession { $true }
            Mock Read-Host { 'y' }
            { Get-RequestedComponent -With 'rust,foo' } | Should -Throw '*foo*'
            $result = @(Get-RequestedComponent -With @('lua, rust', 'tmux'))
            ($result -join ',') | Should -Be 'lua,rust,tmux'
            @(Get-RequestedComponent).Count | Should -Be 0
            Should -Invoke Read-Host -Times 0 -Exactly
        }

        It 'Get-KnownComponent no longer lists tmux' {
            ((Get-KnownComponent) -join ',') | Should -Be 'go,rust,java,lua'
        }

        It 'All excludes tmux' {
            $result = @(Resolve-Components -All)
            ($result -join ',') | Should -Be 'go,rust,java,lua'
        }

        It 'explicit tmux warns and is dropped' {
            $warnings = $null
            $result = @(Resolve-Components -With 'tmux,rust' -WarningVariable warnings -WarningAction SilentlyContinue)
            ($result -join ',') | Should -Be 'rust'
            @($warnings).Count | Should -BeGreaterThan 0
            ($warnings -join ' ') | Should -Match 'tmux'
            ($warnings -join ' ') | Should -Match 'WezTerm'
        }

        It 'accepts comma string and array, de-duplicates, keeps canonical order' {
            $result = @(Resolve-Components -With @('lua, rust', 'rust', 'go'))
            ($result -join ',') | Should -Be 'go,rust,lua'
        }

        It 'Yes without selection returns nothing' {
            $result = @(Resolve-Components -Yes)
            $result.Count | Should -Be 0
        }

        It 'interactive session asks y/N for each optional component' {
            Mock Test-InteractiveSession { $true }
            Mock Read-Host { 'y' } -ParameterFilter { $Prompt -match '^(go|java) ' }
            Mock Read-Host { '' }
            $result = @(Resolve-Components)
            ($result -join ',') | Should -Be 'go,java'
            Should -Invoke Read-Host -Times 4 -Exactly
        }

        It 'non-interactive session does not prompt' {
            Mock Read-Host { 'y' }
            $result = @(Resolve-Components)
            $result.Count | Should -Be 0
            Should -Invoke Read-Host -Times 0 -Exactly
        }
    }

    Context 'Test-NonInteractiveArgument' {
        It 'detects -NonInteractive and its abbreviations case-insensitively' {
            Test-NonInteractiveArgument -Arguments @('powershell.exe', '-NonInteractive', '-File', 'install.ps1') | Should -BeTrue
            Test-NonInteractiveArgument -Arguments @('pwsh', '-noni', '-File', 'install.ps1') | Should -BeTrue
            Test-NonInteractiveArgument -Arguments @('pwsh', '-NONINTERACTIVE') | Should -BeTrue
            Test-NonInteractiveArgument -Arguments @('pwsh', '-NonInter') | Should -BeTrue
        }

        It 'ignores other flags and arguments passed to the script' {
            Test-NonInteractiveArgument -Arguments @('powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'install.ps1') | Should -BeFalse
            Test-NonInteractiveArgument -Arguments @('pwsh', '-NoLogo', '-non') | Should -BeFalse
            # -File 뒤는 스크립트 인자이므로 보지 않는다
            Test-NonInteractiveArgument -Arguments @('pwsh', '-File', 'install.ps1', '-NonInteractive') | Should -BeFalse
            Test-NonInteractiveArgument -Arguments @() | Should -BeFalse
        }
    }

    Context 'Invoke-Step' {
        It 'DryRun prints the command and does not run the action' {
            $state = @{ Ran = $false }
            $output = Invoke-Step -Command 'do something' -Action { $state.Ran = $true } -DryRun
            $output | Should -Be '+ do something'
            $state.Ran | Should -BeFalse
        }

        It 'runs the action without DryRun' {
            $state = @{ Ran = $false }
            Invoke-Step -Command 'do something' -Action { $state.Ran = $true }
            $state.Ran | Should -BeTrue
        }
    }

    Context 'Get-CorePackageId' {
        It 'lists the core winget ids including PowerShell 7' {
            # wezterm.lua의 Windows 기본 셸이 pwsh.exe이므로 Microsoft.PowerShell이 필수에 있어야 한다
            $ids = @(Get-CorePackageId)
            ($ids -join ',') | Should -Be 'Neovim.Neovim,Git.Git,BurntSushi.ripgrep.MSVC,OpenJS.NodeJS.LTS,Python.Python.3.12,zig.zig,Microsoft.PowerShell'
        }
    }

    Context 'Get-OptionalPackageId' {
        It 'java installs JDK 25 (jdtls 1.62+ needs Java 25 to run)' {
            Get-OptionalPackageId -Component 'java' | Should -Be 'EclipseAdoptium.Temurin.25.JDK'
        }
    }

    Context 'Test-PathInside' {
        It 'detects a path under the parent (case-insensitive, either separator)' {
            Test-PathInside -Path 'C:\Users\me\AppData\Local\nvim\mynvim' -Parent 'C:\Users\me\AppData\Local\nvim' | Should -BeTrue
            Test-PathInside -Path 'c:\users\me\appdata\local\NVIM\mynvim' -Parent 'C:\Users\me\AppData\Local\nvim\' | Should -BeTrue
            Test-PathInside -Path 'C:/a/nvim/mynvim' -Parent 'C:\a\nvim' | Should -BeTrue
        }

        It 'does not treat the same path or a sibling prefix as inside' {
            Test-PathInside -Path 'C:\a\nvim' -Parent 'C:\a\nvim' | Should -BeFalse
            Test-PathInside -Path 'C:\a\nvim2\mynvim' -Parent 'C:\a\nvim' | Should -BeFalse
            Test-PathInside -Path 'C:\Users\me\mynvim' -Parent 'C:\Users\me\AppData\Local\nvim' | Should -BeFalse
            Test-PathInside -Path '' -Parent 'C:\a' | Should -BeFalse
        }
    }

    Context 'Install-WingetPackage' {
        It 'DryRun only prints the winget command' {
            $output = Install-WingetPackage -Id 'zig.zig' -DryRun
            $output | Should -Be '+ winget install --id zig.zig -e --accept-source-agreements --accept-package-agreements'
            Should -Invoke Invoke-Winget -Times 0 -Exactly
            Should -Invoke Test-WingetPackageInstalled -Times 0 -Exactly
        }

        It 'skips an installed package' {
            Mock Test-WingetPackageInstalled { $true }
            Install-WingetPackage -Id 'Git.Git' | Out-Null
            Should -Invoke Invoke-Winget -Times 0 -Exactly
        }

        It 'installs a missing package with exact id' {
            Install-WingetPackage -Id 'Git.Git' | Out-Null
            Should -Invoke Invoke-Winget -Times 1 -Exactly -ParameterFilter {
                ($Arguments -join ' ') -eq 'install --id Git.Git -e --accept-source-agreements --accept-package-agreements'
            }
        }

        It 'throws when winget install fails' {
            Mock Invoke-Winget { $global:LASTEXITCODE = 1 }
            { Install-WingetPackage -Id 'Git.Git' } | Should -Throw
        }
    }

    Context 'Set-ConfigLink' {
        BeforeAll {
            # 테스트에서 만든 정션 목록 (AfterAll에서 링크 자체만 지운다)
            $CreatedLinks = New-Object System.Collections.ArrayList
        }

        AfterAll {
            # Pester가 TestDrive를 지우기 전에 정션 자체만 제거한다 (대상 디렉터리는 따라가지 않음)
            foreach ($link in $CreatedLinks) {
                try {
                    if ([System.IO.Directory]::Exists($link)) {
                        [System.IO.Directory]::Delete($link)
                    }
                } catch {
                    Write-Warning "정션 정리 실패: $link"
                }
            }
        }

        It 'junction created' -Skip:$NotWindows {
            $base = New-TestBase
            $source = Join-Path -Path $base -ChildPath 'repo'
            New-Item -ItemType Directory -Path $source | Out-Null
            # 부모 디렉터리가 없어도 만들어야 한다
            $target = Join-Path -Path $base -ChildPath 'local\nvim'
            [void]$CreatedLinks.Add($target)

            Set-ConfigLink -Source $source -Target $target | Out-Null

            (Get-Item -LiteralPath $target -Force).LinkType | Should -Be 'Junction'
        }

        It 'rerun keeps single backup' -Skip:$NotWindows {
            $base = New-TestBase
            $source = Join-Path -Path $base -ChildPath 'repo'
            New-Item -ItemType Directory -Path $source | Out-Null
            $target = Join-Path -Path $base -ChildPath 'nvim'
            New-Item -ItemType Directory -Path $target | Out-Null
            Set-Content -LiteralPath (Join-Path -Path $target -ChildPath 'init.lua') -Value 'old'
            [void]$CreatedLinks.Add($target)

            Set-ConfigLink -Source $source -Target $target | Out-Null
            $second = Set-ConfigLink -Source $source -Target $target

            ($second -join "`n") | Should -Match 'already linked'
            $backups = @(Get-ChildItem -LiteralPath $base -Force | Where-Object { $_.Name -like 'nvim.bak.*' })
            $backups.Count | Should -Be 1
            Test-Path -LiteralPath (Join-Path -Path $backups[0].FullName -ChildPath 'init.lua') | Should -BeTrue
            (Get-Item -LiteralPath $target -Force).LinkType | Should -Be 'Junction'
        }

        It 'path with spaces works' -Skip:$NotWindows {
            $base = New-TestBase
            $source = Join-Path -Path $base -ChildPath 'my repos\mynvim'
            New-Item -ItemType Directory -Path $source -Force | Out-Null
            $target = Join-Path -Path $base -ChildPath 'App Data\nvim'
            [void]$CreatedLinks.Add($target)

            Set-ConfigLink -Source $source -Target $target | Out-Null

            (Get-Item -LiteralPath $target -Force).LinkType | Should -Be 'Junction'
            Set-Content -LiteralPath (Join-Path -Path $source -ChildPath 'probe.txt') -Value 'x'
            Test-Path -LiteralPath (Join-Path -Path $target -ChildPath 'probe.txt') | Should -BeTrue
        }

        It 'target that is the source itself is already linked' -Skip:$NotWindows {
            $base = New-TestBase
            $source = Join-Path -Path $base -ChildPath 'nvim'
            New-Item -ItemType Directory -Path $source | Out-Null

            $output = Set-ConfigLink -Source $source -Target $source

            ($output -join "`n") | Should -Match 'already linked'
            (Get-Item -LiteralPath $source -Force).LinkType | Should -BeNullOrEmpty
            @(Get-ChildItem -LiteralPath $base -Force).Count | Should -Be 1
        }

        It 'dangling junction is backed up and replaced' -Skip:$NotWindows {
            $base = New-TestBase
            $source = Join-Path -Path $base -ChildPath 'repo'
            New-Item -ItemType Directory -Path $source | Out-Null
            $gone = Join-Path -Path $base -ChildPath 'gone'
            New-Item -ItemType Directory -Path $gone | Out-Null
            $target = Join-Path -Path $base -ChildPath 'nvim'
            New-Item -ItemType Junction -Path $target -Value $gone | Out-Null
            [void]$CreatedLinks.Add($target)
            Remove-Item -LiteralPath $gone -Recurse -Force

            Set-ConfigLink -Source $source -Target $target | Out-Null

            $backups = @(Get-ChildItem -LiteralPath $base -Force | Where-Object { $_.Name -like 'nvim.bak.*' })
            $backups.Count | Should -Be 1
            foreach ($backup in $backups) { [void]$CreatedLinks.Add($backup.FullName) }
            (Get-Item -LiteralPath $target -Force).LinkType | Should -Be 'Junction'
        }

        It 'does not overwrite an existing backup (adds -N suffix)' -Skip:$NotWindows {
            Mock Get-Date { '20260101-000000' }
            $base = New-TestBase
            $source = Join-Path -Path $base -ChildPath 'repo'
            New-Item -ItemType Directory -Path $source | Out-Null
            $target = Join-Path -Path $base -ChildPath 'nvim'
            New-Item -ItemType Directory -Path $target | Out-Null
            $existing = "$target.bak.20260101-000000"
            New-Item -ItemType Directory -Path $existing | Out-Null
            Set-Content -LiteralPath (Join-Path -Path $existing -ChildPath 'keep.txt') -Value 'keep'
            [void]$CreatedLinks.Add($target)

            Set-ConfigLink -Source $source -Target $target | Out-Null

            Test-Path -LiteralPath (Join-Path -Path $existing -ChildPath 'keep.txt') | Should -BeTrue
            Test-Path -LiteralPath "$target.bak.20260101-000000-1" -PathType Container | Should -BeTrue
            (Get-Item -LiteralPath $target -Force).LinkType | Should -Be 'Junction'
        }

        It 'repo cloned inside the target throws before moving anything' -Skip:$NotWindows {
            $base = New-TestBase
            $target = Join-Path -Path $base -ChildPath 'nvim'
            $source = Join-Path -Path $target -ChildPath 'mynvim'
            New-Item -ItemType Directory -Path $source -Force | Out-Null
            Set-Content -LiteralPath (Join-Path -Path $source -ChildPath 'init.lua') -Value 'repo'

            { Set-ConfigLink -Source $source -Target $target -DryRun } | Should -Throw '*안에 있습니다*'
            { Set-ConfigLink -Source $source -Target $target } | Should -Throw '*안에 있습니다*'

            (Get-Item -LiteralPath $target -Force).LinkType | Should -BeNullOrEmpty
            Test-Path -LiteralPath (Join-Path -Path $source -ChildPath 'init.lua') | Should -BeTrue
            @(Get-ChildItem -LiteralPath $base -Force | Where-Object { $_.Name -like 'nvim.bak.*' }).Count | Should -Be 0
        }

        It 'DryRun changes nothing' -Skip:$NotWindows {
            $base = New-TestBase
            $source = Join-Path -Path $base -ChildPath 'repo'
            New-Item -ItemType Directory -Path $source | Out-Null
            $target = Join-Path -Path $base -ChildPath 'nvim'
            New-Item -ItemType Directory -Path $target | Out-Null

            $output = Set-ConfigLink -Source $source -Target $target -DryRun

            ($output -join "`n") | Should -Match '\+ New-Item -ItemType Junction'
            # DryRun은 대상의 종류(파일/디렉터리)를 읽지 않으므로 중립적인 move 형식으로 출력한다
            ($output -join "`n") | Should -Match ([regex]::Escape("+ move `"$target`" -> `"$target.bak."))
            ($output -join "`n") | Should -Not -Match '\[IO\.'
            ($output -join "`n") | Should -Not -Match 'Move-Item'
            (Get-Item -LiteralPath $target -Force).LinkType | Should -BeNullOrEmpty
            @(Get-ChildItem -LiteralPath $base -Force | Where-Object { $_.Name -like 'nvim.bak.*' }).Count | Should -Be 0
        }
    }

    Context 'Set-ConfigLink DryRun (mocked)' {
        It 'DryRun backup does not read the entry kind of the target' {
            $base = New-TestBase
            $source = Join-Path -Path $base -ChildPath 'repo'
            New-Item -ItemType Directory -Path $source | Out-Null
            $target = Join-Path -Path $base -ChildPath 'nvim'
            # 대상은 있는 것으로, 백업 이름은 비어 있는 것으로 흉내 낸다 (실제 파일은 만들지 않음)
            Mock Get-LinkTargetPath { $null }
            Mock Test-PathEntry { $true } -ParameterFilter { $Path -eq $target }
            Mock Test-PathEntry { $false }
            Mock Get-PathEntryKind { throw 'DryRun에서 호출되면 안 됨' }
            Mock Move-PathEntry { }

            $output = Set-ConfigLink -Source $source -Target $target -DryRun

            ($output -join "`n") | Should -Match ([regex]::Escape("+ move `"$target`" -> `"$target.bak."))
            Should -Invoke Get-PathEntryKind -Times 0 -Exactly
            Should -Invoke Move-PathEntry -Times 0 -Exactly
        }
    }

    Context 'Get-NvimConfigTarget' {
        It 'empty LOCALAPPDATA throws a clear error' {
            $savedLocalAppData = $env:LOCALAPPDATA
            try {
                $env:LOCALAPPDATA = ''
                { Get-NvimConfigTarget } | Should -Throw '*LOCALAPPDATA*'
            } finally {
                $env:LOCALAPPDATA = $savedLocalAppData
            }
        }

        It 'returns LOCALAPPDATA\nvim' {
            $savedLocalAppData = $env:LOCALAPPDATA
            try {
                $env:LOCALAPPDATA = $TestDrive
                Get-NvimConfigTarget | Should -Be (Join-Path -Path $TestDrive -ChildPath 'nvim')
            } finally {
                $env:LOCALAPPDATA = $savedLocalAppData
            }
        }
    }

    Context 'Get-LinkTargetPath' {
        It 'returns $null when reading Target throws' {
            Mock Get-Item {
                $item = [pscustomobject]@{ LinkType = 'Junction' }
                $item | Add-Member -MemberType ScriptProperty -Name Target -Value { throw 'Target 읽기 실패' }
                $item
            }
            # -ErrorAction Stop: Target 읽기 오류가 새어 나오면 이 It이 실패한다
            $result = Get-LinkTargetPath -Path 'C:\nowhere\nvim' -ErrorAction Stop
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'nvim version' {
        It 'parses the first line of nvim --version' {
            ConvertTo-NvimVersion -Text 'NVIM v0.10.2' | Should -Be ([version]'0.10.2')
            ConvertTo-NvimVersion -Text 'NVIM v0.12.0-dev-1234+gabcdef' | Should -Be ([version]'0.12.0')
            ConvertTo-NvimVersion -Text 'something else' | Should -BeNullOrEmpty
        }

        It 'upgrades nvim older than 0.11' {
            Mock Get-NvimVersion { [version]'0.10.2' }
            Mock Update-SessionPath { }
            Update-OutdatedNvim | Out-Null
            Should -Invoke Invoke-Winget -Times 1 -Exactly -ParameterFilter {
                ($Arguments -join ' ') -eq 'upgrade --id Neovim.Neovim -e --accept-source-agreements --accept-package-agreements'
            }
            Should -Invoke Update-SessionPath -Times 1 -Exactly
        }

        It 'DryRun only prints the upgrade for nvim older than 0.11' {
            Mock Get-NvimVersion { [version]'0.10.2' }
            $output = Update-OutdatedNvim -DryRun
            ($output -join "`n") | Should -Match ([regex]::Escape('+ winget upgrade --id Neovim.Neovim -e --accept-source-agreements --accept-package-agreements'))
            Should -Invoke Invoke-Winget -Times 0 -Exactly
        }

        It 'warns and continues when winget upgrade fails (nvim installed outside winget)' {
            Mock Get-NvimVersion { [version]'0.10.2' }
            Mock Update-SessionPath { }
            # -1978335212(0x8A150014): winget이 설치된 패키지를 찾지 못함
            Mock Invoke-Winget { $global:LASTEXITCODE = -1978335212 }
            # 예외가 나면 이 It이 실패한다 (경고 스트림은 3>&1로 받는다)
            $output = Update-OutdatedNvim 3>&1
            $warnings = @($output | Where-Object { $_ -is [System.Management.Automation.WarningRecord] })
            $warnings.Count | Should -Be 1
            $warnings[0].Message | Should -Match ([regex]::Escape('winget upgrade --id Neovim.Neovim'))
            $warnings[0].Message | Should -Match '직접 0\.11 이상으로 올리세요'
            Should -Invoke Update-SessionPath -Times 1 -Exactly
        }

        It 'does not upgrade nvim 0.12.0' {
            Mock Get-NvimVersion { [version]'0.12.0' }
            Mock Update-SessionPath { }
            Update-OutdatedNvim | Out-Null
            Should -Invoke Invoke-Winget -Times 0 -Exactly
            Should -Invoke Update-SessionPath -Times 0 -Exactly
        }
    }

    Context 'Set-WeztermConfig' {
        It 'sets WEZTERM_CONFIG_FILE for the user' {
            $path = Join-Path -Path $TestDrive -ChildPath 'wezterm.lua'
            Set-WeztermConfig -Path $path | Out-Null
            Should -Invoke Set-UserEnvironmentVariable -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'WEZTERM_CONFIG_FILE' -and $Value -eq $path
            }
        }

        It 'DryRun only prints' {
            $path = Join-Path -Path $TestDrive -ChildPath 'wezterm.lua'
            $output = Set-WeztermConfig -Path $path -DryRun
            ($output -join "`n") | Should -Match 'WEZTERM_CONFIG_FILE'
            Should -Invoke Set-UserEnvironmentVariable -Times 0 -Exactly
        }
    }

    Context 'Main' {
        It 'DryRun prints winget ids' -Skip:$NotWindows {
            Mock Test-CommandAvailable { $true } -ParameterFilter { $Name -eq 'winget' }
            Mock Test-CommandAvailable { $false }
            Mock Set-ConfigLink { }

            $output = Main -With 'rust' -DryRun
            $text = $output -join "`n"

            $text | Should -Match 'Rustlang\.Rustup'
            $text | Should -Match 'zig\.zig'
            $text | Should -Match 'Neovim\.Neovim'
            $text | Should -Match 'Microsoft\.PowerShell'
            $text | Should -Not -Match 'GoLang\.Go'
            $text | Should -Match ([regex]::Escape('+ nvim --headless "+Lazy! sync" +qa'))
            Should -Invoke Invoke-Winget -Times 0 -Exactly
            Should -Invoke Set-ConfigLink -Times 1 -Exactly -ParameterFilter { $DryRun }
            Should -Invoke Set-UserEnvironmentVariable -Times 0 -Exactly
        }

        It 'repo inside the nvim target exits 1 before installing anything' {
            $savedLocalAppData = $env:LOCALAPPDATA
            try {
                $env:LOCALAPPDATA = New-TestBase
                # 레포가 %LOCALAPPDATA%\nvim\mynvim 에 clone된 상황
                Mock Get-RepoDir { Join-Path -Path (Join-Path -Path $env:LOCALAPPDATA -ChildPath 'nvim') -ChildPath 'mynvim' }
                Mock Exit-Script { throw "exit $Code" }
                Mock Test-CommandAvailable { $true }
                Mock Install-WingetPackage { }
                Mock Set-ConfigLink { }

                { Main -Yes -DryRun } | Should -Throw 'exit 1'

                Should -Invoke Exit-Script -Times 1 -Exactly -ParameterFilter { $Code -eq 1 }
                Should -Invoke Install-WingetPackage -Times 0 -Exactly
                Should -Invoke Set-ConfigLink -Times 0 -Exactly
            } finally {
                $env:LOCALAPPDATA = $savedLocalAppData
            }
        }

        It 'unknown component exits 2 even when the repo is inside the nvim target' {
            # install.sh와 같은 순서: 인자 검증(exit 2)이 사전 점검(exit 1)보다 먼저다
            $savedLocalAppData = $env:LOCALAPPDATA
            try {
                $env:LOCALAPPDATA = New-TestBase
                Mock Get-RepoDir { Join-Path -Path (Join-Path -Path $env:LOCALAPPDATA -ChildPath 'nvim') -ChildPath 'mynvim' }
                Mock Exit-Script { throw "exit $Code" }
                Mock Test-CommandAvailable { $true }
                Mock Install-WingetPackage { }
                Mock Set-ConfigLink { }

                { Main -With 'foo' -Yes -DryRun } | Should -Throw 'exit 2'

                Should -Invoke Exit-Script -Times 1 -Exactly -ParameterFilter { $Code -eq 2 }
                Should -Invoke Exit-Script -Times 0 -Exactly -ParameterFilter { $Code -eq 1 }
                Should -Invoke Install-WingetPackage -Times 0 -Exactly
            } finally {
                $env:LOCALAPPDATA = $savedLocalAppData
            }
        }

        It 'repo inside the nvim target exits 1 before prompting' {
            # 질문을 다 받은 뒤 거절하지 않도록, 대화형 질문은 사전 점검 뒤에 한다
            $savedLocalAppData = $env:LOCALAPPDATA
            try {
                $env:LOCALAPPDATA = New-TestBase
                Mock Get-RepoDir { Join-Path -Path (Join-Path -Path $env:LOCALAPPDATA -ChildPath 'nvim') -ChildPath 'mynvim' }
                Mock Exit-Script { throw "exit $Code" }
                Mock Test-InteractiveSession { $true }
                Mock Read-Host { 'y' }

                { Main -DryRun } | Should -Throw 'exit 1'

                Should -Invoke Read-Host -Times 0 -Exactly
            } finally {
                $env:LOCALAPPDATA = $savedLocalAppData
            }
        }

        It 'empty LOCALAPPDATA exits 1 with an install.ps1 error' {
            $savedLocalAppData = $env:LOCALAPPDATA
            try {
                $env:LOCALAPPDATA = ''
                Mock Exit-Script { throw "exit $Code" }
                Mock Install-WingetPackage { }
                Mock Set-ConfigLink { }

                { Main -Yes -DryRun } | Should -Throw 'exit 1'

                Should -Invoke Exit-Script -Times 1 -Exactly -ParameterFilter { $Code -eq 1 }
                Should -Invoke Install-WingetPackage -Times 0 -Exactly
            } finally {
                $env:LOCALAPPDATA = $savedLocalAppData
            }
        }

        It 'missing winget exits 1' -Skip:$NotWindows {
            # winget(WindowsApps)이 없는 PATH로 자식 프로세스를 실행한다
            # Windows PowerShell 5.1은 EAP=Stop일 때 2>&1로 받은 stderr 첫 줄을 종료 오류로 바꾸므로 이 블록에서만 Continue
            $ErrorActionPreference = 'Continue'
            $savedPath = $env:Path
            try {
                $env:Path = Join-Path -Path $env:SystemRoot -ChildPath 'System32'
                $output = & $PowerShellExe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $InstallScript -Yes -DryRun 2>&1
                $exitCode = $LASTEXITCODE
            } finally {
                $env:Path = $savedPath
            }
            $exitCode | Should -Be 1
            ($output | Out-String) | Should -Match 'aka\.ms/getwinget'
        }
    }
}
