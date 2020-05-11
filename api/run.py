from flask import Flask, jsonify
from http import HTTPStatus
from logging import getLogger

app = Flask(__name__)

LOGGER = getLogger(__name__)
VERSION = 1.0

@app.route('/')
def index():
    return jsonify({"message": f"Congratulations! Version {VERSION} of your"
    f" application is running on Kubernetes."}), HTTPStatus.OK


@app.route('/health')
def health():
    return jsonify({"message": "Ok"}), HTTPStatus.OK


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
