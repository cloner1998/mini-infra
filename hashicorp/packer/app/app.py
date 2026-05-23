import socket
import psycopg2
import consul
import pika
from flask import Flask, jsonify, request

app = Flask(__name__)


def discover(service_name):
    c = consul.Consul(host='127.0.0.1', port=8500)
    _, services = c.health.service(service_name, passing=True)
    if not services:
        raise Exception(f"{service_name} not found in Consul")

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
    host, port = discover("postgres")

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


@app.route("/publish", methods=["POST"])
def publish():
    """publish a message to RabbitMQ"""
    host, port = discover("rabbitmq")
    message = request.json.get("message", "hello from flask!")

    credentials = pika.PlainCredentials("admin", "secret123")
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=host, port=port, credentials=credentials)
    )
    channel = connection.channel()
    channel.queue_declare(queue="flask-queue", durable=True)
    channel.basic_publish(
        exchange="",
        routing_key="flask-queue",
        body=message,
        properties=pika.BasicProperties(delivery_mode=2)
    )
    connection.close()

    return jsonify({
        "status": "published",
        "message": message,
        "rabbitmq_host": host
    })


@app.route("/consume")
def consume():
    """consume one message from RabbitMQ"""
    host, port = discover("rabbitmq")

    credentials = pika.PlainCredentials("admin", "secret123")
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=host, port=port, credentials=credentials)
    )
    channel = connection.channel()
    channel.queue_declare(queue="flask-queue", durable=True)
    method, properties, body = channel.basic_get("flask-queue", auto_ack=True)
    connection.close()

    if body is None:
        return jsonify({"status": "empty", "message": None})

    return jsonify({
        "status": "consumed",
        "message": body.decode()
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False, port=5001)
