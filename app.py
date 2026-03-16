from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "Hello, Docker! Hello K8s, this is me form docker hub V3 with sh command V3"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5005)
