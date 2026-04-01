from flask import Flask
import os 

app = Flask(__name__)

try:
  database_name = os.environ['DATABASE_NAME']
  database_test_pass = os.environ['DATABASE_PASS']
except:
    database_name = "NON"
    database_test_pass = "NON"

# This string contains the HTML and CSS for your dark-themed page

HTML_CONTENT = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terminal | V3</title>
    <style>
        body {{
            background-color: #0d1117;
            color: #58a6ff;
            font-family: 'Courier New', Courier, monospace;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            overflow: hidden;
        }}
        .container {{
            text-align: center;
            border: 1px solid #30363d;
            padding: 3rem;
            border-radius: 12px;
            background: rgba(22, 27, 34, 0.8);
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.8);
        }}
        h1 {{
            color: #238636;
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
            letter-spacing: 4px;
        }}
        p {{
            color: #8b949e;
            font-size: 1.1rem;
        }}
        .status-pulse {{
            display: inline-block;
            width: 12px;
            height: 12px;
            background-color: #238636;
            border-radius: 50%;
            margin-right: 8px;
            box-shadow: 0 0 8px #238636;
            animation: pulse 2s infinite;
        }}
        @keyframes pulse {{
            0% {{ transform: scale(0.95); box-shadow: 0 0 0 0 rgba(35, 134, 54, 0.7); }}
            70% {{ transform: scale(1); box-shadow: 0 0 0 10px rgba(35, 134, 54, 0); }}
            100% {{ transform: scale(0.95); box-shadow: 0 0 0 0 rgba(35, 134, 54, 0); }}
        }}
        .version-tag {{
            margin-top: 20px;
            font-size: 0.8rem;
            color: #f0f6fc;
            background: #21262d;
            padding: 4px 12px;
            border-radius: 20px;
            display: inline-block;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>System Online</h1>
        <p>Hello, Docker! Hello K8s!</p>
        <p>{database_name} , {database_test_pass}</p>
        <p><span class="status-pulse"></span> Connection Secure via Docker Hub</p>
        <div class="version-tag">Build: v3.0.0-sh</div>
    </div>
</body>
</html>
"""

@app.route("/")
def hello_world():
    return HTML_CONTENT

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5005)