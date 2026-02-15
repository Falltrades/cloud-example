import os
import ssl
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from io import BytesIO

app = Flask(__name__)

ssl_context = ssl.create_default_context()
ssl_context.check_hostname = False
ssl_context.verify_mode = ssl.CERT_NONE

db_url = os.environ.get('DATABASE_URL')
app.config['SQLALCHEMY_DATABASE_URI'] = db_url
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'connect_args': {'ssl_context': ssl_context}
}
db = SQLAlchemy(app)

class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.String(200), nullable=False)

@app.route('/tasks', methods=['GET', 'POST'])
def tasks():
    with app.app_context():
        db.create_all()
    if request.method == 'POST':
        data = request.get_json()
        new_task = Task(content=data['content'])
        db.session.add(new_task)
        db.session.commit()
        return jsonify({"message": "Task added"}), 201
    all_tasks = Task.query.all()
    return jsonify([{"id": t.id, "content": t.content} for t in all_tasks])

def handler(event, context):
    method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
    path = event.get('rawPath', '/')
    query = event.get('rawQueryString', '')
    headers = event.get('headers', {})
    body = event.get('body', '') or ''
    if event.get('isBase64Encoded'):
        import base64
        body = base64.b64decode(body)
    else:
        body = body.encode('utf-8')

    environ = {
        'REQUEST_METHOD': method,
        'PATH_INFO': path,
        'QUERY_STRING': query,
        'CONTENT_LENGTH': str(len(body)),
        'CONTENT_TYPE': headers.get('content-type', ''),
        'SERVER_NAME': 'lambda',
        'SERVER_PORT': '443',
        'wsgi.input': BytesIO(body),
        'wsgi.errors': BytesIO(),
        'wsgi.url_scheme': 'https',
        'wsgi.multithread': False,
        'wsgi.multiprocess': False,
        'wsgi.run_once': False,
    }
    for k, v in headers.items():
        key = 'HTTP_' + k.upper().replace('-', '_')
        environ[key] = v

    response_started = {}
    response_body = []

    def start_response(status, response_headers, exc_info=None):
        response_started['status'] = int(status.split(' ', 1)[0])
        response_started['headers'] = dict(response_headers)

    result = app(environ, start_response)
    for chunk in result:
        response_body.append(chunk)

    return {
        'statusCode': response_started['status'],
        'headers': response_started['headers'],
        'body': b''.join(response_body).decode('utf-8'),
    }
