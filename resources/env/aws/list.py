#!/usr/bin/python

import boto3
import sys
import json
from pygments import highlight, lexers, formatters
from boto3.session import Session

print "Connecting to AWS..."
session = Session()
client = session.client(service_name='ec2', region_name='us-west-1')

print "Retreiving a list of AMI's..."
images = client.describe_images(Filters=[{'Name': 'virtualization-type', 'Values': ['hvm']}])

formatted_json = json.dumps(images, indent=4)
colorful_json = highlight(unicode(formatted_json, 'UTF-8'), lexers.JsonLexer(), formatters.TerminalFormatter())
print(colorful_json)
