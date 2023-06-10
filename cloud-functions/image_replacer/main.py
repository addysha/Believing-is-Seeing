
import converter as ec
import firebase_admin
from firebase_admin import firestore, storage
from google.cloud.firestore import Client as FirestoreClient 
import requests

# cred = credentials.Certificate('keys\\cloud_key.json')

app = firebase_admin.initialize_app(
    #    cred,

                                    options={"storageBucket":"seeing-is-believing-a9d2c.appspot.com"})

db: FirestoreClient = firestore.client()

def upload_url(url, name)->str:
        data = requests.get(url=url)
        blob = storage.bucket(app=app).blob(name)
        blob.upload_from_string(data.content, content_type='image/jpeg')
        blob.make_public(storage.storage.Client())
        return  blob.public_url


def hello_firestore(event, context):

    new_json = ec.FirestoreTriggerConverter(db).convert(event['value']['fields'])

    resource_string = context.resource

    # new_json = db.collection('Games').limit(1).get()[0]._data

    # resource_string = "Games/kKYJGwDJYKTixPRNXQbe"

    for key in new_json:
            game_entry = new_json[key]
            if type(game_entry) is not dict: continue
            game_entry['url'] = upload_url(game_entry.get("url"), game_entry.get("urlName"))
            new_json[key] = game_entry

    new_json['parsed'] = True

    db.document(resource_string).set(new_json)

    return "good"

