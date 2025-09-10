param(
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(Mandatory=$true)]
    [datetime]$NewDate
)

if (-not (Test-Path $Path)) {
    Write-Error "File not found: $Path"
    exit 1
}

try {
    $file = Get-Item -LiteralPath $Path
    $file.CreationTime     = $NewDate
    $file.LastWriteTime    = $NewDate
    $file.LastAccessTime   = $NewDate

    Write-Host "Timestamps updated for $Path"
    Write-Host "  CreationTime:   $($file.CreationTime)"
    Write-Host "  LastWriteTime:  $($file.LastWriteTime)"
    Write-Host "  LastAccessTime: $($file.LastAccessTime)"
}
catch {
    Write-Error "Failed to update timestamps: $_"
}
