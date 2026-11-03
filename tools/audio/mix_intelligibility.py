"""Are the voice lines intelligible IN THE MIX? Transcribes a recorded clip's audio with a local Whisper (base.en, offline) and, for every
quest line the clip asked for (a cues json with `voice_lines`), finds the best matching window of the transcript (difflib ratio on words).
A line that was dropped by the voice queue should score low, a spoken one high; a spoken one that scores low is masked by the mix.
Not a listening test. Usage: python tools/audio/mix_intelligibility.py <clip.mp4> <cues.json> <out.json>"""
import difflib, json, os, pathlib, re, subprocess, sys
os.environ["HF_HUB_OFFLINE"] = "1"
import numpy as np
from transformers import pipeline

clip, cues, out = sys.argv[1:4]
quest = json.loads(pathlib.Path("project/quests/collect-call/quest.json").read_text(encoding="utf-8"))
text = {l["id"]: l["text"] for l in quest["lines"]}
asked = json.loads(pathlib.Path(cues).read_text())["voice_lines"]
pcm = subprocess.run(["ffmpeg", "-v", "error", "-i", clip, "-ac", "1", "-ar", "16000", "-f", "f32le", "-"], capture_output=True, check=True).stdout
audio = np.frombuffer(pcm, dtype=np.float32).copy()
asr = pipeline("automatic-speech-recognition", model="openai/whisper-base.en", chunk_length_s=30, stride_length_s=5, device=-1)
heard = asr({"raw": audio, "sampling_rate": 16000})["text"]


def words(t: str) -> list:
    return re.sub(r"[^a-z0-9' ]", " ", t.lower().replace("’", "'")).split()


hw = words(heard)
rows = []
for lid in asked:
    w = words(text[lid])
    best = 0.0
    n = len(w)
    for i in range(0, max(len(hw) - n // 2, 1)):
        for span in (n - n // 5, n, n + n // 5):
            r = difflib.SequenceMatcher(None, w, hw[i:i + max(span, 1)]).ratio()
            best = max(best, r)
    rows.append({"id": lid, "match": round(best, 2)})
    print(f"{lid:34s} {best:.2f}", flush=True)
pathlib.Path(out).write_text(json.dumps({"clip": clip, "transcript": heard, "lines": rows}, indent=1))
