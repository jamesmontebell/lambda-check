from dotenv import load_dotenv
import os
import requests

load_dotenv()

api_key = os.getenv("API_KEY")
nvd_id = os.getenv("NVD_ID")

query = """
{
  securityAdvisories(first: 10) {
    nodes {
      summary
      description
      publishedAt
      withdrawnAt
      references {
        url
      }
      vulnerabilities(first: 5) {
        nodes {
          package {
            name
            ecosystem
          }
          severity
          updatedAt
        }
      }
    }
  }
}
"""

headers = {
    'Authorization': api_key,
}

response = requests.post('https://api.github.com/graphql', json={'query': query}, headers=headers)

if response.status_code == 200:
    data = response.json()
    # Process data here
else:
    print('Error:', response.status_code)