import os
import subprocess

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    output = subprocess.check_output('/usr/bin/Rscript HelloWorld.R', shell=True)
    return output


if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))
