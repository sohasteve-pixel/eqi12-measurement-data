$ErrorActionPreference='Continue'
$root='C:\EQi12_SSD_Idle_Evidence'
$before=docker stats --no-stream --format '{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}' 2>$null
$start=Get-Date
$counter=Get-Counter -Counter '\Processor(_Total)\% Processor Time','\Memory\Available MBytes' -SampleInterval 5 -MaxSamples 60
$rows=@()
foreach($set in $counter){
  $cpu=($set.CounterSamples|Where-Object Path -like '*processor(_total)*').CookedValue
  $free=($set.CounterSamples|Where-Object Path -like '*memory*available mbytes').CookedValue
  $rows+=[pscustomobject]@{Time=$set.Timestamp.ToString('o');CPUPercent=[math]::Round($cpu,2);AvailableMemoryMB=[math]::Round($free,0)}
}
$rows|Export-Csv "$root\04_LOW_OVERHEAD_IDLE_5MIN.csv" -NoTypeInformation -Encoding UTF8
$cpuStats=$rows.CPUPercent|Measure-Object -Average -Minimum -Maximum
$memStats=$rows.AvailableMemoryMB|Measure-Object -Average -Minimum -Maximum
$after=docker stats --no-stream --format '{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}' 2>$null
$health=docker ps --format '{{.Names}}|{{.Status}}|{{.Ports}}' 2>&1
$summary=@(
 'EQi12 LOW-OVERHEAD BACKGROUND RESOURCE SAMPLE',
 "Start: $($start.ToString('yyyy-MM-dd HH:mm:ss'))",
 "End: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))",
 'Method: one Windows performance-counter request, 60 samples x 5 seconds; no per-sample Docker polling.',
 "CPU avg/min/max: $([math]::Round($cpuStats.Average,2)) / $($cpuStats.Minimum) / $($cpuStats.Maximum) %",
 "Available RAM avg/min/max: $([math]::Round($memStats.Average,0)) / $($memStats.Minimum) / $($memStats.Maximum) MB",
 '', 'DOCKER BEFORE:',($before|Out-String),'DOCKER AFTER:',($after|Out-String),'CONTAINER HEALTH:',($health|Out-String),
 'Boundary: Windows, Codex and other resident desktop applications remained open; this is an unattended background-state sample, not a clean-boot OS idle measurement.'
)
$summary|Set-Content "$root\05_LOW_OVERHEAD_FINAL.txt" -Encoding UTF8
$summary
