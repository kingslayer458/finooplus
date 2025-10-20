# Docker Image Cleanup Script
# Removes old sample-web-app images, keeping only the last 3 builds

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Docker Image Cleanup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Show current images
Write-Host "Current images:" -ForegroundColor Yellow
docker images | Select-String "sample-web-app"
Write-Host ""

# Count total images
$totalImages = (docker images | Select-String "sample-web-app").Count
Write-Host "Total sample-web-app images: $totalImages" -ForegroundColor Yellow
Write-Host ""

# Calculate disk usage
Write-Host "Disk usage:" -ForegroundColor Yellow
docker system df | Select-String "Images"
Write-Host ""

# Confirm cleanup
$confirm = Read-Host "Do you want to clean up old images? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Cleaning up..." -ForegroundColor Cyan

# 1. Remove dangling images
Write-Host "1. Removing dangling images..." -ForegroundColor Yellow
docker image prune -f

# 2. Remove old build number tags (keep last 3)
Write-Host "2. Removing old build tags (keeping last 3)..." -ForegroundColor Yellow
$images = docker images kingslayerone/sample-web-app --format "{{.Tag}}" | Where-Object { $_ -match '^\d+$' } | Sort-Object -Descending
$toRemove = $images | Select-Object -Skip 3

foreach ($tag in $toRemove) {
    Write-Host "  Removing kingslayerone/sample-web-app:$tag" -ForegroundColor DarkGray
    docker rmi "kingslayerone/sample-web-app:$tag" 2>$null
}

# 3. Remove old sample-web-app images (without registry prefix)
Write-Host "3. Removing old local sample-web-app images..." -ForegroundColor Yellow
$localImages = docker images sample-web-app --format "{{.ID}}" --filter "dangling=false"
foreach ($id in $localImages) {
    Write-Host "  Removing image: $id" -ForegroundColor DarkGray
    docker rmi $id -f 2>$null
}

# 4. Final cleanup of unused images
Write-Host "4. Final cleanup..." -ForegroundColor Yellow
docker image prune -f

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Cleanup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Show remaining images
Write-Host "Remaining images:" -ForegroundColor Yellow
docker images | Select-String "sample-web-app"
Write-Host ""

# Show new disk usage
Write-Host "New disk usage:" -ForegroundColor Yellow
docker system df | Select-String "Images"
Write-Host ""

Write-Host "Summary:" -ForegroundColor Cyan
$newTotal = (docker images | Select-String "sample-web-app").Count
$removed = $totalImages - $newTotal
Write-Host "  Images before: $totalImages" -ForegroundColor White
Write-Host "  Images after:  $newTotal" -ForegroundColor White
Write-Host "  Removed:       $removed" -ForegroundColor Green
