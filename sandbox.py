from dotenv import load_dotenv
import os
import requests

load_dotenv()

api_key = os.getenv("API_KEY")
nvd_id = os.getenv("NVD_ID")

query = """
{
      securityVulnerabilities(last: 5) {
      nodes {
        package {
          name
        }
        advisory {
          ghsaId
          summary
          description
          severity
          references {
            url
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
