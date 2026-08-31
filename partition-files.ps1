$sourceDir = "C:\myDir"   # <-- change this
$batchSize = 5000

$files = Get-ChildItem -Path $sourceDir -File
$total = $files.Count

$folderIndex = 1
$targetFolder = $null

for ($i = 0; $i -lt $total; $i++) {

    if ($i % $batchSize -eq 0) {
        $targetFolder = Join-Path $sourceDir ("{0:D4}" -f $folderIndex)
        New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
        $folderIndex++
    }

    Move-Item $files[$i].FullName $targetFolder

    $percent = [int](($i + 1) / $total * 100)
    Write-Progress `
        -Activity "Partitioning files" `
        -Status "Processing file $($i+1) of $total" `
        -PercentComplete $percent

    if (($i + 1) % 1000 -eq 0) {
        Write-Host "Moved $($i+1) / $total files..."
    }
}

Write-Progress -Activity "Partitioning files" -Completed
Write-Host "Done. Total files processed: $total"