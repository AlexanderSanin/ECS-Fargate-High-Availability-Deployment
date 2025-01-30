from flask import Flask, jsonify
import socket
import datetime

app = Flask(__name__)


@app.route('/')
def home():
    return jsonify({
        'message': 'Hello from ECS Fargate!',
        'hostname': socket.gethostname(),
        'timestamp': datetime.datetime.now().isoformat()
    })


@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.datetime.now().isoformat()
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
