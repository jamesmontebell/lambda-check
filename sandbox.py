from dotenv import load_dotenv
import os
import requests

load_dotenv()

api_key = os.getenv("API_KEY")
nvd_id = os.getenv("NVD_ID")

ghsa_id = ['GHSA-75rw-34q6-72cr', 'GHSA-r5mv-3cq3-727q', 'GHSA-mgm6-c25g-557g', 'GHSA-w6w5-x32x-cg2w', 'GHSA-4q83-8359-v5v3']#Biscuit
#ghsa_id1 = 'GHSA-r5mv-3cq3-727q'#xml-condiut
#ghsa_id2 = 'GHSA-mgm6-c25g-557g'#vscode
#ghsa_id3 = 'GHSA-w6w5-x32x-cg2w'#dynamiclog
#ghsa_id4 = 'GHSA-4q83-8359-v5v3'#basic constraints
disc = {}
#list of arrays
#for loop to go through each one 
#Big data dictionary to hold the data for each one that is appended on "global data dictionary"
for value in ghsa_id:
  response = requests.get(
    f'https://api.github.com/advisories/{value}',
    headers={'Authorization': 'token ' + api_key}
  )
  if response.status_code == 200:
    data = response.json()
    print(data)
  else:
    print('Error:', response.status_code, response.reason)

  disc[f'{value}'] = data['']

if response.status_code == 200:
    data = response.json()
    print(data)
else:
    print('Error:', response.status_code, response.reason)
