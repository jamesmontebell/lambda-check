from dotenv import load_dotenv
import os
import requests
import sqlite3

load_dotenv()

api_key = os.getenv("API_KEY")
import requests
import json

def fetch_global_security_advisories():
    url = "https://api.github.com/advisories"
    advisories = []

    headers = {
        'Authorization': 'token ' + api_key,
    }

    response = requests.get(url, headers=headers)
    response.raise_for_status()  # Raise an exception for bad status codes

    advisories.extend(response.json())

    # Check for pagination
    while 'next' in response.links:
        response = requests.get(response.links['next']['url'], headers=headers)
        response.raise_for_status()
        advisories.extend(response.json())

    return advisories

def filter_advisories_with_haskell_keyword(advisories):
    filtered_advisories = [advisory for advisory in advisories if 'haskell' in advisory['description'].lower()]
    return filtered_advisories

def save_to_json(advisories, filename):
    with open(filename, 'w') as f:
        json.dump(advisories, f, indent=4)

# Example usage:
global_security_advisories = fetch_global_security_advisories()
filtered_advisories = filter_advisories_with_haskell_keyword(global_security_advisories)
save_to_json(filtered_advisories, 'filtered_advisories.json')


