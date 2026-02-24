import json
import boto3
import os
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal): return int(obj)
        return super(DecimalEncoder, self).default(obj)

db = boto3.resource('dynamodb')
hist_table = db.Table(os.environ['HIST_TABLE'])
conn_table = db.Table(os.environ['CONN_TABLE'])

def handler(event, context):
    route_key = event['requestContext']['routeKey']
    connection_id = event['requestContext']['connectionId']

    # 1. If it's just the initial connection, just save and exit
    if route_key == "$connect":
        conn_table.put_item(Item={'connectionId': connection_id})
        return {'statusCode': 200}

    # 2. If it's the history request, fetch and send
    domain = event['requestContext']['domainName']
    stage = event['requestContext']['stage']
    gatewayapi = boto3.client('apigatewaymanagementapi',
                              endpoint_url=f"https://{domain}/{stage}")

    response = hist_table.scan()
    items = response.get('Items', [])
    items.sort(key=lambda x: x.get('unix_time', 0))
    history_to_send = items[-20:]

    try:
        gatewayapi.post_to_connection(
            ConnectionId=connection_id,
            Data=json.dumps({"action": "history", "data": history_to_send}, cls=DecimalEncoder)
        )
    except Exception as e:
        print(f"Error: {e}")

    return {'statusCode': 200}
