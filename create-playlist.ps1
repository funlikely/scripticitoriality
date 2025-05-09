param (
    [Parameter(Mandatory = $true)]
    [string]$Path
)

# Validate the path
if (-Not (Test-Path $Path)) {
    Write-Error "The specified path does not exist."
    exit
}

# Get video files in directory (non-recursive)
$videoFiles = Get-ChildItem -Path $Path

if ($videoFiles.Count -eq 0) {
    Write-Error "No video files found in $Path"
    exit
}

# Shuffle
$shuffled = $videoFiles | Get-Random -Count $videoFiles.Count

# Output file path
$playlistPath = Join-Path -Path $Path -ChildPath "playlist.txt"

# Clear previous playlist if exists
Remove-Item -Path $playlistPath -ErrorAction SilentlyContinue

# Write playlist.txt in FFmpeg format
$shuffled | ForEach-Object {
    $filePath = $_.FullName.Replace('\', '/')
    Add-Content -Path $playlistPath -Value "file '$filePath'"
}

Write-Host "Playlist created at: $playlistPath"
