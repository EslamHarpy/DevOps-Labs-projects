import time
import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.route('/')
def hello():
    count = get_hit_count()
    
    # Modern Dark Theme HTML Embedded directly into Flask response
    html_content = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Flask & Redis Dashboard</title>
        <style>
            :root {{
                --bg-color: #0f172a;
                --card-bg: #1e293b;
                --text-color: #f8fafc;
                --accent-color: #38bdf8;
                --success-color: #10b981;
            }}
            body {{
                font-family: 'Segoe UI', sans-serif;
                background-color: var(--bg-color);
                color: var(--text-color);
                margin: 0;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }}
            .card {{
                background-color: var(--card-bg);
                padding: 3rem;
                border-radius: 16px;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3);
                text-align: center;
                max-width: 500px;
                width: 90%;
                border: 1px solid #334155;
            }}
            h1 {{
                color: var(--accent-color);
                font-size: 2.2rem;
                margin-bottom: 0.5rem;
            }}
            .subtitle {{
                color: #94a3b8;
                font-size: 1rem;
                margin-bottom: 2rem;
            }}
            .counter-box {{
                background: linear-gradient(135deg, #0284c7, #0369a1);
                padding: 1.5rem;
                border-radius: 12px;
                margin: 1.5rem 0;
                border: 1px solid #0ea5e9;
            }}
            .counter-box h2 {{
                margin: 0;
                font-size: 1.2rem;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: #e2e8f0;
            }}
            .count {{
                font-size: 3.5rem;
                font-weight: 800;
                color: white;
                margin-top: 0.5rem;
            }}
            .footer {{
                font-size: 0.9rem;
                color: #64748b;
                margin-top: 2rem;
            }}
            .badge {{
                background-color: rgba(56, 189, 248, 0.1);
                color: var(--accent-color);
                padding: 0.4rem 1rem;
                border-radius: 20px;
                font-size: 0.85rem;
                font-weight: 600;
            }}
        </style>
    </head>
    <body>
        <div class="card">
            <span class="badge">Docker Compose Microservices</span>
            <h1>Docker Mastery Course</h1>
            <p class="subtitle">Distributed Web Application Stack</p>
            
            <div class="counter-box">
                <h2>Total Visitor Count</h2>
                <div class="count">{count}</div>
            </div>
            
            <p style="color: #cbd5e1; font-weight: 500;">Dynamic Live Updates Enabled</p>
            <div class="footer">
                Backend: Python Flask &bull; Cache Layer: Redis Alpine<br>
                Managed by: <strong>Eslam Harby</strong>
            </div>
        </div>
    </body>
    </html>
    """
    return html_content

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
