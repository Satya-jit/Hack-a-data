# AWS Lambda Deployment Script for PRISM Regulatory Intelligence System
# PowerShell script to deploy all Lambda functions and configure API Gateway

# Configuration
$REGION = "us-east-1"
$S3_BUCKET = "prism-doc"
$AWS_ACCESS_KEY = "AKIA2PUE3CS6HTYZ6G5F"
$AWS_SECRET_KEY = "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"

# Function names
$S3_FUNCTION_NAME = "prism-s3-document-fetcher"
$BEDROCK_FUNCTION_NAME = "prism-bedrock-claude-analyzer"
$PRISM_FUNCTION_NAME = "prism-database-integration"

# IAM Role name
$IAM_ROLE_NAME = "prism-lambda-execution-role"

Write-Host "🚀 Starting AWS Lambda deployment for PRISM Regulatory Intelligence System" -ForegroundColor Green

# Set AWS credentials
Write-Host "📋 Setting AWS credentials..." -ForegroundColor Yellow
$env:AWS_ACCESS_KEY_ID = $AWS_ACCESS_KEY
$env:AWS_SECRET_ACCESS_KEY = $AWS_SECRET_KEY
$env:AWS_DEFAULT_REGION = $REGION

# Check if AWS CLI is installed
try {
    aws --version | Out-Null
    Write-Host "✅ AWS CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI is not installed. Please install AWS CLI first." -ForegroundColor Red
    exit 1
}

# Create IAM role for Lambda execution
Write-Host "🔐 Creating IAM role for Lambda functions..." -ForegroundColor Yellow

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

# Create trust policy file
$TRUST_POLICY | Out-File -FilePath "trust-policy.json" -Encoding UTF8

# Create IAM role
Write-Host "Creating IAM role..." -ForegroundColor Yellow
$createRoleResult = aws iam create-role --role-name $IAM_ROLE_NAME --assume-role-policy-document file://trust-policy.json 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ IAM role created successfully" -ForegroundColor Green
} else {
    Write-Host "ℹ️ IAM role may already exist, continuing..." -ForegroundColor Yellow
}

# Attach policy to role
Write-Host "📎 Attaching IAM policy to role..." -ForegroundColor Yellow
$attachPolicyResult = aws iam put-role-policy --role-name $IAM_ROLE_NAME --policy-name "PrismLambdaPolicy" --policy-document file://iam-policy.json 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ IAM policy attached successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️ Policy attachment result: $attachPolicyResult" -ForegroundColor Yellow
}

# Get role ARN
$ROLE_ARN = aws iam get-role --role-name $IAM_ROLE_NAME --query 'Role.Arn' --output text

Write-Host "📦 Creating deployment packages..." -ForegroundColor Yellow

# Function to create Lambda deployment package
function New-LambdaPackage {
    param(
        [string]$FunctionFile,
        [string]$ZipName
    )
    
    if (Test-Path $ZipName) {
        Remove-Item $ZipName -Force
    }
    
    # Create temporary directory
    $tempDir = "temp_lambda_$([System.IO.Path]::GetRandomFileName())"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # Copy Python file
    Copy-Item $FunctionFile -Destination "$tempDir\lambda_function.py"
    
    # Create zip package
    Compress-Archive -Path "$tempDir\*" -DestinationPath $ZipName -Force
    
    # Clean up
    Remove-Item $tempDir -Recurse -Force
    
    Write-Host "✅ Created package: $ZipName" -ForegroundColor Green
}

# Create packages for all Lambda functions
New-LambdaPackage -FunctionFile "lambda_s3_document_fetcher.py" -ZipName "s3-fetcher.zip"
New-LambdaPackage -FunctionFile "lambda_bedrock_claude_analyzer.py" -ZipName "bedrock-analyzer.zip"
New-LambdaPackage -FunctionFile "lambda_prism_database_integration.py" -ZipName "prism-integration.zip"

Write-Host "🚀 Deploying Lambda functions..." -ForegroundColor Yellow

# Wait a moment for IAM role to propagate
Start-Sleep -Seconds 10

