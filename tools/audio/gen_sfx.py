"""Generate the day-run SFX set. PoF's /api/audio-gen could not be used (POF-GAP 1, see JOURNAL), so this calls
ElevenLabs /v1/sound-generation directly. Key comes from env ELEVENLABS_API_KEY only. Raw mp3s go to the masters dir.
Usage: python tools/audio/gen_sfx.py <masters_raw_dir> [only_key_prefix]"""
import json, os, sys, urllib.request, pathlib, time

URL = "https://api.elevenlabs.io/v1/sound-generation?output_format=mp3_44100_128"
SPECS = [
  # key, kind, duration, loop, variations, prompt
  ("pistol_shot", "sfx", 0.8, False, 3, "single close-miked 9mm pistol gunshot, sharp crack with short room tail, dry, no music, no voices"),
  ("pistol_shot", "sfx", 0.8, False, 4, "9mm handgun gunshot, one sharp crack then a quick natural decay, no sustained noise, no hiss, dry outdoor, no music", 4),
  ("rifle_shot", "sfx", 1.0, False, 3, "single assault rifle gunshot, heavy punchy crack with a short outdoor echo, no music, no voices"),
  ("nailgun_shot", "sfx", 0.7, False, 3, "single pneumatic roofing nail gun shot, compressed-air thump and metallic clack, no music"),
  ("impact_flesh", "sfx", 0.6, False, 2, "bullet hitting a body, wet meaty thud, short, no music"),
  ("impact_metal", "sfx", 0.7, False, 2, "bullet ricochet hitting sheet metal, sharp clang and a short whine, no music"),
  ("impact_concrete", "sfx", 0.7, False, 2, "bullet hitting a concrete wall, dry chip and crack with gritty debris, no music"),
  ("shock_crackle", "sfx", 1.5, False, 2, "electric shock crackle, arcing electricity zap with buzzing sparks, short burst, no music"),
  ("engine_loop", "sfx", 4.0, True, 1, "old car engine idling and revving gently, steady looping engine rumble, seamless loop, no music"),
  ("horn", "sfx", 1.0, False, 2, "short sharp car horn honk, single beep, urban street"),
  ("crash", "sfx", 2.0, False, 2, "car crash, metal crunch and glass shattering, one impact, no music"),
  ("tyre_screech", "sfx", 1.5, False, 2, "car tyres screeching on asphalt during a hard turn, no music"),
  ("siren_loop", "sfx", 4.0, True, 1, "police siren wailing, two-tone sweeping, seamless loop, distant street, no music"),
  ("crowd_panic", "ambient", 4.0, False, 2, "crowd of people screaming and panicking in a city street, running footsteps, distant, no music, no intelligible words"),
  ("footsteps", "sfx", 2.0, False, 2, "footsteps of one person walking steadily on concrete pavement, 4 steps, dry, no music"),
  ("servo_whine", "sfx", 1.5, False, 2, "small robot servo motor whine, quick mechanical whirring and a soft clank, no music"),
  ("kill_punch", "sfx", 0.9, False, 2, "short heavy cinematic punch impact with a deep sub thump and a sharp snap, one hit, comic-book knockout, dry, no music, no voices"),
  ("kill_punch", "sfx", 0.9, False, 2, "heavy punch impact, deep thump and a sharp snap, one hit, not too loud, dry, no music, no voices", 3),
  ("cash_ding", "sfx", 0.8, False, 2, "bright coin pickup ding, two quick metallic chimes, arcade reward, clean, no music"),
  ("ui_click", "sfx", 0.5, False, 2, "soft mechanical UI button click, short dry tick, no music"),
  ("ui_confirm", "sfx", 0.6, False, 2, "short positive UI confirm blip, two rising electronic tones, clean, no music"),
  ("ui_back", "sfx", 0.5, False, 2, "short low UI cancel blip, one falling electronic tone, clean, no music"),
  ("ui_back", "sfx", 0.5, False, 1, "short low UI cancel blip, one falling electronic tone, quiet, clean, no music", 3),
  ("objective_ping", "sfx", 1.0, False, 2, "soft notification ping, single bell-like chime with a short tail, mission objective update, no music"),
  ("city_ambience", "ambient", 8.0, True, 1, "night city street ambience, distant traffic, faint wind, occasional far-away siren, seamless loop, no music, no voices"),
]


def post(body):
    req = urllib.request.Request(URL, json.dumps(body).encode(),
                                 {"Content-Type": "application/json", "xi-api-key": os.environ["ELEVENLABS_API_KEY"]})
    with urllib.request.urlopen(req, timeout=180) as r:
        return r.read()

def main():
    out = pathlib.Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
    only = sys.argv[2] if len(sys.argv) > 2 else ""
    log = []
    for key, kind, dur, loop, n, prompt, *rest in SPECS:
        first = rest[0] if rest else 1
        if only and not key.startswith(only): continue
        for v in range(first, first + n):
            body = {"text": f"{prompt} (take {v})"[:440], "duration_seconds": dur, "prompt_influence": 0.5}
            dst = out / f"{key}_{v:02d}.mp3"
            if dst.exists(): continue
            try:
                data = post(body)
            except Exception as e:  # noqa: BLE001
                print("FAIL", key, v, e); log.append({"key": key, "take": v, "error": str(e)}); continue
            dst.write_bytes(data)
            log.append({"key": key, "take": v, "file": dst.name, "prompt": body["text"], "kind": kind, "duration": dur,
                        "loop": loop, "route": "elevenlabs-direct", "ts": time.time()})
            print("ok", dst.name, flush=True)
    with open(out / "gen_log.jsonl", "a") as f:
        for l in log: f.write(json.dumps(l) + chr(10))

main()
