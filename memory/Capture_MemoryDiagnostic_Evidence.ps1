$ErrorActionPreference='Stop'
Add-Type @'
using System;using System.Runtime.InteropServices;
public static class MemDiagCap{[DllImport("user32.dll")]public static extern bool ShowWindow(IntPtr h,int c);[DllImport("user32.dll")]public static extern bool SetForegroundWindow(IntPtr h);[DllImport("user32.dll")]public static extern bool GetWindowRect(IntPtr h,out RECT r);[DllImport("user32.dll")]public static extern bool SetCursorPos(int x,int y);[DllImport("user32.dll")]public static extern void mouse_event(uint f,uint x,uint y,uint d,UIntPtr e);public struct RECT{public int Left,Top,Right,Bottom;}}
'@
Add-Type -AssemblyName System.Drawing
$shell=New-Object -ComObject WScript.Shell
$ise='C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe'
Get-Process|Where-Object {$_.MainWindowTitle -match 'Codex|ChatGPT' -and $_.MainWindowHandle -ne 0}|ForEach-Object {[void][MemDiagCap]::ShowWindow($_.MainWindowHandle,6)}
$p=Start-Process $ise -ArgumentList '-File','C:\EQi12_MemoryDiagnostic_Evidence\05_FINAL_SUMMARY.txt' -PassThru
$deadline=(Get-Date).AddSeconds(15)
while($p.MainWindowHandle -eq 0 -and (Get-Date)-lt$deadline){Start-Sleep -Milliseconds 400;$p.Refresh()}
if($p.MainWindowHandle -eq 0){throw 'ISE window not found'}
[void][MemDiagCap]::ShowWindow($p.MainWindowHandle,3);[void][MemDiagCap]::SetForegroundWindow($p.MainWindowHandle);[void]$shell.AppActivate($p.Id);Start-Sleep 2
[MemDiagCap+RECT]$r=New-Object MemDiagCap+RECT;[void][MemDiagCap]::GetWindowRect($p.MainWindowHandle,[ref]$r)
[void][MemDiagCap]::SetCursorPos($r.Left+500,$r.Top+180);[MemDiagCap]::mouse_event(2,0,0,0,[UIntPtr]::Zero);[MemDiagCap]::mouse_event(4,0,0,0,[UIntPtr]::Zero);[void]$shell.SendKeys('^{HOME}');Start-Sleep 2
$w=[int](($r.Right-$r.Left)*0.72);$h=430;$b=New-Object System.Drawing.Bitmap $w,$h;$g=[System.Drawing.Graphics]::FromImage($b);$g.CopyFromScreen($r.Left+8,$r.Top+75,0,0,$b.Size);$b.Save('C:\EQi12_MemoryDiagnostic_Evidence\Screenshot_MemoryDiagnostic_Result_Raw.png',[System.Drawing.Imaging.ImageFormat]::Png);$g.Dispose();$b.Dispose();Stop-Process -Id $p.Id -Force
