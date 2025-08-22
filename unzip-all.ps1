param (
    [Parameter(Mandatory = $true)]
    [string]$RootPath,

    [string]$LogPath = "$PSScriptRoot\unzip-log.txt"
)

# Resolve and validate root path
try {
    $FullPath = (Resolve-Path -Path $RootPath).Path
} catch {
    Write-Error "Directory does not exist: $RootPath"
    exit 1
}

# Start logging
"=== Unzip Started: $(Get-Date) ===" | Out-File -FilePath $LogPath -Encoding UTF8 -Append

# Get all .zip files recursively
$zipFiles = Get-ChildItem -Path $FullPath -Recurse -Filter *.zip -File

if (-not $zipFiles) {
    "No zip files found under $FullPath" | Tee-Object -FilePath $LogPath -Append
    exit 0
}

foreach ($zip in $zipFiles) {
    $zipPath = $zip.FullName
    $zipName = [System.IO.Path]::GetFileNameWithoutExtension($zip.Name)
    $destination = Join-Path $zip.DirectoryName $zipName

    # Ensure the folder exists
    if (-not (Test-Path $destination)) {
        New-Item -ItemType Directory -Path $destination | Out-Null
    }

    $escapedZip = '"' + $zipPath + '"'
    $escapedDest = '-o"' + $destination + '"'
    $cmd = "7z x $escapedZip $escapedDest -y"

    # Print and log the command
    Write-Host ">> $cmd"
    ">> $cmd" | Out-File -FilePath $LogPath -Append

    try {
        # Run and capture output
        $output = & 7z x $zipPath $escapedDest -y 2>&1
        $output | Out-File -FilePath $LogPath -Append
    } catch {
        $errMsg = "ERROR extracting $zipPath $_"
        Write-Warning $errMsg
        $errMsg | Out-File -FilePath $LogPath -Append
    }
}

"=== Unzip Finished: $(Get-Date) ===`n" | Out-File -FilePath $LogPath -Append
