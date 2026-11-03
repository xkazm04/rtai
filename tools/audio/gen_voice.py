"""Quest 1 voice lines via ElevenLabs text-to-speech (POF-GAP 2: PoF has no tts). Key from env ELEVENLABS_API_KEY only.
Usage: python tools/audio/gen_voice.py <quest.json> <casting.json> <masters_voice_dir> [line-id ...]"""
import json, os, sys, time, urllib.request, pathlib


def tts(voice_id: str, model: str, text: str, cfg: dict) -> bytes:
    body = {"text": text, "model_id": model, "voice_settings": {
        "stability": cfg["stability"], "similarity_boost": cfg["similarity_boost"], "style": cfg["style"],
        "use_speaker_boost": True, "speed": cfg["speed"]}}
    req = urllib.request.Request(f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}?output_format=mp3_44100_128",
                                 json.dumps(body).encode(), {"Content-Type": "application/json", "xi-api-key": os.environ["ELEVENLABS_API_KEY"]})
    with urllib.request.urlopen(req, timeout=180) as r:
        return r.read()


def main() -> None:
    quest = json.load(open(sys.argv[1], encoding="utf-8"))
    cast = json.load(open(sys.argv[2], encoding="utf-8"))
    out = pathlib.Path(sys.argv[3]); out.mkdir(parents=True, exist_ok=True)
    only = set(sys.argv[4:])
    spent = 0
    for line in quest["lines"]:
        if only and line["id"] not in only: continue
        dst = out / f"{line['id']}.mp3"
        if dst.exists(): continue
        c = cast["cast"][line["speaker"]]
        dst.write_bytes(tts(c["voice_id"], cast["model"], line["text"], c))
        spent += len(line["text"])
        rec = {"file": dst.name, "line": line["id"], "speaker": line["speaker"], "voice": c["voice"], "chars": len(line["text"]), "route": "elevenlabs-tts-direct", "ts": time.time()}
        with open(out / "voice_log.jsonl", "a") as f: f.write(json.dumps(rec) + chr(10))
        print("ok", dst.name, len(line["text"]), flush=True)
    print("chars spent", spent)

main()
