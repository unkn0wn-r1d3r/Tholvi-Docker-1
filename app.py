from flask import Flask, request, render_template_string
import os

app = Flask(__name__)

@app.route("/")
def home():
    return "Welcome to Dockerized Flask Hell! Try /debug?input=test"

@app.route("/debug")
def debug():
    user_input = request.args.get('input', 'None')
    return render_template_string(f"Debug: {user_input}")  # SSTI here

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)