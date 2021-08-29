# Bypass ESU

* A project to install Extended Security Updates for Windows 7 and Server 2008 R2

* It consist of three parts:

- patch WU engine to allow receiving ESU updates

- suppress ESU eligibility check for OS updates (including .NET 3.5.1)

- bypass ESU validation for .NET 4 updates (4.5.2 up to 4.8)

___
## Prerequisite Updates

for Live OS installation, the following updates must be installed and ready before using BypassESU:

- KB4490628: Servicing stack update, March 2019
x86
http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/03/windows6.1-kb4490628-x86_3cdb3df55b9cd7ef7fcb24fc4e237ea287ad0992.msu
x64
http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/03/windows6.1-kb4490628-x64_d3de52d6987f7c8bdc2c015dca69eac96047c76e.msu

- KB4474419: SHA-2 code signing support update, September 2019
x86
http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/09/windows6.1-kb4474419-v3-x86_0f687d50402790f340087c576886501b3223bec6.msu
x64
http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/09/windows6.1-kb4474419-v3-x64_b5614c6cea5cb4e198717789633dca16308ef79c.msu

- Latest Extended Servicing Stack Update, KB4555449 (May 2020) or later
x86
http://download.windowsupdate.com/c/msdownload/update/software/secu/2020/04/windows6.1-kb4555449-x86_36683b4af68408ed268246ee3e89772665572471.msu
x64
http://download.windowsupdate.com/c/msdownload/update/software/secu/2020/04/windows6.1-kb4555449-x64_92202202c3dee2f713f67adf6622851b998c6780.msu

- KB4575903: ESU Licensing Preparation Package (only required to get updates via WU)
x86
http://download.windowsupdate.com/d/msdownload/update/software/secu/2020/07/windows6.1-kb4575903-x86_5905c774f806205b5d25b04523bb716e1966306d.msu
x64
http://download.windowsupdate.com/d/msdownload/update/software/secu/2020/07/windows6.1-kb4575903-x64_b4d5cf045a03034201ff108c2802fa6ac79459a1.msu

- Updated Windows Update Client, at least KB3138612
x86
http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/02/windows6.1-kb3138612-x86_6e90531daffc13bc4e92ecea890e501e807c621f.msu
x64
http://download.windowsupdate.com/d/msdownload/update/software/updt/2016/02/windows6.1-kb3138612-x64_f7b1de8ea7cf8faf57b0138c4068d2e899e2b266.msu

if you installed any Monthly Quality Rollup, or July 2016 update rollup KB3172605, both already have updated WUC

if you installed January 2020 Security Only update KB4534314, or the fix update KB4539602, both already have updated WUC

___
## Important Notes:

* Make sure that "Windows Management Instrumentation (winmgmt)" service is not disabled

* For Live OS installation, it is recommended to install KB4538483 after WU ESU Patcher, or else a restart will be required

* After using WU patcher, if you still not offered the ESU updates, try to:

> reboot, then check WU

> stop wuauserv service, delete the folder "C:\Windows\SoftwareDistribution", reboot, then check WU

* You can also acquire and download the updates manually from Microsoft Update Catalog  
https://www.catalog.update.microsoft.com

to track the updates KB numbers, either check the official Update History page  
https://support.microsoft.com/en-us/help/4009469

or follow this MDL thread  
https://forums.mydigitallife.net/threads/19461/

* ESU updates for each month will require (at least) the latest extended SSU from previous month(s)  

e.g.  
April 2020 updates require March SSU at least  
May 2020 updates require April SSU at least  
June 2020 updates require May SSU at least  
July 2020 updates will require May SSU or June SSU (if any)  
and so on...

* Unless you integrate the ESU Suppressor, ESU updates are not supported offline (you cannot integrate them), they must be installed online on live system.

* Extract the 7z pack contents to a folder with simple path, example C:\files\BypassESU

* Temporarily turn off Antivirus protection (if any), or exclude the extracted folder

___
## How to Use - Live OS Installation

* Make sure to install the prerequisite updates (reboot if required)

* right-click on LiveOS-Setup.cmd and "Run as administrator"  

* from the menu, press the corresponding number for the desired option:

[1] Full Installation {ESU Suppressor + WU ESU Patcher + .NET 4 ESU Bypass}  
most recommended option

[2] Install ESU Suppressor
mainly for security-only updates users, whom don't need the Monthly Rollup through WU

[3] Install WU ESU Patcher
this only allow to offer ESU updates via WU

[7] Install .NET 4 ESU Bypass  
this allow to install NDP4 ESU updates (manually or via WU)

* Remarks:

- LiveOS-Setup.cmd will remove BypassESU-v4 if detected, and override other previous versions if present

- You get option [1] only if all Suppressor/Patcher/.NET Bypass are not installed

- ESU Suppressor cannot be uninstalled after installing ESU updates, and option [5] is not shown in that case

- Warning: unless you have another bypass installed, ESU updates installation will fail if you used option [3] alone

___
## How to Use - Offline Image/Wim Integration

* Wim-Integration.cmd support two target types to integrate BypassESU:

[1] Direct WIM file (not mounted), either install.wim or boot.wim

[2] Already Mounted image directory, or offline image deployed on another partition/drive/vhd

___
** Direct WIM file integration **

- place install.wim or boot.wim (one of them, not both) next to Wim-Integration.cmd, then run the script as administrator

- alternatively, run the script as administrator, and when prompted, enter the full path for the wim file

- choose the desired option from the menu (similar to live setup)

- Notes about this method:  

it will also integrate the Suppressor for winre.wim, if it exists inside install.wim  

it does not provide options to remove the Suppressor/Patcher/.NET Bypass, for that, mount the wim image then use second method

___
** Mounted directory / offline image integration **

- manually mount the image of install.wim or boot.wim  
no need for this step if the image is already deployed on another partition/drive/vhd, example Z:\

- No need to integrate the prerequisite updates, you can integrate BypassESU first

- right-click on Wim-Integration.cmd and "Run as administrator"

- enter the correct path for mounted directory or offline image drive letter

- choose the desired option from the menu (similar to live setup)

- afterwards, continue to integrate the updates, including ESU updates

- manually unmount install.wim/boot.wim image and commit changes

___
## Credits

* IMI Kurwica  
- mspaintmsi (superUser)  
* abbodi1406 (Project scripts)
