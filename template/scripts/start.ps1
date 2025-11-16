cls
Write-Host "[INFO] Wait while we install the npm packages..." -ForegroundColor DarkYellow
npm install
Write-Host "[SUCCESS] Packages installed successfully." -ForegroundColor Green
Write-Host "[SERVER] Starting server..." -ForegroundColor Magenta
npm run dev