# Deploy S3 Document Fetcher
Write-Host "📤 Deploying S3 Document Fetcher..." -ForegroundColor Cyan
$s3Result = aws lambda create-function --function-name $S3_FUNCTION_NAME --runtime python3.11 --role $ROLE_ARN --handler lambda_function.lambda_handler --zip-file fileb://s3-fetcher.zip --timeout 300 --memory-size 1024 --description "Fetches regulatory documents from S3 bucket" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ S3 Document Fetcher deployed successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️ S3 function deployment failed, trying to update..." -ForegroundColor Yellow
    aws lambda update-function-code --function-name $S3_FUNCTION_NAME --zip-file fileb://s3-fetcher.zip
}

# Deploy Bedrock Claude Analyzer
Write-Host "📤 Deploying Bedrock Claude Analyzer..." -ForegroundColor Cyan
$bedrockResult = aws lambda create-function --function-name $BEDROCK_FUNCTION_NAME --runtime python3.11 --role $ROLE_ARN --handler lambda_function.lambda_handler --zip-file fileb://bedrock-analyzer.zip --timeout 300 --memory-size 1024 --description "Analyzes documents using Amazon Bedrock Claude" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Bedrock Claude Analyzer deployed successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️ Bedrock function deployment failed, trying to update..." -ForegroundColor Yellow
    aws lambda update-function-code --function-name $BEDROCK_FUNCTION_NAME --zip-file fileb://bedrock-analyzer.zip
}

# Deploy PRISM Database Integration
Write-Host "📤 Deploying PRISM Database Integration..." -ForegroundColor Cyan
$prismResult = aws lambda create-function --function-name $PRISM_FUNCTION_NAME --runtime python3.11 --role $ROLE_ARN --handler lambda_function.lambda_handler --zip-file fileb://prism-integration.zip --timeout 300 --memory-size 1024 --description "Integrates with PRISM database for document matching" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PRISM Database Integration deployed successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️ PRISM function deployment failed, trying to update..." -ForegroundColor Yellow
    aws lambda update-function-code --function-name $PRISM_FUNCTION_NAME --zip-file fileb://prism-integration.zip
}

Write-Host "🌐 Creating API Gateway..." -ForegroundColor Yellow

# Create API Gateway
$API_NAME = "prism-regulatory-api"
$apiResult = aws apigateway create-rest-api --name $API_NAME --description "PRISM Regulatory Intelligence API" 2>&1
if ($LASTEXITCODE -eq 0) {
    $API_ID = ($apiResult | ConvertFrom-Json).id
    Write-Host "✅ API Gateway created: $API_ID" -ForegroundColor Green
} else {
    Write-Host "⚠️ API Gateway creation result: $apiResult" -ForegroundColor Yellow
}

Write-Host "🧹 Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item "s3-fetcher.zip", "bedrock-analyzer.zip", "prism-integration.zip", "trust-policy.json" -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🎉 Deployment completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Configure API Gateway endpoints manually in AWS Console"
Write-Host "2. Update Ria.html with actual API Gateway URLs"
Write-Host "3. Test all Lambda functions"
Write-Host "4. Set up DynamoDB table 'prism-regulatory-documents' if using real PRISM data"
Write-Host ""
Write-Host "🔗 Resources Created:" -ForegroundColor Cyan
Write-Host "- IAM Role: $IAM_ROLE_NAME"
Write-Host "- Lambda Functions:"
Write-Host "  * $S3_FUNCTION_NAME"
Write-Host "  * $BEDROCK_FUNCTION_NAME"
Write-Host "  * $PRISM_FUNCTION_NAME"
if ($API_ID) {
    Write-Host "- API Gateway: $API_ID"
}
Write-Host ""
Write-Host "⚠️ Important:" -ForegroundColor Red
Write-Host "- Ensure your AWS account has access to Bedrock Claude 3.5 Sonnet"
Write-Host "- Create S3 bucket structure: $S3_BUCKET/documents/"
Write-Host "- Upload test documents to S3 for testing"