# Backup location
$backuplocation = "P:\Memcards"

# Check if the backup location exists and create it if it does not
if (!(Test-Path $backuplocation)) {
    New-Item -ItemType Directory -Path $backuplocation | Out-Null
}

# Define an array of emulator names and save locations
$emulators = @(
    @{
        Name = "PCSX2 nightly"
        SaveLocation = "C:\Users\Claudio Schmid\Documents\PCSX2\memcards"
    },
    @{
        Name = "Dolphin GC"
        SaveLocation = "C:\Users\Claudio Schmid\Documents\Dolphin Emulator\GC"
    },
    @{
        Name = "Project64"
        SaveLocation = "C:\Program Files (x86)\Project64 2.3\Save"
    },
    @{
        Name = "CEMU"
        SaveLocation = "C:\Program Files\Cemu_2.0\mlc01"
    },
    @{
        Name = "RPCS3"
        SaveLocation = "C:\Program Files\RPCS3\dev_hdd0\home\00000001\savedata"
    }
)

# Function to backup emulator saves to backup location
function Backup-EmulatorSaves {
    param(
        [string]$backuplocation,
        [hashtable[]]$emulators
    )
    foreach ($emulator in $emulators) {
        $name = $emulator.Name
        $saveLocation = $emulator.SaveLocation
        Copy-Item -Path "$saveLocation" -Destination $backuplocation\$name -Recurse -Force
    }
}

# Function to restore emulator saves from backup location
function Restore-EmulatorSaves {
    param(
        [string]$backuplocation,
        [hashtable[]]$emulators
    )
    foreach ($emulator in $emulators) {
        $name = $emulator.Name
        $saveLocation = $emulator.SaveLocation
        Copy-Item -Path "$backuplocation\$name" -Destination $saveLocation -Recurse -Force
    }
}

# Prompt user to choose whether to backup or restore saves
$action = Read-Host "Enter 'backup' to backup saves or 'restore' to restore saves"

if ($action -eq "backup") {
    Backup-EmulatorSaves -backuplocation $backuplocation -emulators $emulators
}
elseif ($action -eq "restore") {
    Restore-EmulatorSaves -backuplocation $backuplocation -emulators $emulators
}
else {
    Write-Host "Invalid action. Please enter 'backup' or 'restore'."
}