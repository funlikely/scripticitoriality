param (
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Target
)

# Resolve full paths
try {
    $resolvedSource = Resolve-Path -Path $Source -ErrorAction Stop
    $resolvedTarget = Resolve-Path -Path $Target -ErrorAction Stop
} catch {
    Write-Host "Source or target path does not exist." -ForegroundColor Red
    exit 1
}

# Get all files in the source directory
$files = Get-ChildItem -Path $resolvedSource -File

# Sort files by name length (shortest first)
$sortedFiles = $files | Sort-Object { $_.Name.Length }

# Initialize counter
$counter = 0
$maxFiles = 250

foreach ($file in $sortedFiles) {
    # Stop if max files processed
    if ($counter -ge $maxFiles) {
        break
    }


    # Match files ending with _YYYY-MM-DD_HH-MM-SS.mp4
    if ($file.Name -match "^(.*)_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}\.mp4$") {
        $baseName = $matches[1]

        # Look for folders in the target directory
        $folders = Get-ChildItem -Path $resolvedTarget -Directory | Where-Object {
            $baseName.StartsWith($_.Name)
        }

        if ($folders) {
            # Pick the first matching folder
            $folder = $folders | Select-Object -First 1
            $destinationPath = Join-Path -Path $folder.FullName -ChildPath $file.Name
            Move-Item -Path $file.FullName -Destination $destinationPath
            Write-Host "Moved '$($file.Name)' into existing folder '$($folder.Name)'"
        } else {
            # No matching folder, create one in the target
            $newFolderPath = Join-Path -Path $resolvedTarget -ChildPath $baseName
            New-Item -Path $newFolderPath -ItemType Directory | Out-Null
            Write-Host "Created folder '$baseName' in target"

            # Move the file into the new folder
            $destinationPath = Join-Path -Path $newFolderPath -ChildPath $file.Name
            Move-Item -Path $file.FullName -Destination $destinationPath
            Write-Host "Moved '$($file.Name)' into newly created folder '$baseName'"
        }

        $counter++
    }
}
