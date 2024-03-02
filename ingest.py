from dotenv import load_dotenv
import os
import requests

load_dotenv()

api_key = os.getenv("API_KEY")
nvd_id = os.getenv("NVD_ID")

ghsa_id = ['GHSA-75rw-34q6-72cr', 'GHSA-r5mv-3cq3-727q', 'GHSA-mgm6-c25g-557g', 'GHSA-w6w5-x32x-cg2w', 'GHSA-4q83-8359-v5v3']#Biscuit

my_dict = {}

for value in ghsa_id:
  response = requests.get(
    f'https://api.github.com/advisories/{value}',
    headers={'Authorization': 'token ' + api_key}
  )
  if response.status_code == 200:
    data = response.json()
    # print(data)
    my_dict[value] = data
  else:
    print('Error:', response.status_code, response.reason)

for key, value in my_dict.items():
  for k, v in value.items():
    print(k)
  break

nvd_data = None

response = requests.get(
  url= 'https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=haskell',
)

if response.status_code == 200:
  nvd_data = response.json()
else:
  print('Error:', response.status_code, response.reason)

print(nvd_data)