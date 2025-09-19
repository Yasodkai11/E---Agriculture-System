# E-Agriculture System Startup Script
Write-Host "Starting E-Agriculture System..." -ForegroundColor Green

# Change to script directory
Set-Location $PSScriptRoot

# Clean and get dependencies
Write-Host "Cleaning project..." -ForegroundColor Yellow
flutter clean

Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Run the app
Write-Host "Starting Flutter web app..." -ForegroundColor Green
flutter run -d chrome --web-port=54753

Write-Host "App startup complete!" -ForegroundColor Green
