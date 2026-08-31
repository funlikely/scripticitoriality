param (
    [Parameter(Mandatory=$true)]
    [string]$inputTextFilePath,

    [Parameter(Mandatory=$true)]
    [string]$directoryPath
)

# --- validate paths ---
if (-not (Test-Path $inputTextFilePath)) {
    Write-Error "Input text file not found: $inputTextFilePath"
    exit 1
}

if (-not (Test-Path $directoryPath)) {
    Write-Error "Directory not found: $directoryPath"
    exit 1
}

# --- function to normalize characters ---
# --- normalize: keep only letters + numbers ---
function Normalize-Text {
    param([string]$text)

    if ($null -eq $text) { return "" }

    return ($text.Trim() -replace '[^a-su-zA-SU-Z0-9]', '').ToLower()
}

# --- read input file ---
$inputFiles 

# --- read input file into list ---
$inputFiles = Get-Content $inputTextFilePath |
    Where-Object { $_.Trim() -ne "" } |
    ForEach-Object { Normalize-Text $_ }

# --- read directory files into list ---
$directoryFiles = Get-ChildItem -Path $directoryPath -File |
    ForEach-Object { Normalize-Text $_.Name }

# --- compare lists ---
$missingFiles = $inputFiles | Where-Object { $_ -notin $directoryFiles }



# --- test test test ---
Write-Output "inputFiles files:"
$inputFiles
Write-Output "directoryFiles files:"
$directoryFiles


# --- output results ---
if ($missingFiles.Count -eq 0) {
    Write-Output "All files exist in directory."
}
else {
    Write-Output "Missing files:"
    $missingFiles
    Write-Output ""
    Write-Output "Total missing files: $($missingFiles.Count)"
}