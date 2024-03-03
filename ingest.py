from dotenv import load_dotenv
import os
import requests
import sqlite3

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
    data = response.json()
    return data
  else:
    print('Error:', response.status_code, response.reason)
  

github_list = []
for id in ghsa_id:
  github_list.append(get_github(id))

def get_nvd():
  response = requests.get(
  url= 'https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=haskell',
  )

  if response.status_code == 200:
    return response.json()
  else:
    print('Error:', response.status_code, response.reason)\

nvd = get_nvd()

github_dict = {}
count = 0
for cve in github_list:
  github_dict[str(count)] = {
    "cve_id" : cve["cve_id"],
    "severity" : cve["severity"],
    "html_url" : cve["html_url"],
    "summary" : cve["summary"],
    "description" : cve["description"],
  }
  for v in cve["vulnerabilities"]:
    github_dict[str(count)]["package_name"] = v["package"]["name"]
    github_dict[str(count)]["version"] = v["vulnerable_version_range"]
  count += 1

# print(github_dict)

nvd_dict = {}
count = 0
for cve in nvd["vulnerabilities"]:
  nvd_dict[str(count)] = {
    "cve_id" : cve["cve"]["id"],
  }
  for x in cve["cve"]["descriptions"]:
      if x["lang"] == "en":
        nvd_dict[str(count)]["description"] = x["value"]
      break
    
  for d in cve["cve"]["metrics"]["cvssMetricV31"]:
    nvd_dict[str(count)]["severity"] = d["cvssData"]["baseSeverity"]
    nvd_dict[str(count)]["version"] = d["cvssData"]["version"]
  
  
  nvd_dict[str(count)]["package_name"] = "haskell package vulnerability"
  nvd_dict[str(count)]["html_url"] = "https://nvd.nist.gov/vuln/search/results?form_type=Basic&results_type=overview&query=haskell&search_type=all&isCpeNameSearch=false"
  nvd_dict[str(count)]["summary"] = nvd_dict[str(count)]["description"][:45] + "..."
  count += 1

print(nvd_dict)