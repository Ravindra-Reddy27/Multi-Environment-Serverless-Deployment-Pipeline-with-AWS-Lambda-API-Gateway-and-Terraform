import json
import os

def lambda_handler(event, context):
    environment = os.environ.get('ENVIRONMENT', 'unknown')
    version = os.environ.get('VERSION', 'Blue') # For blue/green
    
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({
            'message': f'Hello from {environment} ({version})!'
        })
    }