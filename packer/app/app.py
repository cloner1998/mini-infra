import socket
import psycopg2
import consul
from flask import Flask, jsonify

app = Flask(__name__)


def get_postgres():
    c = consul.Consul(host='127.0.0.1', port=8500)
    _, services = c.health.service("postgres", passing=True)
    if not services:
        raise Exception("postgres not found in Consul")

    host = services[0]["Service"]["Address"]
    port = services[0]["Service"]["Port"]
    return host, port


@app.route('/')
def home():
    return jsonify(
        message={'hello': 'world'},
        host=socket.gethostname(),
    )


@app.route('/health')
def health():
    return jsonify({'status': 'ok'}), 200


@app.route("/db")
def db():
    host, port = get_postgres()

    conn = psycopg2.connect(
        host=host,
        port=port,
        dbname="flaskdb",
        user="flask",
        password="secret123"
    )
    cur = conn.cursor()
    cur.execute("SELECT version();")
    version = cur.fetchone()
    conn.close()

    return jsonify({
        "postgres_host": host,
        "postgres_port": port,
        "version": version[0]
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False, port=5001)
