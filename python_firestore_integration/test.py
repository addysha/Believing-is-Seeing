import firebase_admin
from firebase_admin import firestore, credentials
import logging 
from google.cloud.firestore import Client as FirestoreClient # importing the return type of firestore.client()

# from shapely.geometry import Point
# from shapely.geometry.polygon import Polygon

cred = credentials.Certificate('python_firestore_integration\\cloud_key.json')
app = firebase_admin.initialize_app(cred)
db: FirestoreClient = firestore.client() # Addid


db.collection('test').add({"test":"test"})