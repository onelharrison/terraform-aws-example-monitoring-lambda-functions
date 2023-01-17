from faker import Faker

fake = Faker()


def handler(event, context):
    if event["trigger_error"]:
        raise Exception 

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"profile": { "name": fake.name(), "address": fake.address() }}),
    }


if __name__ == "__main__":
    pass
