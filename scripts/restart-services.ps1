# Restart script for Innovia IoT services
# Run this after CORS changes or other code updates

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Restarting Innovia IoT Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n⚠️  Press Ctrl+C in each terminal window to stop the services first." -ForegroundColor Yellow
Write-Host "Then run these commands in separate terminals:" -ForegroundColor Yellow

Write-Host "`n📋 Terminal 1 - DeviceRegistry.Api:" -ForegroundColor Green
Write-Host "cd src\DeviceRegistry.Api; dotnet run" -ForegroundColor White

Write-Host "`n📋 Terminal 2 - Ingest.Gateway:" -ForegroundColor Green
Write-Host "cd src\Ingest.Gateway; dotnet run" -ForegroundColor White

Write-Host "`n📋 Terminal 3 - Realtime.Hub:" -ForegroundColor Green
Write-Host "cd src\Realtime.Hub; dotnet run" -ForegroundColor White

Write-Host "`n📋 Terminal 4 - Portal.Adapter:" -ForegroundColor Green
Write-Host "cd src\Portal.Adapter; dotnet run" -ForegroundColor White

Write-Host "`n📋 Terminal 5 - Edge.Simulator:" -ForegroundColor Green
Write-Host "cd src\Edge.Simulator; dotnet run" -ForegroundColor White

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CORS is now configured for Angular!" -ForegroundColor Green
Write-Host "Allowed origins:" -ForegroundColor Yellow
Write-Host "  - http://localhost:4200" -ForegroundColor White
Write-Host "  - http://127.0.0.1:4200" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan
