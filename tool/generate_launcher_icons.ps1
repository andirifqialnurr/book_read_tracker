param(
    [string]$SourcePath = "book-stack.png"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$resolvedSource = Resolve-Path $SourcePath

function Save-ResizedPng {
    param(
        [string]$TargetPath,
        [int]$Width,
        [int]$Height,
        [System.Drawing.Color]$BackgroundColor = [System.Drawing.Color]::Transparent
    )

    $targetDirectory = Split-Path -Parent $TargetPath
    if (-not (Test-Path $targetDirectory)) {
        New-Item -ItemType Directory -Force $targetDirectory | Out-Null
    }

    $source = [System.Drawing.Image]::FromFile($resolvedSource)
    try {
        $canvas = New-Object System.Drawing.Bitmap $Width, $Height
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($canvas)
            try {
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.Clear($BackgroundColor)
                $graphics.DrawImage($source, 0, 0, $Width, $Height)
            } finally {
                $graphics.Dispose()
            }

            $canvas.Save($TargetPath, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $canvas.Dispose()
        }
    } finally {
        $source.Dispose()
    }
}

$androidIcons = @{
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png" = 48
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" = 72
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" = 96
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" = 144
    "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" = 192
}

foreach ($entry in $androidIcons.GetEnumerator()) {
    Save-ResizedPng -TargetPath $entry.Key -Width $entry.Value -Height $entry.Value
}

$webIcons = @{
    "web/favicon.png" = 32
    "web/icons/Icon-192.png" = 192
    "web/icons/Icon-512.png" = 512
    "web/icons/Icon-maskable-192.png" = 192
    "web/icons/Icon-maskable-512.png" = 512
}

foreach ($entry in $webIcons.GetEnumerator()) {
    Save-ResizedPng -TargetPath $entry.Key -Width $entry.Value -Height $entry.Value
}

$iosContentsPath = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json"
if (Test-Path $iosContentsPath) {
    $iosBackground = [System.Drawing.Color]::FromArgb(255, 250, 246, 215)
    $iosContents = Get-Content -Raw $iosContentsPath | ConvertFrom-Json
    foreach ($image in $iosContents.images) {
        $size = [double](($image.size -split "x")[0])
        $scale = [int](($image.scale -replace "x", ""))
        $pixels = [int][Math]::Round($size * $scale)
        $target = Join-Path "ios/Runner/Assets.xcassets/AppIcon.appiconset" $image.filename
        Save-ResizedPng -TargetPath $target -Width $pixels -Height $pixels -BackgroundColor $iosBackground
    }
}

Write-Host "Launcher icons generated from $resolvedSource"
