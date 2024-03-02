from dotenv import load_dotenv
import os
import requests

load_dotenv()

api_key = os.getenv("API_KEY")
nvd_id = os.getenv("NVD_ID")

query = """
{
  securityAdvisory(ghsaId: "GHSA-75rw-34q6-72cr" ) {
    ghsaId
    summary
    description
    severity
    references {
            url
          }
  }
}
"""

response = requests.post(
    'https://api.github.com/graphql',
    json={'query': query},
    headers={'Authorization': 'Bearer ' + api_key}
)

if response.status_code == 200:
    data = response.json()
    print(data)
else:
    print('Error:', response.status_code, response.reason)
