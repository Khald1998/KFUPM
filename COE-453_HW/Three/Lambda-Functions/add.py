import json
import boto3
import random

client=boto3.resource("dynamodb")
table=client.Table("table")

def lambda_handler(event, context):
    x = event["queryStringParameters"]["x"]
    y = event["queryStringParameters"]["y"]
    # x = event["x"]
    # y = event["y"]
    op = "add"
    res = int(x) + int(y)  
    res = str(res)
    response=table.scan()
    done=True

    Items = response['Items']
    OpIdLis=[]
    for idx,i in enumerate(Items):
        OpIdLis.append(i['OpId'])
    while done:
        num = random.randint(0, 100)
        print(num)
        if (str(num) not in OpIdLis):
            done=False

    NewOpId=num
    NewOpId=str(NewOpId)
    table.put_item(
        Item={
            'OpId':NewOpId,
            'op':op,
            'res':res,
            'x':x,
            'y':y
            
        })
    return {
        'statusCode': 200,
        'body': json.dumps(f'{x} + {y} = {res}')
    }    