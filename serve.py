from fastapi import FastAPI
import sqlite3

app = FastAPI()
conn = sqlite3.connect('haskVul.db')


@app.get("/search/")
async def search_items(term: str = None):
    if term:
        cursor = conn.cursor()
        query = f"SELECT summary, Severity FROM packageVul WHERE package_name='{term}'"
        cursor.execute(query)
        conn.commit()
        results = cursor.fetchone()
        cursor.close()
        if results:
            results = list(results)
            final = []
            final.append(results[0].replace("\n"," ").replace("#", ""))
            final.append(results[1].replace("\n"," ").replace("#", ""))
            return final[0] + ' - ' + final[1]
        else:
            return "No vulnerabilities found"
    else:
        return {"message": "No search query provided"}
    

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
