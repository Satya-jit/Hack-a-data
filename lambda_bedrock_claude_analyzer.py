import json
import boto3
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda function to analyze documents using Amazon Bedrock Claude
    
    Expected event structure:
    {
        "body": {
            "prompt": "Analysis prompt...",
            "maxTokens": 4000,
            "temperature": 0.3,
            "document": "Document content...",
            "oddaContext": "ODDA requirements..."
        }
    }
    """
    
    try:
        # Parse request body
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        else:
            body = event.get('body', {})
        
        # Extract parameters
        prompt = body.get('prompt', '')
        document_content = body.get('document', '')
        odda_context = body.get('oddaContext', '')
        max_tokens = body.get('maxTokens', 4000)
        temperature = body.get('temperature', 0.3)
        
        if not prompt and not (document_content and odda_context):
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Missing required parameters',
                    'message': 'Either prompt or (document + oddaContext) is required'
                })
            }
        
        # Build comprehensive prompt if document and ODDA context provided
        if document_content and odda_context and not prompt:
            prompt = f"""
You are a regulatory affairs expert analyzing pharmaceutical documents for compliance with new ODDA requirements.

ORIGINAL DOCUMENT:
{document_content}

NEW ODDA REQUIREMENTS:
{odda_context}

Please provide a comprehensive regulatory impact analysis including:

1. KEY SECTIONS REQUIRING MODIFICATION
   - Identify specific sections that need updates
   - Explain why each section requires changes

2. SPECIFIC CHANGES REQUIRED
   - Detail exact modifications needed
   - Include quantitative data where applicable
   - Specify new language requirements

3. IMPLEMENTATION RECOMMENDATIONS
   - Provide step-by-step implementation plan
   - Include timeline considerations
   - Identify resource requirements

4. RISK ASSESSMENT
   - Evaluate compliance risks
   - Assess implementation challenges
   - Provide risk mitigation strategies

5. TIMELINE CONSIDERATIONS
   - Break down implementation phases
   - Identify critical path items
   - Suggest monitoring checkpoints

Format the response with clear sections and actionable recommendations. Be specific and regulatory-focused.
"""
        
        # Initialize Bedrock client with AWS credentials
        bedrock_client = boto3.client(
            'bedrock-runtime',
            region_name='us-east-1',
            aws_access_key_id='AKIA2PUE3CS6HTYZ6G5F',
            aws_secret_access_key='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'
        )
        
        # Prepare request for Claude
        claude_request = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": max_tokens,
            "temperature": temperature,
            "messages": [
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        }
        
        # Model ID for Claude 3.7 Sonnet
        model_id = "anthropic.claude-3-5-sonnet-20241022-v2:0"
        
        logger.info(f"Invoking Claude model: {model_id}")
        logger.info(f"Prompt length: {len(prompt)} characters")
        
        # Invoke Claude model
        response = bedrock_client.invoke_model(
            modelId=model_id,
            contentType="application/json",
            accept="application/json",
            body=json.dumps(claude_request)
        )
        
        # Parse Claude response
        response_body = json.loads(response['body'].read())
        claude_content = response_body['content'][0]['text']
        
        # Prepare response
        analysis_result = {
            'analysis': claude_content,
            'model': model_id,
            'timestamp': context.aws_request_id if context else 'local-test',
            'usage': {
                'input_tokens': response_body.get('usage', {}).get('input_tokens', 0),
                'output_tokens': response_body.get('usage', {}).get('output_tokens', 0)
            },
            'parameters': {
                'max_tokens': max_tokens,
                'temperature': temperature
            }
        }
        
        logger.info(f"Successfully generated analysis. Output tokens: {analysis_result['usage']['output_tokens']}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
                'Content-Type': 'application/json'
            },
            'body': json.dumps(analysis_result)
        }
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        
        if error_code == 'AccessDeniedException':
            logger.error("Access denied to Bedrock service")
            return {
                'statusCode': 403,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Access denied',
                    'message': 'Insufficient permissions to access Bedrock Claude model'
                })
            }
        elif error_code == 'ThrottlingException':
            logger.error("Bedrock request throttled")
            return {
                'statusCode': 429,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Rate limit exceeded',
                    'message': 'Too many requests to Bedrock service'
                })
            }
        elif error_code == 'ValidationException':
            logger.error(f"Invalid request to Bedrock: {str(e)}")
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Invalid request',
                    'message': 'Request parameters are invalid'
                })
            }
        else:
            logger.error(f"Bedrock error: {str(e)}")
            return {
                'statusCode': 500,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Bedrock service error',
                    'message': str(e)
                })
            }
    
    except json.JSONDecodeError as e:
        logger.error(f"JSON parsing error: {str(e)}")
        return {
            'statusCode': 400,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Invalid JSON',
                'message': 'Request body is not valid JSON'
            })
        }
    
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': 'An unexpected error occurred'
            })
        }

# Test function for local development
if __name__ == "__main__":
    # Test event
    test_event = {
        "body": {
            "document": "Sample clinical protocol document content...",
            "oddaContext": "New ODDA requirements for opioid prescribing...",
            "maxTokens": 1000,
            "temperature": 0.3
        }
    }
    
    result = lambda_handler(test_event, {})
    print(json.dumps(result, indent=2))