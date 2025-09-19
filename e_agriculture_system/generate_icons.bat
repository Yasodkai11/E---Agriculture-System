@echo off
echo 🌾 E-Agriculture System Icon Generator
echo ========================================

echo.
echo This script will help you generate app icons for your Flutter project.
echo.
echo Before running this script, you need to:
echo 1. Install Python (if not already installed)
echo 2. Install required packages: pip install cairosvg Pillow
echo 3. Have your base icon design ready
echo.

echo Press any key to continue or Ctrl+C to cancel...
pause >nul

echo.
echo Running Python icon generator...
python generate_icons.py

echo.
echo Icon generation process completed!
echo.
echo Next steps:
echo 1. Run: flutter clean
echo 2. Run: flutter pub get  
echo 3. Run: flutter run --debug
echo.
pause
