param (
    [string]$Path
)

if (-Not (Test-Path $Path)) {
    Write-Host "The specified path does not exist." -ForegroundColor Red
    exit
}

# Get all immediate subfolders
$folders = Get-ChildItem -Path $Path -Directory

# Output header
"{0,-60} {1,15}" -f "Folder", "Size (MB)"
"{0,-60} {1,15}" -f ("-"*60), ("-"*15)

foreach ($folder in $folders) {
    $folderSizeBytes = (Get-ChildItem -Path $folder.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $folderSizeMB = [math]::Round($folderSizeBytes / 1MB, 2)
    "{0,-60} {1,15}" -f $folder.Name, $folderSizeMB
}
