# AWS Lambda Deployment Script - Simple Version
# PowerShell script to deploy PRISM Lambda functions

$REGION = "us-east-1"
$S3_BUCKET = "prism-doc"
$AWS_ACCESS_KEY = "AKIA2PUE3CS6HTYZ6G5F"
$AWS_SECRET_KEY = "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"

# Function names
$S3_FUNCTION_NAME = "prism-s3-document-fetcher"
$BEDROCK_FUNCTION_NAME = "prism-bedrock-claude-analyzer"
$PRISM_FUNCTION_NAME = "prism-database-integration"
$IAM_ROLE_NAME = "prism-lambda-execution-role"

Write-Host "🚀 Starting AWS Lambda deployment..." -ForegroundColor Green

# Set AWS credentials
$env:AWS_ACCESS_KEY_ID = $AWS_ACCESS_KEY
$env:AWS_SECRET_ACCESS_KEY = $AWS_SECRET_KEY
$env:AWS_DEFAULT_REGION = $REGION

Write-Host "📋 AWS credentials configured" -ForegroundColor Yellow

# Create trust policy
$TRUST_POLICY = @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
"@

$TRUST_POLICY | Out-File -FilePath "trust-policy.json" -Encoding UTF8

# Create IAM role
Write-Host "🔐 Creating IAM role..." -ForegroundColor Yellow
aws iam create-role --role-name $IAM_ROLE_NAME --assume-role-policy-document file://trust-policy.json
aws iam put-role-policy --role-name $IAM_ROLE_NAME --policy-name "PrismLambdaPolicy" --policy-document file://iam-policy.json

# Get role ARN
$ROLE_ARN = aws iam get-role --role-name $IAM_ROLE_NAME --query 'Role.Arn' --output text
Write-Host "✅ IAM Role ARN: $ROLE_ARN" -ForegroundColor Green

# Create deployment packages
Write-Host "📦 Creating deployment packages..." -ForegroundColor Yellow

function New-LambdaZip {
    param($SourceFile, $ZipFile)
    
    if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }
    
    $tempDir = "temp_$([System.IO.Path]::GetRandomFileName())"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Copy-Item $SourceFile -Destination "$tempDir\lambda_function.py"
    Compress-Archive -Path "$tempDir\*" -DestinationPath $ZipFile -Force
    Remove-Item $tempDir -Recurse -Force
    
    Write-Host "✅ Created: $ZipFile" -ForegroundColor Green
}

New-LambdaZip -SourceFile "lambda_s3_document_fetcher.py" -ZipFile "s3-fetcher.zip"
New-LambdaZip -SourceFile "lambda_bedrock_claude_analyzer.py" -ZipFile "bedrock-analyzer.zip"
New-LambdaZip -SourceFile "lambda_prism_database_integration.py" -ZipFile "prism-integration.zip"

# Wait for IAM role to propagate
Write-Host "⏳ Waiting for IAM role to propagate..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Deploy Lambda functions
Write-Host "🚀 Deploying Lambda functions..." -ForegroundColor Yellow

Write-Host "📤 Deploying S3 Document Fetcher..." -ForegroundColor Cyan
aws lambda create-function `
    --function-name $S3_FUNCTION_NAME `
    --runtime python3.11 `
    --role $ROLE_ARN `
    --handler lambda_function.lambda_handler `
    --zip-file fileb://s3-fetcher.zip `
    --timeout 300 `
    --memory-size 1024

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Function exists, updating code..." -ForegroundColor Yellow
    aws lambda update-function-code --function-name $S3_FUNCTION_NAME --zip-file fileb://s3-fetcher.zip
}

Write-Host "📤 Deploying Bedrock Claude Analyzer..." -ForegroundColor Cyan
aws lambda create-function `
    --function-name $BEDROCK_FUNCTION_NAME `
    --runtime python3.11 `
    --role $ROLE_ARN `
    --handler lambda_function.lambda_handler `
    --zip-file fileb://bedrock-analyzer.zip `
    --timeout 300 `
    --memory-size 1024

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Function exists, updating code..." -ForegroundColor Yellow
    aws lambda update-function-code --function-name $BEDROCK_FUNCTION_NAME --zip-file fileb://bedrock-analyzer.zip
}

Write-Host "📤 Deploying PRISM Database Integration..." -ForegroundColor Cyan
aws lambda create-function `
    --function-name $PRISM_FUNCTION_NAME `
    --runtime python3.11 `
    --role $ROLE_ARN `
    --handler lambda_function.lambda_handler `
    --zip-file fileb://prism-integration.zip `
    --timeout 300 `
    --memory-size 1024

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Function exists, updating code..." -ForegroundColor Yellow
    aws lambda update-function-code --function-name $PRISM_FUNCTION_NAME --zip-file fileb://prism-integration.zip
}

# Create API Gateway
Write-Host "🌐 Creating API Gateway..." -ForegroundColor Yellow
$apiOutput = aws apigateway create-rest-api --name "prism-regulatory-api" --description "PRISM Regulatory Intelligence API"
if ($apiOutput) {
    $API_ID = ($apiOutput | ConvertFrom-Json).id
    Write-Host "✅ API Gateway created: $API_ID" -ForegroundColor Green
}

# Cleanup
Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
Remove-Item "s3-fetcher.zip", "bedrock-analyzer.zip", "prism-integration.zip", "trust-policy.json" -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🎉 Deployment completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resources Created:" -ForegroundColor Cyan
Write-Host "- IAM Role: $IAM_ROLE_NAME"
Write-Host "- Lambda Functions:"
Write-Host "  * $S3_FUNCTION_NAME"
Write-Host "  * $BEDROCK_FUNCTION_NAME"  
Write-Host "  * $PRISM_FUNCTION_NAME"
if ($API_ID) {
    Write-Host "- API Gateway: $API_ID"
}
Write-Host ""
Write-Host "✅ Next: Run setup-s3-documents.ps1 to create test documents" -ForegroundColor Green