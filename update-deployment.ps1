# AURA Platform - Update Deployment Script
# Run this script whenever you want to update your Amplify deployment

Write-Host "🚀 Updating AURA Platform Deployment..." -ForegroundColor Cyan

# Remove old deployment files
Remove-Item "amplify-deploy\*" -Force

# Copy updated files to deployment folder
Copy-Item "*.html" "amplify-deploy\"
Copy-Item "*.png" "amplify-deploy\"
Copy-Item "*.js" "amplify-deploy\"

Write-Host "✅ Files updated in amplify-deploy folder" -ForegroundColor Green
Write-Host "📁 Ready to upload to AWS Amplify" -ForegroundColor Yellow

# List updated files
Write-Host "`nUpdated files:" -ForegroundColor White
Get-ChildItem "amplify-deploy" | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }

Write-Host "`n🌐 Next steps:" -ForegroundColor Cyan
Write-Host "1. Go to AWS Amplify Console" -ForegroundColor White
Write-Host "2. Click 'Deploy updates' on your app" -ForegroundColor White
Write-Host "3. Drag and drop the amplify-deploy folder" -ForegroundColor White