import requests

url = "https://srpg9.groovestats.com/api/get-songlist.php?entrantid=39&notyou=1&_=1779786320365"

try:
    song_rows = requests.get(url).json().get("data", [])
    
    import json
    import os
    
    print(f"Found {len(song_rows)} songs.\n")
    print(f"{'TITLE':<32} | {'BPM EFF':<8} | {'DIFF':<4} | {'RATE':<5} | {'SCORE':<7} | {'STATUS':<10} | {'TIME':<5} | {'XP':<6}")
    print("-" * 96)
    
    json_data = []
    for riga in song_rows:
        title = riga[4]
        diff = riga[3]
        rate = riga[25]
        xp = riga[24]
        bpm_base = riga[5]
        score = riga[26]
        status = riga[27]
        duration_sec = riga[6]

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

except requests.exceptions.RequestException as e:
    print(f"Network error: {e}")
