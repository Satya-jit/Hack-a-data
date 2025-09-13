# AWS Bedrock Claude Integration Setup Guide

## What You've Implemented

✅ **Frontend Changes Made:**
- Added new data input textarea for users to paste new regulation text
- Updated "Generate AI Comparison" button to call Claude
- Enhanced UI with loading animations and Claude branding
- Fallback demo mode if API isn't configured yet

✅ **Backend Ready:**
- Complete Lambda function for AWS Bedrock Claude integration
- Handles old vs new data comparison
- Returns formatted analysis

## Quick Setup Steps

### Step 1: Deploy Lambda Function
1. Go to AWS Lambda Console
2. Create new function: `ria-claude-comparison`
3. Copy the Python code from `claude_lambda_function.py`
4. Set runtime: Python 3.9+
5. Add IAM role with Bedrock permissions

### Step 2: Create API Gateway
1. Go to API Gateway Console
2. Create REST API
3. Create resource: `/compare`
4. Create POST method → Link to Lambda
5. Enable CORS
6. Deploy API → Get URL

### Step 3: Update Frontend
In your Ria.html, replace `YOUR_API_GATEWAY_URL_HERE` with actual URL:
```javascript
const response = await fetch('https://your-api-id.execute-api.us-east-1.amazonaws.com/prod/compare', {
```

### Step 4: Test Your Integration
1. Open RIA application
2. Click "Analyse" on any regulation row
3. Paste new regulation text in the textarea
4. Click "Generate AI Comparison with Claude"
5. See Claude's intelligent analysis!

## How It Works

1. **User Input:** Pastes new regulation data in textarea
2. **API Call:** Frontend sends old + new data to Lambda
3. **Claude Analysis:** Lambda calls Bedrock Claude model
4. **Response:** Claude returns detailed comparison
5. **Display:** Formatted analysis shown in UI

## Cost Estimate
- **Lambda:** ~$0.20 per 1M requests
- **API Gateway:** ~$3.50 per 1M requests  
- **Bedrock Claude:** ~$0.008 per 1K input tokens
- **Total:** $5-20/month for moderate usage

## Demo Mode
Your app now works in demo mode even without AWS setup. Configure the API for real Claude analysis!

## IAM Permissions Needed
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "bedrock:InvokeModel"
            ],
            "Resource": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-*"
        }
    ]
}
```
