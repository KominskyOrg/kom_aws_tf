import json
import pymysql
import boto3
import os
import socket
import logging
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Extract stack_name and env from the event
    stack_name = event.get('stack_name')
    env = event.get('env')
    if not stack_name or not env:
        missing_params = []
        if not stack_name:
            missing_params.append('stack_name')
        if not env:
            missing_params.append('env')
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error: Missing parameters: {', '.join(missing_params)}")
        }

    # RDS settings from environment variables
    rds_host = os.environ['RDS_HOST']
    rds_port = int(os.environ['RDS_PORT'])
    master_username = os.environ['MASTER_USERNAME']
    master_password = os.environ['MASTER_PASSWORD']

    logger.info(f"Attempting to connect to RDS Host: {rds_host}, Port: {rds_port}")

    # Validate DNS resolution
    try:
        resolved_ip = socket.gethostbyname(rds_host)
        logger.info(f"Resolved RDS host {rds_host} to IP {resolved_ip}")
    except socket.gaierror as e:
        logger.error(f"DNS resolution failed: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps("DNS resolution failed.")
        }

    # Test basic TCP connectivity
    try:
        with socket.create_connection((rds_host, rds_port), timeout=5):
            logger.info(f"Successfully established TCP connection to {rds_host}:{rds_port}")
    except socket.error as e:
        logger.error(f"TCP connection failed: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps("TCP connection to RDS failed.")
        }

    # Define database and user based on stack_name
    db_name = f"{stack_name}_db"
    db_user = f"{stack_name}_user"
    secrets_manager_secret_name = f"{env}_{stack_name}_db_credentials"

    # Generate a secure random password using AWS Secrets Manager
    secrets_client = boto3.client('secretsmanager')
    try:
        random_password = secrets_client.get_random_password(
            PasswordLength=16,
            ExcludeCharacters="'\"\\!@#$%^&*()_+-=[]{}|;:,.<>?/",
            ExcludePunctuation=True
        )['RandomPassword']
    except ClientError as e:
        logger.error(f"Failed to generate random password: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps("Failed to generate password.")
        }

    db_password = random_password

    # Connect to RDS
    try:
        with pymysql.connect(
            host=rds_host,
            user=master_username,
            password=master_password,
            port=rds_port,
            cursorclass=pymysql.cursors.DictCursor
        ) as connection:
            logger.info("Successfully connected to RDS")

            db_user_escaped = connection.escape_string(db_user)
            db_password_escaped = connection.escape_string(db_password)

            with connection.cursor() as cursor:
                # Create database
                cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{db_name}`;")
                # Create user
                cursor.execute(
                    f"CREATE USER IF NOT EXISTS '{db_user_escaped}'@'%' IDENTIFIED BY '{db_password_escaped}';"
                )
                # Grant privileges
                cursor.execute(
                    f"GRANT ALL PRIVILEGES ON `{db_name}`.* TO '{db_user_escaped}'@'%';"
                )
                # Flush privileges
                cursor.execute("FLUSH PRIVILEGES;")
            connection.commit()
            logger.info("Database and user created successfully")
    except pymysql.MySQLError as e:
        logger.error(f"Database operation failed: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps("Database operation failed.")
        }


    # Store credentials in Secrets Manager
    secret_string = json.dumps({
        "username": db_user,
        "password": db_password
    })

    try:
        # Check if the secret already exists
        try:
            secrets_client.describe_secret(SecretId=secrets_manager_secret_name)
            secret_exists = True
        except secrets_client.exceptions.ResourceNotFoundException:
            secret_exists = False

        if not secret_exists:
            # Create the secret
            secrets_client.create_secret(
                Name=secrets_manager_secret_name,
                SecretString=secret_string
            )
            logger.info(f"Secret {secrets_manager_secret_name} created successfully")
        else:
            # Update the secret
            secrets_client.update_secret(
                SecretId=secrets_manager_secret_name,
                SecretString=secret_string
            )
            logger.info(f"Secret {secrets_manager_secret_name} updated successfully")
    except ClientError as e:
        logger.error(f"Error storing secret: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps("Error storing secret.")
        }

    return {
        'statusCode': 200,
        'body': json.dumps(f"Database '{db_name}' and user '{db_user}' created successfully.")
    }
