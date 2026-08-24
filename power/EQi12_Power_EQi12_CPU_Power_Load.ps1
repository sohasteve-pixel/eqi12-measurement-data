$ErrorActionPreference='Stop'
$root='C:\EQi12_Power_Evidence'
New-Item -ItemType Directory -Path $root -Force|Out-Null
$pid|Set-Content "$root\CPU_LOAD_PID.txt"
"CPU load start: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"|Set-Content "$root\CPU_LOAD_LOG.txt"
Add-Type @'
using System;
using System.Collections.Generic;
using System.Threading;
public static class EQi12CpuBurn {
  public static void Run(int seconds) {
    DateTime end=DateTime.UtcNow.AddSeconds(seconds);
    var threads=new List<Thread>();
    for(int i=0;i<Environment.ProcessorCount;i++) {
      var t=new Thread(()=>{double x=0.123456789; while(DateTime.UtcNow<end){for(int n=1;n<200000;n++){x=Math.Sqrt(x+n);x=Math.Sin(x)+Math.Cos(x);} } GC.KeepAlive(x);});
      t.IsBackground=false; t.Priority=ThreadPriority.Normal; threads.Add(t); t.Start();
    }
    foreach(var t in threads)t.Join();
  }
}
'@
[EQi12CpuBurn]::Run(900)
"CPU load end: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"|Add-Content "$root\CPU_LOAD_LOG.txt"
