from dotenv import load_dotenv
import os
import requests
import sqlite3

load_dotenv()

api_key = os.getenv("API_KEY")
import json

def fetch_advisories(before=None, after=None, per_page=100):
    url = 'https://api.github.com/advisories'
    headers = {
        'Authorization': 'token ' + api_key
    }
    params = {
        'per_page': per_page
    }

    if before:
        params['before'] = before
    elif after:
        params['after'] = after

    response = requests.get(url, headers=headers, params=params)

    if response.status_code == 200:
        advisories = response.json()
        return advisories
    else:
        print(f"Failed to fetch advisories. Status code: {response.status_code}")
        return None

def fetch_all_advisories(per_page=100):
    all_advisories = []

    # Fetch the first page of advisories
    advisories = fetch_advisories(per_page=per_page)

    if advisories:
        all_advisories.extend(advisories)
        last_advisory = advisories[-1]  # Get the last advisory

        # Fetch subsequent pages of advisories using the 'before' parameter
        while advisories:
            before_id = last_advisory.get('id')
            advisories = fetch_advisories(before=before_id, per_page=per_page)
            if advisories:
                all_advisories.extend(advisories)
                last_advisory = advisories[-1]  # Update the last advisory

    return all_advisories

def filter_advisories(advisories):
    filtered_advisories = [advisory for advisory in advisories if 'haskell' in advisory['description'].lower()]
    return filtered_advisories

def save_to_json(advisories):
    if advisories:
        with open('haskell_advisories.json', 'w') as f:
            json.dump(advisories, f, indent=4)
        print("Filtered advisories saved to haskell_advisories.json")
    else:
        print("No advisories to save.")

if __name__ == "__main__":
    all_advisories = fetch_all_advisories(per_page=100)
    if all_advisories:
        filtered_advisories = filter_advisories(all_advisories)
        save_to_json(filtered_advisories)









