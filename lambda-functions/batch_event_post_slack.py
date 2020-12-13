#!/usr/bin/python3.6
# Lambda function to post SNS notifications to Slack
# Follow instructions as described here to set this up: https://aws.amazon.com/premiumsupport/knowledge-center/sns-lambda-webhooks-chime-slack-teams/

import urllib3
import json
http = urllib3.PoolManager()
def lambda_handler(event, context):
    url = "https://hooks.slack.com/services/xxxx" #TODO Add hook URL
    msg_part = json.loads(event["Records"][0]["Sns"]["Message"])
    msg = {
        "channel": "#<CHANNEL_NAME>", #TODO Add channel name
        "username": "<USERNAME>", #TODO Add github username
        "text": msg_part["detail"]["jobName"]+" "+msg_part["detail"]["status"],
        "icon_emoji": ""
    }
    
    encoded_msg = json.dumps(msg).encode('utf-8')
    resp = http.request('POST',url, body=encoded_msg)
    print({
        "message": msg_part["detail"]["jobName"]+" "+msg_part["detail"]["status"], 
        "status_code": resp.status, 
        "response": resp.data
    })