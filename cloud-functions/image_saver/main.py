import firebase_admin
from firebase_admin import firestore, credentials, storage
from google.cloud.firestore import Client as FirestoreClient 
from google.cloud.storage import Client as StorageClient 
import requests
from datetime import timedelta
import functions_framework

cred = credentials.Certificate('keys\\cloud_key.json')

app = firebase_admin.initialize_app(cred,
                                    options={"storageBucket":"seeing-is-believing-a9d2c.appspot.com"})

db: FirestoreClient = firestore.client()

@functions_framework.http
def upload_url(request):
    url = request.headers.get('url')
    name = request.headers.get('name')
    if url == None or name == None:
        return {"message":"no url or no name"}
    else:
        data = requests.get(url=url)
        blob = storage.bucket(app=app).blob(name)
        blob.upload_from_string(data.content, content_type='image/jpeg')
        blob.make_public(storage.storage.Client())
        return  blob.public_url

        