# load function file
. "$PSScriptRoot\functions.ps1"

#Path to configuration file
$pathtocfg = Join-Path -Path $PSScriptRoot -ChildPath "config/configuration.cfg"

# Check if the configuration file exists if not create it in the correct format
if (Test-Path $pathtocfg -PathType Leaf) {

    # Load the XML file
    $emulatorxml = New-Object System.Xml.XmlDocument
    $emulatorxml.Load($pathtocfg)

} else {

    # Ask for backup location
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $backuplocation = New-Object -Typename System.Windows.Forms.FolderBrowserDialog
        $null = $backuplocation.ShowDialog() # Suppress output by redirecting to $null
        $backuplocation = $backuplocation.SelectedPath 
    }
    catch {
        <#Do this if a terminating exception happens#>
        $backuplocation = read-host -prompt "Enter a location to save the emulator"
    }

    # Create basic configuration file
    $emulatorxml = new-scriptcfg -pathtocfg $pathtocfg -pathtobackup ($backuplocation)
    $emulatorxml = New-Object System.Xml.XmlDocument
    $emulatorxml.Load($pathtocfg)
 
}

# Loop until the user exits
while ($true) {
    
    # Display the menu
    #Clear-Host
    Write-Host -ForegroundColor Yellow "
        Please select option:
        1. Backup saves 
        2. Restore saves 
        3. Add Emulator 
        4. Remove Emulator
        5. Show Emulators 
        6. Update Backup path
        7. Exit
    "
    switch ([System.Console]::ReadKey($true).KeyChar) {
        1 {
            Backup-EmulatorSaves -xmlDoc $emulatorxml -backup
        }
        2 {
            Backup-EmulatorSaves -xmlDoc $emulatorxml -restore
        }
        3 {
            add-emulator -xmlDoc $emulatorxml 
        }
        4 {
            remove-emulator -xmlDoc $emulatorxml 
        }
        5 {
            show-emulators -xmlDoc $emulatorxml 
        }
        6 {
            Update-scriptcfg -xmlDoc $emulatorxml 
        }
        7 {
            exit
        }
    }
        # Save the changes to the XML file
        $emulatorxml.Save($pathtocfg)
}