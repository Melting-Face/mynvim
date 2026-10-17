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
            $output = & $PowerShellExe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $InstallScript -With foo -DryRun 2>&1
            $LASTEXITCODE | Should -Be 2
            ($output | Out-String) | Should -Match 'foo'
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

        It 'DryRun changes nothing' -Skip:$NotWindows {
            $base = New-TestBase
            $source = Join-Path -Path $base -ChildPath 'repo'
            New-Item -ItemType Directory -Path $source | Out-Null
            $target = Join-Path -Path $base -ChildPath 'nvim'
            New-Item -ItemType Directory -Path $target | Out-Null

            $output = Set-ConfigLink -Source $source -Target $target -DryRun

            ($output -join "`n") | Should -Match '\+ New-Item -ItemType Junction'
            (Get-Item -LiteralPath $target -Force).LinkType | Should -BeNullOrEmpty
            @(Get-ChildItem -LiteralPath $base -Force | Where-Object { $_.Name -like 'nvim.bak.*' }).Count | Should -Be 0
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
            $text | Should -Not -Match 'GoLang\.Go'
            $text | Should -Match ([regex]::Escape('+ nvim --headless "+Lazy! sync" +qa'))
            Should -Invoke Invoke-Winget -Times 0 -Exactly
            Should -Invoke Set-ConfigLink -Times 1 -Exactly -ParameterFilter { $DryRun }
            Should -Invoke Set-UserEnvironmentVariable -Times 0 -Exactly
        }

        It 'missing winget exits 1' -Skip:$NotWindows {
            # winget(WindowsApps)이 없는 PATH로 자식 프로세스를 실행한다
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
