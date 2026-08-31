param(
    [Parameter(Mandatory=$true)]
    [string]$sourceDirectory,

    [Parameter(Mandatory=$true)]
    [double]$minLength,

    [Parameter(Mandatory=$true)]
    [double]$maxLength,

    [Parameter(Mandatory=$true)]
    [string]$targetDirectory
)

# ---- CONFIG ----
$ffprobePath = "ffprobe"   # change if ffprobe is not in PATH

# Common video extensions
$videoExtensions = @(
    "*.mp4","*.mkv","*.avi","*.mov","*.wmv","*.flv","*.webm","*.m4v"
)

# ---- VALIDATION ----
if (!(Test-Path $sourceDirectory)) {
    Write-Error "Source directory does not exist."
    exit
}

if (!(Test-Path $targetDirectory)) {
    Write-Host "Creating target directory..."
    New-Item -ItemType Directory -Path $targetDirectory | Out-Null
}

if ($minLength -gt $maxLength) {
    Write-Error "minLength cannot be greater than maxLength."
    exit
}

Write-Host "Scanning videos in: $sourceDirectory"
Write-Host "Keeping videos between $minLength and $maxLength seconds"
Write-Host ""

# ---- GET VIDEO FILES ----
$files = foreach ($ext in $videoExtensions) {
    Get-ChildItem -Path $sourceDirectory -Filter $ext -File -Recurse
}

$total = $files.Count
$index = 0

foreach ($file in $files) {
    $index++
    Write-Host "[$index/$total] Checking: $($file.Name)"

    try {
        # --- GET DURATION (robust version) ---

        function Get-VideoDurationSeconds($filePath) {
            
            # Try container duration first
            $out = & $ffprobePath `
                -v error `
                -show_entries format=duration `
                -of csv=p=0 `
                "$filePath" 2>$null

            $value = ($out | Select-Object -First 1).ToString().Trim()

            # If numeric → use it
            if ($value -match '^\d+(\.\d+)?$') {
                return [double]::Parse($value, [cultureinfo]::InvariantCulture)
            }

            # Fallback: try video stream duration
            $out = & $ffprobePath `
                -v error `
                -select_streams v:0 `
                -show_entries stream=duration `
                -of csv=p=0 `
                "$filePath" 2>$null

            $value = ($out | Select-Object -First 1).ToString().Trim()

            if ($value -match '^\d+(\.\d+)?$') {
                return [double]::Parse($value, [cultureinfo]::InvariantCulture)
            }

            return $null
        }

        $durationSeconds = Get-VideoDurationSeconds $file.FullName

        # Check range
        if ($durationSeconds -ge $minLength -and $durationSeconds -le $maxLength) {

            
            $destPath = Join-Path $targetDirectory $file.Name
            Copy-Item -LiteralPath $file.FullName -Destination $targetDirectory -Force -ErrorAction Stop

            # Now check the file itself
            $fullDestPath = Join-Path $targetDirectory $file.Name

            if (Test-Path -LiteralPath $fullDestPath) {
                Write-Host "Copy confirmed"
            }
            else {
                Write-Warning "Copy failed"
            }

        }
        else {
            Write-Host "  -> Skipped ($([math]::Round($durationSeconds,2))s)"
        }
    }
    catch {
        Write-Warning "Error processing $($file.Name): $_"
    }
}

Write-Host ""
Write-Host "Done."