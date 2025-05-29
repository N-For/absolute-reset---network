@echo off
echo Начинается абсолютный сброс сетевых настроек...

taskkill /F /IM explorer.exe
cls

route -f
netsh int tcp reset
netsh advfirewall reset
netcfg -d
netsh int ipv6 reset
netsh int ip reset
ipconfig /flushdns
netsh int ip reset c:resetlog.txt
netsh winsock reset

netsh wlan delete profile name=*
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /f

ipconfig /release
ipconfig /renew

netsh interface set interface "Ethernet" admin=disable
netsh interface set interface "Ethernet" admin=enable
netsh interface set interface "Wi-Fi" admin=disable
netsh interface set interface "Wi-Fi" admin=enable

certutil -urlcache * delete
arp -d *

netsh advfirewall set allprofiles state off
netsh advfirewall set allprofiles state on

del /q /f %windir%\temp\*.*
del /q /f %windir%\Prefetch\*.*

sc config dhcp start= auto
sc config dnscache start= auto
sc config netprofm start= auto
sc config nsi start= auto
net start dhcp
net start dnscache
net start netprofm
net start nsi



echo Очистка кэша и куки основных браузеров...
rem Chrome
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cookies"

rem Firefox
rd /s /q "%APPDATA%\Mozilla\Firefox\Profiles\*.default-release\cache2"
rd /s /q "%APPDATA%\Mozilla\Firefox\Profiles\*.default-release\cookies.sqlite"

rem Edge
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache"
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cookies"

echo Очистка файла подкачки...
wmic pagefile list /format:list
wmic pagefileset where name="C:\\pagefile.sys" delete
wmic pagefileset create name="C:\\pagefile.sys"

echo Очистка временных файлов и кэша системы...
rd /s /q %TEMP%
rd /s /q %LOCALAPPDATA%\Temp

echo Сброс настроек DNS...
ipconfig /flushdns
netsh int ip set dns name="Ethernet" source=dhcp
netsh int ip set dns name="Wi-Fi" source=dhcp

echo Очистка журналов событий Windows...
wevtutil cl Application
wevtutil cl System
wevtutil cl Security

echo Сброс настроек PowerShell и командной строки...
reg delete "HKCU\Software\Microsoft\Command Processor" /v AutoRun /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f

echo Очистка кэша обновлений Windows...
net stop wuauserv
rd /s /q %windir%\SoftwareDistribution
net start wuauserv

echo Сброс настроек приложения "Почта" и "Календарь"...
rd /s /q %LOCALAPPDATA%\Comms
rd /s /q %LOCALAPPDATA%\Microsoft\WindowsMail


start explorer
timeout 22
shutdown /r