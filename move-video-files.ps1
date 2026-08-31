$src = "C:\from"
$dst = "C:\to"

$videoExt = @(
    ".mp4",".mkv",".avi",".mov",".wmv",
    ".flv",".webm",".m4v",".mpg",".mpeg",".ts"
)

Get-ChildItem $src -Recurse -File | Where-Object {
    $videoExt -contains $_.Extension.ToLower()
} | ForEach-Object {

    $relative = $_.FullName.Substring($src.Length)
    $target = Join-Path $dst $relative
    $dir = Split-Path $target

    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $final = $target
    $i = 1
    while (Test-Path $final) {
        $final = Join-Path $dir (
            [IO.Path]::GetFileNameWithoutExtension($target) + "_$i" + $_.Extension
        )
        $i++
    }

    Move-Item $_.FullName $final
}