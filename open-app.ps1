# Script to open the application in browser
# Since NodePort doesn't work well with Docker Desktop on Windows,
# we'll use port-forwarding which works reliably

Write-Host "🚀 Opening Sample Web App..." -ForegroundColor Cyan
Write-Host ""

# Check if port-forward is already running
$portForwardRunning = Get-Process -Name kubectl -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*port-forward*8080*"
}

if (-not $portForwardRunning) {
    Write-Host "📡 Starting port-forward..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl port-forward service/sample-web-app-service 8080:80" -WindowStyle Minimized
    Start-Sleep -Seconds 3
}

Write-Host "✅ Application is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Opening browser at: http://localhost:8080" -ForegroundColor Cyan
Start-Sleep -Seconds 2

# Open browser
Start-Process "http://localhost:8080"

Write-Host ""
Write-Host "📝 Note: The port-forward window is minimized. Close it when done." -ForegroundColor Yellow
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor White
Write-Host "  • View pods:     kubectl get pods" -ForegroundColor Gray
Write-Host "  • View services: kubectl get svc" -ForegroundColor Gray
Write-Host "  • View logs:     kubectl logs -l app=sample-web-app" -ForegroundColor Gray
