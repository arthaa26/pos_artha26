@echo off
echo ========================================
echo POS ARTHA26 - Migration to Drift Database
echo ========================================
echo.
echo [1/4] Cleaning project...
flutter clean
echo.
echo [2/4] Getting dependencies...
flutter pub get
echo.
echo [3/4] Generating Drift code...
dart run build_runner build --delete-conflicting-outputs
echo.
echo [4/4] Checking for errors...
dart analyze
echo.
echo ========================================
echo ✅ Setup complete! Ready to run.
echo ========================================
echo.
echo Next: flutter run
echo.
pause
