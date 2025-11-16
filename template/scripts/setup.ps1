# Ask for remote repository URL
$remoteRepo = Read-Host "Enter the remote repository URL: "

# Create README.md if it doesn't exist
if (-not (Test-Path "README.md")) {
    echo "# Project" >> README.md
}

# Initialize Git repo and push first commit
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin $remoteRepo
git push origin main
