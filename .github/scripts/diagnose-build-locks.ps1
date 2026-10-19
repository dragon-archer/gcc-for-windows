$ErrorActionPreference = 'Continue'
$logDir = Join-Path $env:GITHUB_WORKSPACE 'artifacts/logs'
New-Item -ItemType Directory -Force $logDir | Out-Null

& {
    $root = [System.IO.Path]::GetFullPath($env:GFW_BUILD_ROOT)
    Write-Output "Build root: $root"
    $buildDirs = @(
        Get-ChildItem "$root/src" -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like '*build*' }
        Get-ChildItem $root -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { Get-Item "$($_.FullName)/build" -ErrorAction SilentlyContinue }
    )
    foreach ($buildDir in $buildDirs) {
        $paths = @($buildDir) + @(
            Get-ChildItem $buildDir.FullName -Directory -Force |
                Where-Object { $_.Name -eq 'gcc' -or $_.Name -like '*-gcc' }
        )
        foreach ($path in $paths) {
            $path | Format-List FullName, Attributes, LinkType, Target
            Get-Acl $path.FullName | Format-List Path, Owner, AccessToString
        }
        foreach ($marker in 'stage_current', 'stage_last') {
            $path = Join-Path $buildDir.FullName $marker
            if (Test-Path $path) {
                Write-Output "${path}:"
                Get-Content $path
            }
        }
    }
    Get-CimInstance Win32_Process |
        Where-Object { $_.ExecutablePath -like '*gcc-build*' -or $_.Name -match '^(make|bash|sh|gcc|g\+\+|xgcc|xg\+\+|cc1.*|collect2|ld|as|lto.*)\.exe$' } |
        Format-List ProcessId, ParentProcessId, ExecutablePath, CommandLine
    $archive = Join-Path $env:RUNNER_TEMP 'Handle.zip'
    $tools = Join-Path $env:RUNNER_TEMP 'gfw-handle'
    Invoke-WebRequest 'https://download.sysinternals.com/files/Handle.zip' -OutFile $archive
    Expand-Archive $archive -DestinationPath $tools -Force
    & "$tools/handle64.exe" -accepteula -nobanner $root
} *>&1 | Tee-Object -FilePath "$logDir/build-locks.log"
