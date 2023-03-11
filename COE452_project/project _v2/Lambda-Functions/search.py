import json
import boto3

client=boto3.resource("dynamodb")
table=client.Table("things")

def lambda_handler(event, context):
    matchedList = []
    event["queryStringParameters"]["name"]
    

    
    response = table.scan()
    all_records = response["Items"]
    for record in all_records:
        if record["name"].contain(event["name"]):
            matchedList.append(record)
    
    print(matchedList)


    return {
        'statusCode': 200,
        'body': json.dumps("hi")
    }