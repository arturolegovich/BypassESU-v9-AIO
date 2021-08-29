@echo off
if "%~1"=="" goto :eof
@setlocal DisableDelayedExpansion
set "target=%~1"
set "targen=%~nx1"
@cls
echo.
echo ____________________________________________________________
echo.
echo Checking . . .
echo.

wimlib-imagex info "%target%" 1 2>nul | find /i "760" 1>nul || (
echo.
echo %_err%
echo Specified wim is not Windows NT 6.1
goto :TheEnd
)

set "IFEO=HKLM\wSOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
set "_SxS=HKLM\wSOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Winners"
set "_Cmp=HKLM\wCOMPONENTS\DerivedData\Components"
set "_OurVer=6.1.7603.25000"
set "xOS=x86"
set "xPA=x86"
set "xBE=bbe32.exe"
set "xSL=sle32.dll"
set "xMS=msiesu32.dll"
set "_EsuKey=%_SxS%\x86_microsoft-windows-s..edsecurityupdatesai_31bf3856ad364e35_none_b26c9b4c15d241fc"
set "_EsuCom=x86_microsoft-windows-s..edsecurityupdatesai_31bf3856ad364e35_6.1.7603.25000_none_6eb019927ae880f2"
set "_EsuIdn=4D6963726F736F66742D57696E646F77732D534C432D436F6D706F6E656E742D457874656E64656453656375726974795570646174657341492C2043756C747572653D6E65757472616C2C2056657273696F6E3D362E312E373630332E32353030302C205075626C69634B6579546F6B656E3D333162663338353661643336346533352C2050726F636573736F724172636869746563747572653D7838362C2076657273696F6E53636F70653D4E6F6E537853"
set "_EsuHsh=343B7E8DE2FE932E2FA1DB0CDFE69BB648BEE8E834B41728F1C83A12C1766ECB"
wimlib-imagex info "%target%" 1 2>nul | find /i "x86_64" 1>nul && (
set "xOS=x64"
set "xPA=amd64"
set "xBE=bbe64.exe"
set "xSL=sle64.dll"
set "xMS=msiesu64.dll"
set "_EsuKey=%_SxS%\amd64_microsoft-windows-s..edsecurityupdatesai_31bf3856ad364e35_none_0e8b36cfce2fb332"
set "_EsuCom=amd64_microsoft-windows-s..edsecurityupdatesai_31bf3856ad364e35_6.1.7603.25000_none_caceb5163345f228"
set "_EsuIdn=4D6963726F736F66742D57696E646F77732D534C432D436F6D706F6E656E742D457874656E64656453656375726974795570646174657341492C2043756C747572653D6E65757472616C2C2056657273696F6E3D362E312E373630332E32353030302C205075626C69634B6579546F6B656E3D333162663338353661643336346533352C2050726F636573736F724172636869746563747572653D616D6436342C2076657273696F6E53636F70653D4E6F6E537853"
set "_EsuHsh=45D0AE442FD92CE32EE1DDC38EA3B875EAD9A53D6A17155A10FA9D9E16BEDEB2"
)

set _SrvrC=0
wimlib-imagex dir "%target%" 1 --path=Windows\Servicing\Packages 2>nul | find /i "Microsoft-Windows-ServerCore-Package" 1>nul && set _SrvrC=1

set _Embed=0
wimlib-imagex dir "%target%" 1 --path=Windows\Servicing\Packages 2>nul | find /i "WinEmb-" 1>nul && set _Embed=1

set _WinPE=0
wimlib-imagex dir "%target%" 1 --path=sources\recovery\RecEnv.exe 1>nul 2>nul && set _WinPE=1

set _Winre=0
wimlib-imagex dir "%target%" 1 --path=Windows\System32\Recovery\winre.wim 1>nul 2>nul && set _Winre=1

set _WuEsu=0
wimlib-imagex dir "%target%" 1 --path=Windows\WuEsu\bbe.exe 1>nul 2>nul && set _WuEsu=1

set _WiEsu=0
wimlib-imagex dir "%target%" 1 --path=Windows\System32\msiesu.dll 1>nul 2>nul && set _WiEsu=1

set _EsuPkg=0
wimlib-imagex dir "%target%" 1 --path=Windows\WinSxS\Manifests\%_EsuCom%.manifest 1>nul 2>nul && set _EsuPkg=1

