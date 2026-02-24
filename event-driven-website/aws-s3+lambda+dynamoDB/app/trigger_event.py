import json
import boto3
import os
import time
import uuid
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal): return int(obj)
        return super(DecimalEncoder, self).default(obj)

db = boto3.resource('dynamodb')
conn_table = db.Table(os.environ['CONN_TABLE'])
hist_table = db.Table(os.environ['HIST_TABLE'])

def handler(event, context):
    domain = event['requestContext']['domainName']
    stage = event['requestContext']['stage']
    gatewayapi = boto3.client('apigatewaymanagementapi',
                               endpoint_url=f"https://{domain}/{stage}")

    body = json.loads(event.get('body', '{}'))
    action = body.get('action')
    broadcast_data = None

    if action == "clear_history":
        try:
            scan = hist_table.scan(
                ProjectionExpression='#id',
                ExpressionAttributeNames={'#id': 'id'}
            )
            items = scan.get('Items', [])
            print(f"Found {len(items)} items to delete: {items}")
            with hist_table.batch_writer() as batch:
                for each in items:
                    batch.delete_item(Key={'id': each['id']})
            broadcast_data = json.dumps({"action": "ui_clear_requested"})
            print("Clear success")
        except Exception as e:
            print(f"CLEAR ERROR: {e}")
            return {'statusCode': 500}

    elif action == "manual_trigger":
        event_payload = {
            "id": str(uuid.uuid4())[:4],
            "type": body.get('event_type', 'System Update'),
            "timestamp": time.strftime('%H:%M:%S'),
            "unix_time": int(time.time())
        }
        hist_table.put_item(Item=event_payload)
        broadcast_data = json.dumps(event_payload, cls=DecimalEncoder)

    if not broadcast_data:
        return {'statusCode': 400}

    connections = conn_table.scan(ProjectionExpression="connectionId")['Items']
    for conn in connections:
        cid = conn['connectionId']
        try:
            gatewayapi.post_to_connection(ConnectionId=cid, Data=broadcast_data)
        except Exception:
            conn_table.delete_item(Key={'connectionId': cid})

    return {'statusCode': 200}
