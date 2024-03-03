from dotenv import load_dotenv
import os
import requests

load_dotenv()

api_key = os.getenv("API_KEY")
nvd_id = os.getenv("NVD_ID")

ghsa_id = ['GHSA-75rw-34q6-72cr', 'GHSA-r5mv-3cq3-727q', 'GHSA-mgm6-c25g-557g', 'GHSA-w6w5-x32x-cg2w', 'GHSA-4q83-8359-v5v3']#Biscuit

def get_github(id):
  response = requests.get(
    f'https://api.github.com/advisories/{id}',
    headers={'Authorization': 'token ' + api_key}
  )
  if response.status_code == 200:
    data = response.text
    return data
  else:
    print('Error:', response.status_code, response.reason)
  

for id in ghsa_id:
  print(get_github(id))

def get_nvd():
  response = requests.get(
  url= 'https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=haskell',
  )

  if response.status_code == 200:
    return response.text
  else:
    print('Error:', response.status_code, response.reason)\

print(get_nvd())

