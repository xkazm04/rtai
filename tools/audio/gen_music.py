"""Radio station stub: 3 short loops + 1 stinger via ElevenLabs /v1/music (POF-GAP 3: PoF has no music kind).
Key from env ELEVENLABS_API_KEY only. Usage: python tools/audio/gen_music.py <masters_music_dir>"""
import json, os, pathlib, sys, time, urllib.request

TRACKS = [
    ("radio_loop_1", 20000, "dusty late-night radio jazz, muted trumpet over brushed drums and upright bass, warm and a little sad, mellow 85 bpm, instrumental, loops cleanly"),
    ("radio_loop_2", 20000, "gritty industrial synth groove, steady 110 bpm, heavy analog bass pulse and clanking percussion, tense city night drive, instrumental, loops cleanly"),
    ("radio_loop_3", 20000, "tinny fast garage-punk instrumental, distorted guitar riff and shouty drums, 150 bpm, lo-fi AM radio feel, instrumental, loops cleanly"),
    ("boss_loop", 24000, "tense boss-fight instrumental, driving 120 bpm, heavy distorted bass pulse, industrial metal percussion and a dark brooding synth drone, relentless, no melody lead, instrumental, loops cleanly"),
    ("radio_stinger", 3000, "short dramatic brass and timpani sting, one big hit then a quick decay, comic noir"),
]
out = pathlib.Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
for name, ms, prompt in TRACKS:
    dst = out / f"{name}.mp3"
    if dst.exists(): continue
    body = {"prompt": prompt, "music_length_ms": ms, "force_instrumental": True}
    req = urllib.request.Request("https://api.elevenlabs.io/v1/music?output_format=mp3_44100_128", json.dumps(body).encode(),
                                 {"Content-Type": "application/json", "xi-api-key": os.environ["ELEVENLABS_API_KEY"]})
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            dst.write_bytes(r.read())
    except Exception as e:  # noqa: BLE001
        detail = e.read()[:300] if hasattr(e, "read") else b""
        print("FAIL", name, e, detail); continue
    with open(out / "music_log.jsonl", "a") as f:
        f.write(json.dumps({"name": name, "file": dst.name, "tool": "elevenlabs-music (direct API; PoF has no music kind, POF-GAP 3)",
                            "model": "elevenlabs music", "prompt_ref": f"masters:day-d5/audio/music/music_log.jsonl#{name}: {prompt}",
                            "human_edits": "loop seam crossfaded 0.5 s, peak-normalised -6 dBFS, Ogg Vorbis q4", "length_ms": ms, "ts": time.time()}) + chr(10))
    print("ok", name, dst.stat().st_size)
