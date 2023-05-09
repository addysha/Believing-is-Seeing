from SPARQLWrapper import SPARQLWrapper, JSON
from datetime import datetime

# Set up the SPARQL endpoint
endpoint_url = "https://query.wikidata.org/sparql"
sparql = SPARQLWrapper(endpoint_url)

# Set up a new SPARQLWrapper object for the query for Abraham Lincoln
sparql_abraham = SPARQLWrapper(endpoint_url)

# Set up the query for Abraham Lincoln
query_abraham = """
PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?name ?birthdate ?deathdate
WHERE {
  wd:Q91 rdfs:label ?name.
  FILTER(LANG(?name) = "en").
  wd:Q91 wdt:P569 ?birthdate.
  wd:Q91 wdt:P570 ?deathdate.
}
"""

# Execute the query for Abraham Lincoln and retrieve the results
sparql_abraham.setQuery(query_abraham)
sparql_abraham.setReturnFormat(JSON)
results_abraham = sparql_abraham.query().convert()

# Print the results for Abraham Lincoln
for result in results_abraham["results"]["bindings"]:
    name = result["name"]["value"]
    birthdate = datetime.strptime(result["birthdate"]["value"], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d")
    deathdate = datetime.strptime(result["deathdate"]["value"], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d")
    print(f"Name: {name}, Birth Date: {birthdate}, Death Date: {deathdate}")


# Set up a new SPARQLWrapper object for the query for Albert Einstein
sparql_einstein = SPARQLWrapper(endpoint_url)

# Set up the query for Albert Einstein
query_einstein = """
PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?name ?birthdate ?deathdate
WHERE {
  wd:Q937 rdfs:label ?name.
  FILTER(LANG(?name) = "en").
  wd:Q937 wdt:P569 ?birthdate.
  wd:Q937 wdt:P570 ?deathdate.
}
"""

# Execute the query for Albert Einstein and retrieve the results
sparql_einstein.setQuery(query_einstein)
sparql_einstein.setReturnFormat(JSON)
results_einstein = sparql_einstein.query().convert()

# Print the results for Albert Einstein
for result in results_einstein["results"]["bindings"]:
    name = result["name"]["value"]
    birthdate = datetime.strptime(result["birthdate"]["value"], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d")
    deathdate = datetime.strptime(result["deathdate"]["value"], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d")
    print(f"Name: {name}, Birth Date: {birthdate}, Death Date: {deathdate}")
