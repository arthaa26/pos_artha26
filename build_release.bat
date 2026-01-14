@echo off
echo Starting Flutter Release Build...
echo.

cd /d "%~dp0"

echo Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo Clean failed with error code %errorlevel%
    pause
    exit /b %errorlevel%
)

echo.
echo Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Pub get failed with error code %errorlevel%
    pause
    exit /b %errorlevel%
)

echo.
echo Building APK release...
flutter build apk --release --verbose
if %errorlevel% neq 0 (
    echo Build failed with error code %errorlevel%
    echo.
    echo Common solutions:
    echo 1. Check if Android SDK is properly installed
    echo 2. Ensure JAVA_HOME is set correctly
    echo 3. Try flutter doctor to check environment
    echo 4. Check if all dependencies are compatible
    pause
    exit /b %errorlevel%
)

echo.
echo Build completed successfully!
echo APK location: build\app\outputs\flutter-apk\app-release.apk
pause