import json
import time
import hashlib
import hmac
import base64
import uuid
import sys

def generate_sign(token, secret):
    nonce = str(uuid.uuid4())
    t = int(round(time.time() * 1000))
    string_to_sign = '{}{}{}'.format(token, t, nonce)

    string_to_sign = bytes(string_to_sign, 'utf-8')
    secret = bytes(secret, 'utf-8')

    sign = base64.b64encode(hmac.new(secret, msg=string_to_sign, digestmod=hashlib.sha256).digest())

    data = {
        "token": token,
        "timestamp": t,
        "sign": str(sign, 'utf-8'),
        "nonce": nonce
    }
    return json.dumps(data)

if __name__ == "__main__":
    token = sys.argv[1]
    secret = sys.argv[2]
    result = generate_sign(token, secret)
    print(result)
