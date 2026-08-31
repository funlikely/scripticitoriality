param(
    [Parameter(Mandatory = $true)]
    [string]$path
)

# Ensure the path exists
if (-not (Test-Path $path)) {
    Write-Error "The folder path '$path' does not exist."
    exit
}

# Get all MP4 files in the folder, ordered by Last Modified date
$files = Get-ChildItem -Path $path -Filter "*.webm" | Sort-Object LastWriteTime

# Determine padding length (e.g., if 12 files → 2 digits, if 105 → 3 digits)
$padLength = [Math]::Max(2, [Math]::Ceiling([Math]::Log10([Math]::Max(1, $files.Count + 1))))

# Counter for numbering
$count = 1

foreach ($file in $files) {
    $paddedNum = $count.ToString("D$padLength")
    $newName = "{0} - {1}" -f $paddedNum, $file.Name
    $newFullPath = Join-Path -Path $file.DirectoryName -ChildPath $newName

    # Skip if already renamed or name already exists
    if ($file.Name -match '^\d+\s*-\s*') {
        Write-Host "Skipping '$($file.Name)' (already numbered)"
        continue
    }
    if (Test-Path -LiteralPath $newFullPath) {
        Write-Warning "A file named '$newName' already exists. Skipping."
        continue
    }

    try {
        Rename-Item -LiteralPath $file.FullName -NewName $newName -ErrorAction Stop
        Write-Host "Renamed: '$($file.Name)' → '$newName'"
    } catch {
        Write-Warning "Failed to rename '$($file.Name)': $_"
    }

    $count++
}