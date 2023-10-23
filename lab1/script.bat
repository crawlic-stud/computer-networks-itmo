@echo off

echo Available interfaces:
netsh interface ip show config | find "Configuration for interface"

echo ------------------------------------------------
set /P interface=Enter interface you want to change:

set /P automatic=Do you want to configure settings of "%interface%" automatically? (y/n):

if "%automatic%"=="y" (
  echo Configuring IPv4, Subnet Mask, Default Gateway and DNS through DHCP...
  netsh interface ipv4 set address %interface% dhcp
  netsh interface ipv4 set dns %interface% dhcp

) else if "%automatic%"=="n" (
  set /p myipv4=Enter IPV4: 
  set /p mask=Enter Mask: 
  set /p gateway=Enter Gateway: 
  set /p mydns=Enter DNS: 

  echo ------------------------------------------------
  echo Setting provided values...

  netsh interface ip set address name=%interface% static address="%myipv4%" mask="%mask%" gateway="%gateway%" 
  netsh interface ip set dns name=%interface% static "%mydns%" validate=no

) else (
  echo Abort.
)

echo ------------------------------------------------
echo Your settings after:
ipconfig /all
@REM netsh interface ip show addresses %interface%
@REM netsh interface ip show dns %interface%

rem revert all back
@REM netsh interface ip set address %interface% dhcp
@REM netsh interface ip set dns %interface% dhcp
