@echo off
pushd "%~dp0"

for /d %%d in (*) do (
    if exist "%%d\students\students\students.csproj" set "BACKEND=%%d\students\students"
    if exist "%%d\my_app\pubspec.yaml" set "FRONTEND=%%d\my_app"
)

echo Starting Backend Server...
start "GavAkademy - Backend" /d "%BACKEND%" cmd /k dotnet run

echo Waiting 5 seconds for server to start...
timeout /t 5 /nobreak > nul

echo Starting Flutter Web (Chrome)...
start "GavAkademy - Flutter" /d "%FRONTEND%" cmd /k flutter run -d chrome --web-port=5000

pause
