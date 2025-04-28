param (
    [Parameter(Mandatory = $true)]
    [string]$Path
)

# Resolve the full path
try {
    $resolvedPath = Resolve-Path -Path $Path -ErrorAction Stop
} catch {
    Write-Host "The specified path does not exist: $Path" -ForegroundColor Red
    exit 1
}

# Get all files in the given folder
$files = Get-ChildItem -Path $resolvedPath -File

# Sort files by name length (shortest first)
$sortedFiles = $files | Sort-Object { $_.Name.Length }

foreach ($file in $sortedFiles) {
    # Match files ending with _YYYY-MM-DD_HH-MM-SS.mp4
    if ($file.Name -match "^(.*)_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}\.mp4$") {
        $baseName = $matches[1]

        # Look for folders in the same directory
        $folders = Get-ChildItem -Path $resolvedPath -Directory | Where-Object {
            $_.Name.Length -ge 10 -and
            $baseName.StartsWith($_.Name)
        }

        if ($folders) {
            foreach ($folder in $folders) {
                Write-Host "This filename '$($file.Name)' matches folder '$($folder.Name)'"
            }
        } else {
            # No matching folder, create one
            $newFolderPath = Join-Path -Path $resolvedPath -ChildPath $baseName
            New-Item -Path $newFolderPath -ItemType Directory | Out-Null
            Write-Host "Created folder '$baseName'"
        }
    }
}
