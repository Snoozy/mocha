import boto3
from config import config

boto_session = boto3.Session(
    aws_access_key_id=config['aws']['access_key'],
    aws_secret_access_key=config['aws']['secret_key']
)
