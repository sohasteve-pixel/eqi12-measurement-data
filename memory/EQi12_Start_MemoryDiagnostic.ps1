$ErrorActionPreference='Stop'
$root='C:\EQi12_MemoryDiagnostic_Evidence'
New-Item -ItemType Directory -Path $root -Force|Out-Null
$log="$root\01_SCHEDULE_LOG.txt"
@(
 'EQi12 Windows Memory Diagnostic',
 "Schedule time: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))",
 "Computer: $env:COMPUTERNAME",
 'Mode: Windows Memory Diagnostic standard test'
)|Set-Content $log -Encoding UTF8

& bcdedit.exe /enum '{memdiag}' 2>&1|Add-Content $log
& bcdedit.exe /bootsequence '{memdiag}' 2>&1|Add-Content $log
$code=$LASTEXITCODE
"BCDEdit exit code: $code"|Add-Content $log
if($code-ne0){throw "Failed to schedule Windows Memory Diagnostic; bcdedit exit code $code"}
'Memory diagnostic scheduled. Restart in 20 seconds.'|Add-Content $log
shutdown.exe /r /t 20 /c "EQi12 Windows Memory Diagnostic"
