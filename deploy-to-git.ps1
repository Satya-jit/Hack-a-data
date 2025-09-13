# AURA Platform - Deploy to Git and Amplify
# Run this script after I make changes to your files

Write-Host "🚀 AURA Platform Deployment Script" -ForegroundColor Cyan

# Step 1: Update deployment folder
Write-Host "📁 Updating deployment folder..." -ForegroundColor Yellow
Remove-Item "amplify-deploy\*" -Force -ErrorAction SilentlyContinue
Copy-Item "*.html" "amplify-deploy\" -Force
Copy-Item "*.png" "amplify-deploy\" -Force
Copy-Item "*.js" "amplify-deploy\" -Force

# Step 2: Git operations
Write-Host "📝 Adding changes to Git..." -ForegroundColor Yellow
git add .

Write-Host "💾 Committing changes..." -ForegroundColor Yellow
$commitMessage = Read-Host "Enter commit message (or press Enter for default)"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Updated AURA platform - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}
git commit -m $commitMessage

Write-Host "🌐 Pushing to Git repository..." -ForegroundColor Yellow
git push origin main

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🔗 Check your Amplify console for build status" -ForegroundColor Cyan
Write-Host "🌐 Your site: https://main.d3j6q39o5z3jj6.amplifyapp.com/home.html" -ForegroundColor White