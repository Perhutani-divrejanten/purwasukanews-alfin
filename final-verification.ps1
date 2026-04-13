# Final Verification Script - Memastikan rebrand Purwasuka News selesai dengan baik

$WorkspaceRoot = $PSScriptRoot
$legacyBrandA = 'Indonesia' + ' Daily'
$legacyBrandB = 'indonesia' + 'daily'
$legacyBrandC = 'Indonesia' + 'Daily'
$legacyImage = 'logo' + '.png'
$requiredColors = @('#7E22CE', '#2E1065', '#1A5F6F')

Write-Host '========== FINAL VERIFICATION - PURWASUKA NEWS ==========' -ForegroundColor Cyan
Write-Host ''

$filesToCheck = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include '*.html', '*.css', '*.json', '*.md', '*.txt', '*.toml', '*.js', '*.ps1' -File |
    Where-Object { $_.FullName -notlike '*\node_modules\*' -and $_.FullName -notlike '*\.bak.*' }

$legacyHits = @()
foreach ($pattern in @($legacyBrandA, $legacyBrandB, $legacyBrandC)) {
    $legacyHits += $filesToCheck | Select-String -Pattern ([regex]::Escape($pattern)) -ErrorAction SilentlyContinue
}

$imageHits = $filesToCheck | Select-String -Pattern ([regex]::Escape($legacyImage)) -ErrorAction SilentlyContinue
$colorHits = @{}
foreach ($color in $requiredColors) {
    $colorHits[$color] = ($filesToCheck | Select-String -Pattern ([regex]::Escape($color)) -ErrorAction SilentlyContinue | Measure-Object).Count
}

$currentBrandHits = $filesToCheck | Select-String -Pattern 'Purwasuka News|PurwasukaNews|purwasukanews' -ErrorAction SilentlyContinue

Write-Host ('Files checked: ' + $filesToCheck.Count) -ForegroundColor White
Write-Host ('Legacy branding hits: ' + $legacyHits.Count) -ForegroundColor $(if ($legacyHits.Count -eq 0) { 'Green' } else { 'Yellow' })
Write-Host ('Legacy image hits   : ' + $imageHits.Count) -ForegroundColor $(if ($imageHits.Count -eq 0) { 'Green' } else { 'Yellow' })
Write-Host ('Current brand hits  : ' + $currentBrandHits.Count) -ForegroundColor $(if ($currentBrandHits.Count -gt 0) { 'Green' } else { 'Yellow' })
Write-Host ''

foreach ($color in $requiredColors) {
    Write-Host ("Color $color found: " + $colorHits[$color]) -ForegroundColor $(if ($colorHits[$color] -gt 0) { 'Green' } else { 'Yellow' })
}

Write-Host ''
if ($legacyHits.Count -eq 0 -and $imageHits.Count -eq 0 -and $currentBrandHits.Count -gt 0) {
    Write-Host 'Verification passed ✅' -ForegroundColor Green
} else {
    Write-Host 'Verification needs review ⚠️' -ForegroundColor Yellow
}

