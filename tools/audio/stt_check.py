"""Ear proxy for the TTS voices: transcribes every quest 1 voice file with a local Whisper model (HF cache, offline) and
compares the words with the line text (word error rate after lower-casing, punctuation stripped). A high WER = the TTS
misread / mumbled / dropped words. NOT a listening test (no pacing, no acting, no timbre). Usage: python tools/audio/stt_check.py <out.json>"""
import json, os, pathlib, re, subprocess, sys, tempfile
os.environ["HF_HUB_OFFLINE"] = "1"
import numpy as np
from transformers import pipeline

quest = json.loads(pathlib.Path("project/quests/collect-call/quest.json").read_text(encoding="utf-8"))
asr = pipeline("automatic-speech-recognition", model="openai/whisper-base.en", chunk_length_s=30, device=-1)


def words(t: str) -> list:
    return re.sub(r"[^a-z0-9' ]", " ", t.lower().replace("’", "'")).split()


def wer(ref: list, hyp: list) -> float:
    d = list(range(len(hyp) + 1))
    for i, r in enumerate(ref, 1):
        prev, d[0] = d[0], i
        for j, h in enumerate(hyp, 1):
            prev, d[j] = d[j], min(d[j] + 1, d[j - 1] + 1, prev + (r != h))
    return d[-1] / max(len(ref), 1)


rows = []
for l in quest["lines"]:
    f = pathlib.Path("project/assets/audio/voice") / (l["id"] + ".ogg")
    pcm = subprocess.run(["ffmpeg", "-v", "error", "-i", str(f), "-ac", "1", "-ar", "16000", "-f", "f32le", "-"], capture_output=True, check=True).stdout
    audio = np.frombuffer(pcm, dtype=np.float32).copy()
    hyp = asr({"raw": audio, "sampling_rate": 16000})["text"].strip()
    w = wer(words(l["text"]), words(hyp))
    rows.append({"id": l["id"], "speaker": l["speaker"], "wer": round(w, 3), "heard": hyp, "text": l["text"]})
    print(f"{l['id']:34s} wer {w:.2f}", flush=True)
pathlib.Path(sys.argv[1]).write_text(json.dumps({"model": "openai/whisper-base.en", "mean_wer": round(sum(r["wer"] for r in rows) / len(rows), 3), "lines": rows}, indent=1))
print("mean wer", round(sum(r["wer"] for r in rows) / len(rows), 3))
