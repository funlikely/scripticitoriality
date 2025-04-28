param (
    [Parameter(Mandatory = $true)]
    [string]$Path
)

# Resolve to full path from relative or absolute
try {
    $resolvedPath = Resolve-Path -Path $Path -ErrorAction Stop
} catch {
    Write-Host "The specified path does not exist: $Path" -ForegroundColor Red
    exit 1
}

# Get all immediate subfolders
$folders = Get-ChildItem -Path $resolvedPath -Directory

# Output header
"{0,-60} {1,15}" -f "Folder", "Size (MB)"
"{0,-60} {1,15}" -f ("-"*80), ("-"*15)

foreach ($folder in $folders) {
    $folderSizeBytes = (Get-ChildItem -Path $folder.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $folderSizeMB = [math]::Round($folderSizeBytes / 1MB, 2)
    "{0,-60} {1,15}" -f $folder.Name, $folderSizeMB
}
