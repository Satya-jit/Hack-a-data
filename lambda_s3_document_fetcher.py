import json
import boto3
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda function to fetch documents from S3 bucket for RIA analysis
    
    Expected event structure:
    {
        "pathParameters": {
            "documentId": "DOC-2025-001"
        }
    }
    """
    
    try:
        # Get document ID from path parameters
        document_id = event.get('pathParameters', {}).get('documentId')
        
        if not document_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Document ID is required',
                    'message': 'Please provide a valid document ID in the path'
                })
            }
        
        # Initialize S3 client with AWS credentials
        s3_client = boto3.client(
            's3',
            region_name='us-east-1',
            aws_access_key_id='AKIA2PUE3CS6HTYZ6G5F',
            aws_secret_access_key='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'
        )
        
        # AWS Configuration
        bucket_name = 'prism-doc'
        document_key = f'documents/{document_id}.json'
        
        logger.info(f"Fetching document: {document_id} from bucket: {bucket_name}")
        
        # Fetch document from S3
        response = s3_client.get_object(
            Bucket=bucket_name,
            Key=document_key
        )
        
        # Read and parse document content
        document_content = response['Body'].read().decode('utf-8')
        document_data = json.loads(document_content)
        
        # Add metadata from S3 object
        document_data['s3_metadata'] = {
            'last_modified': response['LastModified'].isoformat(),
            'content_length': response['ContentLength'],
            'etag': response['ETag'].strip('"'),
            'content_type': response.get('ContentType', 'application/json')
        }
        
        logger.info(f"Successfully fetched document: {document_id}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
                'Content-Type': 'application/json'
            },
            'body': json.dumps(document_data)
        }
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        
        if error_code == 'NoSuchKey':
            logger.warning(f"Document not found: {document_id}")
            return {
                'statusCode': 404,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Document not found',
                    'message': f'Document {document_id} does not exist in S3',
                    'document_id': document_id
                })
            }
        elif error_code == 'NoSuchBucket':
            logger.error(f"S3 bucket not found: {bucket_name}")
            return {
                'statusCode': 500,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Configuration error',
                    'message': 'S3 bucket not configured properly'
                })
            }
        else:
            logger.error(f"S3 error: {str(e)}")
            return {
                'statusCode': 500,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'S3 access error',
                    'message': str(e)
                })
            }
    
    except json.JSONDecodeError as e:
        logger.error(f"JSON parsing error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Document format error',
                'message': 'Document is not in valid JSON format'
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
        "pathParameters": {
            "documentId": "DOC-2025-001"
        }
    }
    
    result = lambda_handler(test_event, {})
    print(json.dumps(result, indent=2))