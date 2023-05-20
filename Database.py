import requests
import json
import time
from datetime import datetime

# Function to send a query to Wikidata SPARQL endpoint
def send_query(query):
    url = 'https://query.wikidata.org/sparql'
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0;Win64) AppleWebkit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'}
    params = {'format': 'json', 'query': query}

    try:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print("Error occurred during the request:", e)
        return None

# Load JSON data from file
with open('persons.json', 'r') as json_file:
    data = json.load(json_file)

# Iterate over each person and query their information
for person in data['persons']:
    code = person['code']
    name = person['name']

    # Construct the SPARQL query
    query = f'''
    SELECT ?birthdate ?deathdate WHERE {{
      wd:{code} wdt:P569 ?birthdate.
      OPTIONAL {{ wd:{code} wdt:P570 ?deathdate. }}
    }}
    '''

    # Send the query and handle potential server timeouts
    while True:
        result = send_query(query)
        if result is not None:
            break
        else:
            print("Waiting for server timeout...")
            time.sleep(5)

    # Extract and print the information
    if 'results' in result and 'bindings' in result['results']:
        bindings = result['results']['bindings']
        if len(bindings) > 0:
            birthdate = datetime.strptime(bindings[0]['birthdate']['value'], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d")
            deathdate = datetime.strptime(bindings[0]['deathdate']['value'], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d") if 'deathdate' in bindings[0] else "Unknown"
            print(f"Name: {name}, Birth Date: {birthdate}, Death Date: {deathdate}")
        else:
            print(f"No information found for {name}")
    else:
        print(f"Error occurred while processing {name}")
    
    # Wait for a second before sending the next query
    time.sleep(1)