:MainMenu
set _elr=0
set _dowu=0
@cls
echo ____________________________________________________________
echo.
if %_EsuPkg% equ 0 if %_WinPE% equ 0 if %_WuEsu% equ 0 if %_WiEsu% equ 0 (
echo [1] Full Integration {ESU Suppressor + WU ESU Patcher + .NET 4 ESU Bypass}
echo.
)
if %_EsuPkg% equ 0 (
echo [2] Integrate ESU Suppressor
echo.
)
if %_WinPE% equ 0 if %_WuEsu% equ 0 (
echo [3] Integrate WU ESU Patcher
echo.
)
if %_WinPE% equ 0 if %_WiEsu% equ 0 (
echo [7] Integrate .NET 4 ESU Bypass
echo.
)
echo [9] Exit
echo.
echo ____________________________________________________________
echo.
choice /C 12379 /N /M "Choose a menu option: "
set _elr=%errorlevel%
if %_elr%==5 exit
if %_elr%==4 if %_WinPE% equ 0 if %_WiEsu% equ 0 (goto :wimWI)
if %_elr%==3 if %_WinPE% equ 0 if %_WuEsu% equ 0 (goto :wimWU)
if %_elr%==2 if %_EsuPkg% equ 0 (goto :wimESU)
if %_elr%==1 if %_EsuPkg% equ 0 if %_WinPE% equ 0 if %_WuEsu% equ 0 if %_WiEsu% equ 0 (set _dowu=1&goto :wimESU)
goto :MainMenu

:wimESU
@cls
echo.
echo ____________________________________________________________
echo.
echo Integrating ESU Suppressor . . .
echo.
echo %targen%
for /f "tokens=3 delims=: " %%# in ('wimlib-imagex info "%target%" ^| findstr /i /c:"Image Count"') do set imgcount=%%#
for /L %%# in (1,1,%imgcount%) do (
echo index %%#/%imgcount%
call :WIMt %%# 1>nul 2>nul
)

if %_Winre% equ 0 if %_dowu% equ 1 goto :wimWU
if %_Winre% equ 0 if %_dowu% equ 0 (
echo.
echo Done.
goto :TheEnd
)

echo.
echo ____________________________________________________________
echo.
echo Processing "winre.wim" . . .
echo.
echo extracting
wimlib-imagex extract "%target%" 1 Windows\System32\Recovery\winre.wim --dest-dir=.\re --no-acls --no-attributes 1>nul 2>nul
echo integrating
set "source=%target%"
set "target=re\winre.wim"
set _WinPE=1
call :WIMt 1 1>nul 2>nul
echo re-adding
for /L %%# in (1,1,%imgcount%) do (
wimlib-imagex update "%source%" %%# --command="add 're\winre.wim' '\Windows\System32\Recovery\winre.wim'" 1>nul 2>nul
)
if exist re\ rmdir /s /q re\
set "target=%source%"
if %_dowu% equ 1 goto :wimWU
echo.
echo Done.
goto :TheEnd

:WIMt
set "_EsuFnd=windowsfoundation_31bf3856ad364e35_6.1.7601.17514_615fdfe2a739474c"
if %_WinPE% equ 1 set "_EsuFnd=winpe_31bf3856ad364e35_6.1.7601.17514_b103c6caf44fb2e9"
if %_Embed% equ 1 set "_EsuFnd=windowsembe..dfoundation_31bf3856ad364e35_6.1.7601.17514_b791db78a3ca92ca"
if %_SrvrC% equ 1 set "_EsuFnd=windowsserverfoundation_31bf3856ad364e35_6.1.7601.17514_1767904420c89fad"
if /i "%xPA%"=="x86" (
set "_EsuFnd=windowsfoundation_31bf3856ad364e35_6.1.7601.17514_0541445eeedbd616"
if %_WinPE% equ 1 set "_EsuFnd=winpe_31bf3856ad364e35_6.1.7601.17514_54e52b473bf241b3"
if %_Embed% equ 1 set "_EsuFnd=windowsembe..dfoundation_31bf3856ad364e35_6.1.7601.17514_5b733ff4eb6d2194"
)
wimlib-imagex extract "%target%" %1 \Windows\System32\config\COMPONENTS \Windows\System32\config\SOFTWARE --dest-dir=.\temp
reg load HKLM\wCOMPONENTS "temp\COMPONENTS"
reg load HKLM\wSOFTWARE "temp\SOFTWARE"
reg delete "%_Cmp%\%_EsuCom%" /f
reg add "%_Cmp%\%_EsuCom%" /f /v "c!%_EsuFnd%" /t REG_BINARY /d ""
reg add "%_Cmp%\%_EsuCom%" /f /v identity /t REG_BINARY /d "%_EsuIdn%"
reg add "%_Cmp%\%_EsuCom%" /f /v S256H /t REG_BINARY /d "%_EsuHsh%"
reg add "%_EsuKey%" /f /ve /d %_OurVer:~0,3%
reg add "%_EsuKey%\%_OurVer:~0,3%" /f /ve /d %_OurVer%
reg add "%_EsuKey%\%_OurVer:~0,3%" /f /v %_OurVer% /t REG_BINARY /d 01
reg unload HKLM\wCOMPONENTS
reg unload HKLM\wSOFTWARE
type nul>wimupdt.txt
>>wimupdt.txt echo add '%_EsuCom%.manifest' '\Windows\WinSxS\Manifests\%_EsuCom%.manifest'
>>wimupdt.txt echo add 'temp\COMPONENTS' '\Windows\System32\config\COMPONENTS'
>>wimupdt.txt echo add 'temp\SOFTWARE' '\Windows\System32\config\SOFTWARE'
wimlib-imagex update "%target%" %1 < wimupdt.txt
del /f /q wimupdt.txt
rmdir /s /q .\temp
exit /b

