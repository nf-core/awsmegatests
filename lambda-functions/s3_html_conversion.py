# Function to convert ContentType for html objects
# Follow the tutorial to reproduce the steps: https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example.html

import boto3
import os
import sys
import uuid
from urllib.parse import unquote_plus

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        print('{}'.format(bucket))
        # TODO update bucket name to desired bucket
        if "aws-html-conversion-test" in bucket:
            key = unquote_plus(record['s3']['object']['key'])
            print("This is the filename: " + key)
            if key.endswith(".html"):
                tmpkey = key.replace('/', '')
                download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)
                print(download_path)
                s3_client.download_file(bucket, key, download_path)
                s3_client.upload_file(download_path, '{}'.format(bucket), key, ExtraArgs={"ContentType":"text/html"})