function add-emulator {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Xml.XmlDocument]
        $xmlDoc
    )

    # Prompt the user for a name
    $name = Read-Host -Prompt "Enter a Emulator"

    try {
        Add-Type -AssemblyName System.Windows.Forms
        $savelocation = New-Object -Typename System.Windows.Forms.FolderBrowserDialog
        $null = $Savelocation.ShowDialog() # Suppress output by redirecting to $null
        $savelocation = $Savelocation.SelectedPath 
    }
    catch {
        <#Do this if a terminating exception happens#>
        $savelocation = read-host -prompt "Enter a location to save the emulator"
    }

    # Get the root element
    $root = $xmlDoc.DocumentElement

    # Create a new data block element
    $newDataBlock = $xmlDoc.CreateElement("Emulator")

    # Create the name element
    $nameElement = $xmlDoc.CreateElement("Name")
    $nameElement.InnerText = $name

    # Create the location element
    $locationElement = $xmlDoc.CreateElement("Location")
    $locationElement.InnerText = $savelocation

    # Add the name and location elements to the new data block
    $newDataBlock.AppendChild($nameElement)
    $newDataBlock.AppendChild($locationElement)

    # Add the new data block to the root element
    $root.AppendChild($newDataBlock)
    
    return ,$root 
}
function remove-emulator {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Xml.XmlDocument]
        $xmlDoc
    )

    # Get the root element
    $root = $xmlDoc.DocumentElement

    # Get all emulator elements
    $emulators = $root.GetElementsByTagName("Emulator")

    # Check if there are any emulators
    if ($emulators.Count -eq 0) {
        Write-Host "No emulators found"
        return
    }

    # Display the emulators with selectable numbers
    Write-Host "Select an emulator to remove:"
    for ($i = 0; $i -lt $emulators.Count; $i++) {
        $name = $emulators[$i].GetElementsByTagName("Name")[0].InnerText
        $location = $emulators[$i].GetElementsByTagName("Location")[0].InnerText
        Write-Host "$($i + 1): $name ($location)"
    }

    # Prompt the user for a selection
    do {
        $selection = Read-Host -Prompt "Enter the number of the emulator to remove"
    } until ($selection -ge 1 -and $selection -le $emulators.Count)

    # Remove the selected emulator
    $root.RemoveChild($emulators[$selection - 1])
}

function show-emulators {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Xml.XmlDocument]
        $xmlDoc
    )

    # Get the root element
    $root = $xmlDoc.DocumentElement

    # Get all emulator elements
    $emulators = $root.GetElementsByTagName("Emulator")

    # Check if there are any emulators
    if ($emulators.Count -eq 0) {
        Write-Host "No emulators found"
        return
    }

    # Display the emulators with selectable numbers
    Write-Host "List of configured Emulators:"
    for ($i = 0; $i -lt $emulators.Count; $i++) {
        $name = $emulators[$i].GetElementsByTagName("Name")[0].InnerText
        $location = $emulators[$i].GetElementsByTagName("Location")[0].InnerText
        Write-Host "$($i + 1): $name ($location)"
    }

    # Wait for keystroke
    Write-Host -ForegroundColor Red "Press any key to continue..."
    [System.Console]::ReadKey($true)
}

# backup Saves function not tested yet pleas dont use
function Backup-EmulatorSaves {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Xml.XmlDocument]
        $xmlDoc
    )

    # Get the root element
    $root = $xmlDoc.DocumentElement

    # Get all emulator elements
    $emulators = $root.GetElementsByTagName("Emulator")

    # Iterate through the emulator elements
    foreach ($emulator in $emulators) {
        # Get the name and location values
        $name = $emulator.GetElementsByTagName("Name")[0].InnerText
        $location = $emulator.GetElementsByTagName("Location")[0].InnerText

        # Display the name and location values
        Write-Host "Emulator: $name"
        Write-Host "Location: $location"

        # Check if the file exists
        if (Test-Path $location -PathType Container) {
            # Create the backup
            Compress-Archive -Path $location -DestinationPath (Join-Path -Path $Backupfolder -ChildPath "$name.zip")
        } else {
            Write-Host "File not found"
        }
    }
}

function Restore-EmulatorSaves {}

function Update-scriptcfg {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Xml.XmlDocument]
        $xmlDoc
    )

    Write-Output "Current Backup path: $($xmldoc.DataBlocks.Scriptconfig.Backupfolder)"
    Write-Output "Choose new Backup path"
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $path = New-Object -Typename System.Windows.Forms.FolderBrowserDialog
        $null = $path.ShowDialog() # Suppress output by redirecting to $null
        $path = $path.SelectedPath 
    }
    catch {
        <#Do this if a terminating exception happens#>
        $path = read-host -prompt "Enter a location to save the emulator"
    }
    # abort if no path is selected
    if ("" -ne $path) {
        # set selected folder as backup folder
        $xmldoc.DataBlocks.scriptconfig.backupfolder = $path
    }
}

# create basic configuration.cfg file
function new-scriptcfg {

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $pathtocfg,

        [Parameter()]
        [string]
        $pathtobackup
    )

    new-item -path (Join-Path -Path $PSScriptRoot -ChildPath "config") -itemtype directory 

    # Create a new XML documcent
    $emulatorxml = New-Object System.Xml.XmlDocument

    # Create the XML declaration
    $xmlDeclaration = $emulatorxml.CreateXmlDeclaration("1.0", "UTF-8", $null)

    # Append the XML declaration to the document
    $emulatorxml.AppendChild($xmlDeclaration)

    # Create the root element
    $root = $emulatorxml.CreateElement("DataBlocks")

    # Append the root element to the document
    $emulatorxml.AppendChild($root)

    # Get the root element
    $root = $emulatorxml.DocumentElement

    # Create a new data block element
    $newDataBlock = $emulatorxml.CreateElement("Scriptconfig")

    # Create the path element
    $pathElement = $emulatorxml.CreateElement("Backupfolder")
    $pathElement.InnerText = $pathtobackup

    # Add the name and location elements to the new data block
    $newDataBlock.AppendChild($pathElement)
    
    # Add the new data block to the root element
    $root.AppendChild($newDataBlock)

    # Append the root element to the document
    $emulatorxml.AppendChild($root)

    $emulatorxml.Save($pathtocfg)

}