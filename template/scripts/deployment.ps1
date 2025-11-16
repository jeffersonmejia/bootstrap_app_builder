cls
$msg = Read-Host "Enter commit message"
npm run build
git add .
git commit -m "$msg"
git pull origin main
git push origin main
npm run deploy
