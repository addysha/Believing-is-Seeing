import firebase_admin
from firebase_admin import firestore, credentials, storage
from google.cloud.firestore import Client as FirestoreClient 
from google.cloud.storage import Client as StorageClient 
import requests
from datetime import timedelta
import functions_framework
from firebase_functions import https_fn
import json

cred = credentials.Certificate('keys\\cloud_key.json')

app = firebase_admin.initialize_app(cred,
                                    options={"storageBucket":"seeing-is-believing-a9d2c.appspot.com"})

db: FirestoreClient = firestore.client()

@functions_framework.http
@https_fn.on_request()
def upload_url(request: https_fn.Request):
    url = None
    name = None
    print(request)
    print(request.parameter_storage_class)
    print(bytes.decode(request.data))
    
    
   
    headers = {
        'Access-Control-Allow-Origin': '*'
    }
    if url == None or name == None:
        print('here')
        return ("no url or no name", 401, headers)
    else:
        data = requests.get(url=url)
        print(data)
        blob = storage.bucket(app=app).blob(name)
        blob.upload_from_string(data.content, content_type='image/jpeg')
        blob.make_public(storage.storage.Client())
        return  (blob.public_url, 200,headers )

        