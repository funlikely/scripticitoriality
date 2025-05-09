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

$command = "exiftool -overwrite_original `"-FileModifyDate=$Time`" `"-FileAccessDate=$Time`" `"-FileCreateDate=$Time`" `"$File`""

Write-Host "Running command: $command"
Invoke-Expression $command
