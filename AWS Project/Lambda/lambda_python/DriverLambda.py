import json
import requests
import boto3


def lambda_handler(event, context):
    
    ID = json.loads(event["body"])["ID"]
    Name = json.loads(event["body"])["Name"]
    Kind = json.loads(event["body"])["Kind"]
    Src = json.loads(event["body"])["Src"]
    Dest = json.loads(event["body"])["Dest"]

    # open a session
    dynamodb = boto3.resource("dynamodb")

    # table name
    table = dynamodb.Table("DriverTable")

    # put item into dynamoDB
    table.put_item(Item={"ID": ID, "Name": Name, "Kind": Kind, "Src": Src, "Dest": Dest})

    # RESTfully send json to api.go
    json_data = {"ID": ID, "Kind": Kind}

    # Converts a Python object into a JSON String
    jsonData = json.dumps(json_data)

    headers = {"Content-type": "application/json", "Accept": "text/plain"}

    r = requests.post("http://3.80.84.146:9999/api", jsonData, headers)
    r.connection.close()

    return {
        "statusCode": 200,
        "body": "Request has been received, wait for email for more details",
    }