:wimWU
if %_dowu% equ 0 (
@cls
)
echo.
echo ____________________________________________________________
echo.
echo Integrating WU ESU Patcher . . .
echo.
echo %targen%
for /L %%# in (1,1,%imgcount%) do (
echo index %%#/%imgcount%
call :wimDoWU %%# 1>nul 2>nul
)
if %_dowu% equ 1 goto :wimWI
echo.
echo Done.
goto :TheEnd

:wimDoWU
if exist tsk\ rmdir /s /q tsk\
mkdir tsk
copy /y PatchWU.xml "tsk\Patch WU ESU"
icacls tsk\ /restore PatchWU.txt
wimlib-imagex extract "%target%" %1 \Windows\System32\config\SOFTWARE --dest-dir=.\temp
reg load HKLM\wSOFTWARE "temp\SOFTWARE"
reg import PatchWU.reg
reg unload HKLM\wSOFTWARE
type nul>wimupdt.txt
>>wimupdt.txt echo add 'PatchWU.cmd' '\Windows\WuEsu\PatchWU.cmd'
>>wimupdt.txt echo add '%xBE%' '\Windows\WuEsu\bbe.exe'
>>wimupdt.txt echo add '%xSL%' '\Windows\System32\sle.dll'
>>wimupdt.txt echo add 'tsk\Patch WU ESU' '\Windows\System32\Tasks\Patch WU ESU'
>>wimupdt.txt echo add 'temp\SOFTWARE' '\Windows\System32\config\SOFTWARE'
wimlib-imagex update "%target%" %1 < wimupdt.txt
del /f /q wimupdt.txt
rmdir /s /q .\temp
rmdir /s /q .\tsk
exit /b

:wimWI
if %_dowu% equ 0 (
@cls
)
echo.
echo ____________________________________________________________
echo.
echo Integrating .NET 4 ESU Bypass . . .
echo.
echo %targen%
for /L %%# in (1,1,%imgcount%) do (
echo index %%#/%imgcount%
call :wimDoWI %%# 1>nul 2>nul
)
echo.
echo Done.
goto :TheEnd

:wimDoWI
wimlib-imagex extract "%target%" %1 \Windows\System32\config\SOFTWARE --dest-dir=.\temp
reg load HKLM\wSOFTWARE "temp\SOFTWARE"
reg delete "%IFEO%\msiexec.exe" /f
reg add "%IFEO%\msiexec.exe" /f /v VerifierDlls /t REG_SZ /d msiesu.dll
reg add "%IFEO%\msiexec.exe" /f /v VerifierDebug /t REG_DWORD /d 0x00000000
reg add "%IFEO%\msiexec.exe" /f /v VerifierFlags /t REG_DWORD /d 0x80000000
reg add "%IFEO%\msiexec.exe" /f /v GlobalFlag /t REG_DWORD /d 0x00000100
reg unload HKLM\wSOFTWARE
type nul>wimupdt.txt
>>wimupdt.txt echo add '%xMS%' '\Windows\System32\msiesu.dll'
>>wimupdt.txt echo add 'temp\SOFTWARE' '\Windows\System32\config\SOFTWARE'
if %xOS%==x64 (
>>wimupdt.txt echo add 'msiesu32.dll' '\Windows\SysWOW64\msiesu.dll'
)
wimlib-imagex update "%target%" %1 < wimupdt.txt
del /f /q wimupdt.txt
rmdir /s /q .\temp
exit /b

:TheEnd
goto :eof
