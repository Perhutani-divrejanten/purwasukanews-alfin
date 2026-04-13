$ErrorActionPreference = 'Stop'

$WorkspaceRoot = $PSScriptRoot
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Save-Utf8 {
    param(
        [string]$Path,
        [string]$Content
    )

    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Normalize-HtmlText {
    param([string]$Text)

    $Text = $Text.Replace([string][char]0x201C, '"')
    $Text = $Text.Replace([string][char]0x201D, '"')
    $Text = $Text.Replace([string][char]0x2018, "'")
    $Text = $Text.Replace([string][char]0x2019, "'")
    $Text = $Text.Replace([string][char]0x2013, '-')
    $Text = $Text.Replace([string][char]0x2014, '-')
    $Text = $Text.Replace([string][char]0xFFFD, ' ')
    $Text = $Text.Replace([string][char]0x00A0, ' ')
    return $Text
}

$articlesPath = Join-Path $WorkspaceRoot 'articles.json'
$backupPath = Join-Path $WorkspaceRoot 'articles.json.bak'
if (Test-Path $articlesPath) {
    Copy-Item $articlesPath $backupPath -Force
    Write-Host ('Backup dibuat: ' + $backupPath) -ForegroundColor Green
}

$mainPages = 0
$articlePages = 0

Get-ChildItem -Path $WorkspaceRoot -Recurse -Include *.html -File | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)
    $normalized = Normalize-HtmlText $content
    Save-Utf8 -Path $_.FullName -Content $normalized

    if ($_.DirectoryName -like '*\article') {
        $articlePages++
    } else {
        $mainPages++
    }
}

$cssCount = (Get-ChildItem -Path (Join-Path $WorkspaceRoot 'css') -Filter *.css -File -ErrorAction SilentlyContinue | Measure-Object).Count
$packageCount = @(
    (Join-Path $WorkspaceRoot 'package.json'),
    (Join-Path $WorkspaceRoot 'package-lock.json'),
    (Join-Path $WorkspaceRoot 'tools\package.json'),
    (Join-Path $WorkspaceRoot 'tools\sites-config.json')
) | Where-Object { Test-Path $_ } | Measure-Object | Select-Object -ExpandProperty Count
$docsCount = (Get-ChildItem -Path $WorkspaceRoot -Recurse -Include *.md,*.txt,*.toml,*.ps1 -File |
    Where-Object { $_.Name -ne 'rebrand-purwasuka-news.ps1' } | Measure-Object).Count

Write-Host ''
Write-Host 'Langkah eksekusi PowerShell:' -ForegroundColor Yellow
Write-Host '1. Backup `articles.json` ke `articles.json.bak`' -ForegroundColor White
Write-Host '2. Jalankan normalisasi UTF-8 untuk HTML dengan pola:' -ForegroundColor White
Write-Host '   Get-ChildItem -Recurse -Include *.html | ForEach-Object { ... }' -ForegroundColor Gray
Write-Host ''
Write-Host 'Jumlah file yang diproses:' -ForegroundColor Yellow
Write-Host ('- main pages   : ' + $mainPages)
Write-Host ('- article pages: ' + $articlePages)
Write-Host ('- css          : ' + $cssCount)
Write-Host ('- package      : ' + $packageCount)
Write-Host ('- docs         : ' + $docsCount)
Write-Host ''
Write-Host 'Rebrand Purwasuka News selesai ✅' -ForegroundColor Green
