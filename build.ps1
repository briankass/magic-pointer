New-Item -ItemType Directory -Force -Path src, src-tauri/src, src-tauri/icons | Out-Nullif ((Test-Path index.html) -and -not (Test-Path src/index.html)) {
Copy-Item index.html src/index.html
}
if (-not (Test-Path src/index.html)) {
Set-Content -Path src/index.html -Value 'Magic Pointer'
}Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap(32, 32)$g = [System.Drawing.Graphics]::FromImage($bmp)$g.Clear([System.Drawing.Color]::Orange)
$g.Dispose()$bmp.Save('src-tauri/icons/icon.png', [System.Drawing.Imaging.ImageFormat]::Png)
$icon = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
$fs = New-Object System.IO.FileStream('src-tauri/icons/icon.ico', [System.IO.FileMode]::Create)$icon.Save($fs)$fs.Close()$q = [char]34$toml = @(
'[package]',
('name = ' + $q + 'magic-pointer' +$q),
('version = ' + $q + '1.0.0' + $q),
('edition = ' + $q + '2021' +$q),
'[build-dependencies]',
('tauri-build = { version = ' + $q + '2' +$q + ', features = [] }'),
'[dependencies]',
('tauri = { version = ' + $q + '2' +$q + ', features = [] }'),
('serde = { version = ' + $q + '1.0' +$q + ', features = [' + $q + 'derive' +$q + '] }'),
('serde_json = ' + $q + '1.0' +$q)
)
Set-Content -Path src-tauri/Cargo.toml -Value $toml
Set-Content -Path src-tauri/build.rs -Value 'fn main() { tauri_build::build() }'$rs = @(
('#![cfg_attr(not(debug_assertions), windows_subsystem = ' + $q + 'windows' +$q + ')]'),
'fn main() {',
'  tauri::Builder::default().run(tauri::generate_context!()).unwrap();',
'}'
)
Set-Content -Path src-tauri/src/main.rs -Value $rs$conf = @{
productName = 'magic-pointer'
version = '1.0.0'
identifier = 'com.magicpointer.app'
build = @{ frontendDist = '../src' }
app = @{
withGlobalTauri = $true
windows = @(
@{
title = 'Magic Pointer'
width = 880
height = 620
decorations = $false
transparent = $true
visible = $true
alwaysOnTop = $true
}
)
security = @{ csp = $null }
}
} | ConvertTo-Json -Depth 6
Set-Content -Path src-tauri/tauri.conf.json -Value $confPush-Location src-tauri
cargo build --release
Pop-Location
