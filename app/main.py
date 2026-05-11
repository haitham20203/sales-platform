import os
from flask import Flask, request, jsonify
import psycopg2
from google.cloud import pubsub_v1
import json

app = Flask(__name__)

PROJECT_ID = os.environ.get("PROJECT_ID", "globant-gdp")
TOPIC_ID   = os.environ.get("TOPIC_ID", "sales-events")
DB_HOST    = os.environ.get("DB_HOST")
DB_NAME    = "salesdb"
DB_USER    = "salesapp"
DB_PASS    = os.environ.get("DB_PASS", "SalesApp@2024!")

def get_db():
    return psycopg2.connect(
        host=DB_HOST, dbname=DB_NAME,
        user=DB_USER, password=DB_PASS
    )

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS sales (
            id SERIAL PRIMARY KEY,
            region VARCHAR(100),
            product VARCHAR(100),
            amount FLOAT,
            created_at TIMESTAMP DEFAULT NOW()
        )
    """)
    conn.commit()
    cur.close()
    conn.close()

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/")
def index():
    return """
    <html><body style="font-family:Arial;max-width:500px;margin:50px auto">
    <h2>Sales Platform</h2>
    <form action="/sales" method="post">
        <p>Region: <input name="region" placeholder="e.g. Riyadh" required></p>
        <p>Product: <input name="product" placeholder="e.g. Laptop" required></p>
        <p>Amount: <input name="amount" type="number" step="0.01" required></p>
        <button type="submit">Submit Sale</button>
    </form>
    </body></html>
    """

@app.route("/sales", methods=["POST"])
def add_sale():
    region  = request.form.get("region")
    product = request.form.get("product")
    amount  = float(request.form.get("amount"))

    # Save to Cloud SQL
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO sales (region, product, amount) VALUES (%s, %s, %s)",
        (region, product, amount)
    )
    conn.commit()
    cur.close()
    conn.close()

    # Publish to Pub/Sub
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)
    message = json.dumps({"region": region, "product": product, "amount": amount})
    publisher.publish(topic_path, message.encode("utf-8"))

    return f"""
    <html><body style="font-family:Arial;max-width:500px;margin:50px auto">
    <h2>✅ Sale Recorded!</h2>
    <p>Region: {region} | Product: {product} | Amount: {amount}</p>
    <a href="/">Submit another</a>
    </body></html>
    """

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=8080)
