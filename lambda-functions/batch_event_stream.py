#!/usr/bin/python3.6
# Lambda function to listen to events from the Batch event stream to other apps, e.g. Slack.
# Follow instructions as detailed here: https://docs.aws.amazon.com/batch/latest/userguide/batch_cwet.html

import json

def lambda_handler(event, _context):
    # _context is not used
    del _context
    if event["source"] != "aws.batch":
        raise ValueError("Function only supports input from events with a source type of: aws.batch")

    print(json.dumps(event))