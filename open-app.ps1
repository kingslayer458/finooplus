# Script to open the application avoiding Apache (port 80) and Jenkins (port 8080/8081)

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "  Starting Sample Web App" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Find an available port
$portsToTry = @(5000, 5001, 5002, 6000, 7000, 5555)
$availablePort = $null

Write-Host "Finding available port..." -ForegroundColor Yellow
foreach ($port in $portsToTry) {
    try {
        $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $port)
        $listener.Start()
        $listener.Stop()
        $availablePort = $port
        Write-Host "Port $availablePort is available!" -ForegroundColor Green
        break
    } catch {
        Write-Host "Port $port is busy, trying next..." -ForegroundColor DarkGray
    }
}

if ($null -eq $availablePort) {
    Write-Host "All common ports busy. Using port 5555..." -ForegroundColor Yellow
    $availablePort = 5555
}

Write-Host ""
Write-Host "Getting pod name..." -ForegroundColor Yellow

# Get the first pod name
$podName = kubectl get pods -l app=sample-web-app -o jsonpath='{.items[0].metadata.name}' 2>$null

if ([string]::IsNullOrEmpty($podName)) {
    Write-Host "ERROR: No pods found!" -ForegroundColor Red
    Write-Host "Check deployment: kubectl get pods -l app=sample-web-app" -ForegroundColor Yellow
    exit 1
}

Write-Host "Pod found: $podName" -ForegroundColor Green
Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Application URL:" -ForegroundColor Green
Write-Host "  http://localhost:$availablePort" -ForegroundColor White
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Available endpoints:" -ForegroundColor Cyan
Write-Host "  - Homepage:     http://localhost:$availablePort" -ForegroundColor White
Write-Host "  - Health Check: http://localhost:$availablePort/api/health" -ForegroundColor White
Write-Host "  - API Message:  http://localhost:$availablePort/api/message" -ForegroundColor White
Write-Host ""
Write-Host "Starting port-forward..." -ForegroundColor Cyan
Write-Host "Keep this window open!" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Wait then open browser
Start-Sleep -Seconds 2
Start-Process "http://localhost:$availablePort" -ErrorAction SilentlyContinue

# Start port-forwarding (keeps running)
kubectl port-forward pod/$podName ${availablePort}:3000
