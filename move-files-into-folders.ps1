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

Write-Host "number of files: $($sortedFiles.length)"

# Initialize counter
$counter = 0
$maxFiles = 200

foreach ($file in $sortedFiles) {
    # Stop if max files processed
    if ($counter -ge $maxFiles) {
        Write-Host "Break, processed number of files: '$($counter)'"
        break
    }

    # Match files ending with _YYYY-MM-DD_HH-MM-SS_collage.jpg
    if ($file.Name -match "^(.*)_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}_collage\.jpg$") {
        $baseName = $matches[1]

        # Look for folders in the target directory
        $folders = Get-ChildItem -Path $resolvedTarget -Directory | Where-Object {
            $baseName.StartsWith($_.Name)
        }

        if ($folders) {
            # Pick the first matching folder
            $folder = $folders | Select-Object -First 1

            # Ensure the thumbnails subfolder exists
            $thumbnailsPath = Join-Path -Path $folder.FullName -ChildPath "thumbnails"
            if (-Not (Test-Path $thumbnailsPath)) {
                New-Item -Path $thumbnailsPath -ItemType Directory | Out-Null
                Write-Host "Created 'thumbnails' folder inside '$($folder.Name)'"
            }
            else {
                Write-Host "Found 'thumbnails' folder inside '$($folder.Name)'"
            }
            
            # Move the file into the thumbnails folder
            $destinationPath = Join-Path -Path $thumbnailsPath -ChildPath $file.Name
            Move-Item -Path $file.FullName -Destination $destinationPath
            Write-Host "Moved '$($file.Name)' into folder '$($destinationPath)'"


        } else {
            # No matching folder
            Write-Host "No matching folder for '$($file.Name)'"
        }

        $counter++
    } else {
        
        Write-Host "Things are dumb. Filename  '$($file.Name)'"
        $counter++
    }
}
