import requests
response = requests.get('https://australia-southeast1-seeing-is-believing-a9d2c.cloudfunctions.net/save_url_to_storage',
                   headers={"url": "https://images.unsplash.com/photo-1575936123452-b67c3203c357?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D&w=1000&q=80","name":"tessadaddating"}
                   )
print(response.content)