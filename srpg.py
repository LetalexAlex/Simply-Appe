import os
import json
import requests

PLAYER_TARGET = "LetalexAlex"

RANKING_API_URL = "https://srpg9.groovestats.com/api/get-ranking.php?type=level&gender=all&superregion=all&country=all"
API_BASE_URL = "https://srpg9.groovestats.com/api/get-songlist.php"

try:
    print(f"Searching ID for player '{PLAYER_TARGET}'...")
    
    response = requests.get(RANKING_API_URL)
    response.raise_for_status()
    ranking_data = response.json().get("data", [])
    
    player_id = None

    for row in ranking_data:
        if str(row[1]).strip().lower() == PLAYER_TARGET.lower():
            player_id = row[8]
            PLAYER_TARGET = str(row[1]).strip()
            break

    if not player_id:
        print(f"Player '{PLAYER_TARGET}' not found.")
        exit()
    
    print(f"Found: '{PLAYER_TARGET}' ID = {player_id}\n")
    print(f"Fetching songlist...")

    params = { 
        "entrantid": player_id,
        "notyou": "1",
        "_": "1716766983375"
    } 

    api_response = requests.get(API_BASE_URL, params=params)
    api_response.raise_for_status()
    song_rows = api_response.json().get("data", [])

    print(f"Found {len(song_rows)} songs.\n")
    print(f"{'TITLE':<32} | {'BPM EFF':<8} | {'DIFF':<4} | {'RATE':<5} | {'SCORE':<7} | {'STATUS':<10} | {'TIME':<5} | {'XP':<6}")
    print("-" * 96)

    json_data = []
    for row in song_rows:
        title = row[4]
        diff = row[3]
        rate = row[25]
        xp = row[24]
        bpm_base = row[5]
        score = row[26]
        status = row[27]
        duration_sec = row[6]

        rate_str = f"{rate}x" if rate else "1.00x"
        score_str = f"{score}%" if score else "0.00%"
        
        print(f"{title:<32} | {bpm_base:<8} | {diff:<4} | {rate_str:<5} | {score_str:<7} | {status:<10} | {duration_sec:<5} | {xp:<6}")
        
        json_data.append({
            "title": title,
            "bpm_base": bpm_base,
            "diff": diff,
            "rate": rate_str,
            "score": score_str,
            "status": status,
            "duration_sec": duration_sec,
            "xp": xp
        })

    script_dir = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(script_dir, "srpg_data.json"), "w", encoding="utf-8") as f:
        json.dump(json_data, f, indent=4)
        print(f"\n[OK] srpg_data.json wrote correctly for {PLAYER_TARGET}!")

except requests.exceptions.RequestException as e:
    print(f"Network error: {e}")