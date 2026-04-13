# Script untuk memastikan semua navbar-brand memakai text-based logo Purwasuka News

$WorkspaceRoot = $PSScriptRoot
$htmlFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include '*.html' -File

$textBasedLogo = @"
<span style="font-weight: bold; color: #7E22CE; font-size: 24px; letter-spacing: -0.5px;">PURWASUKA<span style="color: #1A5F6F; font-weight: normal; font-size: 18px; margin-left: 2px;">NEWS</span></span>
"@

$replaceCount = 0
$legacyLogoToken = [regex]::Escape(('logo' + '.png'))
$legacyLogoPattern = '<img[^>]*src="[^\"]*' + $legacyLogoToken + '"[^>]*>'

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $newContent = $content -replace $legacyLogoPattern, $textBasedLogo

        if ($newContent -ne $content) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
            $replaceCount++
            Write-Host "Updated logo in: $($file.Name)"
        }
    } catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ''
Write-Host 'Logo replacement complete!'
Write-Host ('Total files updated: ' + $replaceCount)
