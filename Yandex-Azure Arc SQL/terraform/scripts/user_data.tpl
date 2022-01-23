#ps1
net user ${admin_user} ${admin_password}
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
Enable-PSRemoting -SkipNetworkProfileCheck -Force
Set-MpPreference -DisableRealtimeMonitoring $true
netsh advfirewall set  allprofiles state off
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
net stop winrm
sc.exe config winrm start=auto
net start winrm
Rename-Computer -NewName '${hostname}' -Force
Restart-Computer -Force
