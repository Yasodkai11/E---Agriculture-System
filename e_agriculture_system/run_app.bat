@echo off
echo Starting E-Agriculture System...
cd /d "%~dp0"
flutter clean
flutter pub get
flutter run -d chrome --web-port=54753
pause
