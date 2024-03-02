from dotenv import load_dotenv
import os
import requests

load_dotenv()

api_key = os.getenv("API_KEY")
nvd_id = os.getenv("NVD_ID")

query = """
{
      securityVulnerabilities(first: 10, ecosystem: HASKELL) {
        nodes {
          advisory {
            summary
            identifiers {
              type
              value
            }
          }
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
    for key, value in data.items():
        print(key,':',value)
        print('\n')
else:
    print('Error:', response.status_code, response.reason)