param (
    [Parameter(Mandatory = $true)]
    [string]$File,

    [Parameter(Mandatory = $true)]
    [string]$Time  # Format: "YYYY:MM:DD HH:MM:SS"
)

if (-not (Test-Path $File)) {
    Write-Error "File does not exist: $File"
    exit 1
}

function Show-ExifDates {
    param ([string]$Path)
    exiftool -FileModifyDate -FileCreateDate "$Path"
}

Write-Host "`n--- Before ---" -ForegroundColor Yellow -BackgroundColor Black
Show-ExifDates -Path $File
$command = "exiftool -overwrite_original `"-FileModifyDate=$Time`" `"-FileCreateDate=$Time`" `"$File`""

Write-Host "Running command: $command" -ForegroundColor Cyan -BackgroundColor DarkGreen
Invoke-Expression $command

Write-Host "`n--- After ---" -ForegroundColor Yellow -BackgroundColor Black
Show-ExifDates -Path $File
