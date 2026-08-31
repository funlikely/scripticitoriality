param (
    [Parameter(Mandatory=$true)]
    [string]$directoryPath,

    [switch]$deleteThese
)

if (-Not (Test-Path $directoryPath)) {
    Write-Error "Directory '$directoryPath' does not exist."
    exit
}

# Get all files in the directory
$files = Get-ChildItem -Path $directoryPath -File -Recurse

# Group files by 'base name' and size
$grouped = @{}

foreach ($file in $files) {
    # Remove (1), (2), etc. from the filename
    $baseName = [regex]::Replace($file.BaseName, '\s*\(\d+\)$', '')
    $key = "$baseName|$($file.Length)"
    
    if (-not $grouped.ContainsKey($key)) {
        $grouped[$key] = @()
    }
    $grouped[$key] += $file
}

$duplicateCount = 0
foreach ($entry in $grouped.GetEnumerator()) {
    $fileGroup = $entry.Value
    if ($fileGroup.Count -gt 1) {
        # Identify duplicates (files with suffixes like (1), (2), etc.)
        $original = $fileGroup | Where-Object { $_.BaseName -notmatch '\(\d+\)$' } | Select-Object -First 1
        $duplicates = $fileGroup | Where-Object { $_.BaseName -match '\(\d+\)$' }

        if ($duplicates.Count -gt 0) {
            $duplicateCount = $duplicateCount + 1
            Write-Output "Original: $($original.FullName)"
            foreach ($dup in $duplicates) {
                Write-Output "Duplicate: $($dup.FullName)"
                if ($deleteThese.IsPresent) {
                    Remove-Item $dup.FullName -Force
                    Write-Output "Deleted: $($dup.Name)"
                }
            }
            Write-Output "----"
        }
        
    }
}
Write-Output "Duplicate count: $($duplicateCount)"
