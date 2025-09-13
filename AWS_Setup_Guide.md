# AWS Bedrock Claude Integration for RIA Application

## Complete Setup Guide

### Phase 1: Complete Lambda Function (Save as `claude_comparison_lambda.py`)

```python
import json
import boto3
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    """
    AWS Lambda function to compare old vs new regulatory data using Claude
    """
    
    # Initialize Bedrock client
    bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-east-1')
    
    try:
        # Parse the request body
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        old_data = body.get('oldData', '')
        new_data = body.get('newData', '')
        regulation_type = body.get('regulationType', 'General')
        
        # Create prompt for Claude
        prompt = f"""Human: You are a pharmaceutical regulatory expert. Please analyze and compare the following regulatory information:

REGULATION TYPE: {regulation_type}

OLD REGULATION/DATA:
{old_data}

NEW REGULATION/DATA:
{new_data}

Please provide a detailed comparison focusing on:
1. Key changes and differences
2. Impact on pharmaceutical companies
3. Compliance requirements
4. Timeline implications
5. Risk assessment

Format your response in clear sections with bullet points for easy reading.
