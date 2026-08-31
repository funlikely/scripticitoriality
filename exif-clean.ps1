
# removes exif data from files in a directory


param (
    [Parameter(Mandatory = $true)]
    [string]$Path
)

# Resolve and validate the path
$FullPath = Resolve-Path -Path $Path -ErrorAction Stop

if (-not (Test-Path $FullPath -PathType Container)) {
    Write-Error "Provided path is not a directory."
    exit 1
}

Push-Location $FullPath

try {
    # Run exiftool on all files in the folder (non-recursive, matches your command)
    exiftool -all= -overwrite_original -r .
}
finally {
    Pop-Location
}

