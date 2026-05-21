import socket
from pyexpat.errors import messages

from flask import Flask, jsonify

app = Flask(__name__)
@app.route('/')
def home():
    return jsonify(
        message = {'hello': 'world'},
        host = socket.gethostname(),
    )

@app.route('/health')
def health():
    return jsonify({'status': 'ok'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False, port=5001)