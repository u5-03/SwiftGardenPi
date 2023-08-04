import requests
import json

def post_image():
    url = 'https://storage.googleapis.com/upload/storage/v1/b/mydevelopment-cdc30.appspot.com/o?name=Images%2F1690651182.jpeg&uploadType=media'
    headers = {
        'Accept': '*/*',
        'Content-Type': 'image/jpeg',
        'Authorization': 'Bearer ya29.a0AfB_byAKy0aNtGSvcMErEJUy0tyMvkFw8F0sAO_BQdmqTht2MVWvjrITTBilK8QQDwUC2p-cA_faWMeCYQI7HkrhFPPWx3Vh40TzS_IujjwYmv1BLIdOzEkbqNPyB6yEPBal6_uHxo6PqwWgNwMJ3q72iJAuBp3ERAaCgYKAUASARMSFQHsvYlsBmH5UFpMAH-QyxE2M0nmLg0169'
    }
    data = open('/Users/yugo.sugiyama/Dev/Swift/SwiftGarden/SwiftGardenPi/Sources/SwiftGardenPi/Images/1690651182.jpeg', 'rb').read()

    response = requests.post(url, headers=headers, data=data)

    # Check if the request was successful
    if response.status_code == 200:
        # Parse the response as JSON
        response_json = response.json()
        return response_json
    else:
        return f"Request failed with status code {response.status_code}"

if __name__ == "__main__":
    result = post_image()
    print(json.dumps(result, indent=4))