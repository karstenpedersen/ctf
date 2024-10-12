from flask import Flask, request, flash
from flask import render_template
from flask_bootstrap import Bootstrap5
import hashlib
import requests
import httpx

app = Flask(__name__)
bootstrap = Bootstrap5(app)
app.config["BOOTSTRAP_SERVE_LOCAL"] = True
app.secret_key = b"egKm?zmAeQ5Uw#MKMZ_N-#WF;Az5fR"

PASSWORDAPI_URL = "http://pwnedpasswords.hkn/range/"


# TODO: implement the block-list check
# a description of the API can be found at http://pwnedpasswords.hkn
def breach_count(password: str) -> int:
    sha1 = hashlib.sha1()
    encoded = password.encode()
    sha1.update(encoded)
    h = sha1.hexdigest()
    response = httpx.get(f"{PASSWORDAPI_URL}{h[:5]}")

    lines = response.text.split("\n")
    for line in lines:
        s = line.split(":") 
        if s[0].lower() == h[5:]:
            return s[1]
    return 0 


# return status code 200 for a valid request
# and status code 400 for a request with a breached password
@app.route("/", methods=["GET", "POST"])
def change():
    if request.method == "GET":
        return render_template("password.html")
    password = request.form["password"]
    count = breach_count(password)
    if count == 0:
        flash("Password successfully changed", "success")
        return render_template("password.html")
    else:
        # do not change the message, as it will be used for checking the solution
        flash(f"Cannot change to password since it is breached {count} times", "danger")
        return render_template("password.html"), 400
